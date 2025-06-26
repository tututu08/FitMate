//
//  AuthService.swift
//  FitMate
//
//  Created by NH on 6/12/25.
//

import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import RxSwift
import KakaoSDKUser
import KakaoSDKAuth
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

enum KakaoLoginError: LocalizedError {
  case userCancelled
  case networkError
  case invalidToken
  case unknownError(String)
  var errorDescription: String? {
    switch self {
    case .userCancelled:
      return "사용자가 로그인을 취소했습니다."
    case .networkError:
      return "네트워크 연결을 확인해주세요."
    case .invalidToken:
      return "로그인 토큰이 유효하지 않습니다."
    case .unknownError(let message):
      return message
    }
  }
}

typealias KakaoUser = KakaoSDKUser.User

final class AuthService: NSObject {
    
    static let shared = AuthService()
    
    private override init() {
        super.init()
        configureGoogleSignIn()
    }
    
    private func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    /// - 구글 로그인 화면을 띄움
    /// - 사용자 로그인 성공 시, Firebase 인증 처리
    /// - 성공한 사용자를 Rx의 Single<User> 로 방출
    func signInWithGoogle(presentingVC: UIViewController) -> Single<FirebaseAuth.User> {
        return Single.create { observer in
            // Swuft Concurrency 에서 비동기 코드를 실행하기 위해 Task 사용
            Task { @MainActor in // @MainActor를 붙인 이유: 로그인 UI를 띄우는 작업이므로 반드시 메인 스레드에서 실행되어야 함
                do {
                    // 구글 로그인 화면을 띄우고, 사용자가 로그인할 때까지 기다림.
                    // try await: 실패할 수도 있는 비동기 작업이기 때문에 try와 await을 함께 사용
                    // 로그인 결과(GIDGoogleUser)를 await으로 돌려줌
                    // await : 비동기 함수의 결과가 올 때까지 잠깐 멈췄다가 다시 이어서 실행하라는 뜻.
                    let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
                    
                    // 구글 로그인 결과에서 idToken 을 꺼냄
                    // idToken은 구글이 "이 유저는 인증됨"을 보증해주는 서명된 문자열
                    // 값이 없으면, 실패로 간주하고 .failure 이벤트를 내보냄
                    guard let idToken = signInResult.user.idToken?.tokenString else {
                        observer(.failure(NSError(domain: "GoogleAuth", code: -2)))
                        return
                    }
                    
                    // Firebase 인증용 Credential 만들기
                    // Firebase에게 “이 사람은 구글에서 인증됐어요”라고 증명하기 위한 자격 증명 (credential)을 생성
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: signInResult.user.accessToken.tokenString
                    )
                    
                    // Firebase에 구글 로그인 결과를 전달해서, Firebase 인증을 시도
                    // 성공하면 Firebase User 객체 리턴
                    Auth.auth().signIn(with: credential) { result, error in
                        if let error = error {
                            observer(.failure(error))
                        } else if let user = result?.user {
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            observer(.success(user))
                        } else {
                            observer(.failure(NSError(domain: "FirebaseAuth", code: -3)))
                        }
                    }
                } catch {
                    observer(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    /// 카카오 사용자 정보로 firebase 이메일/비번 방식 로그인 시도
    /// 이메일 = kakaoUser.kakaoAccount?.email
    /// 비번 = kakaoUser.id를 문자열로 변환해서 사용
    /// 이미 가입됐으면 로그인 / 아니면 회원가입
    func signInWithKakao(kakaoUser: KakaoUser) -> Single<FirebaseAuth.User> {
        return Single.create { single in
            Task {
                do {
                    // 이메일 및 id가 nil인지 확인 후 언래핑
                    guard let email = kakaoUser.kakaoAccount?.email,
                          let id = kakaoUser.id else {
                        // nil이면 실패
                        single(.failure(NSError(domain: "kakaoAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "이메일 또는 ID 없음"])))
                        return
                    }
                    // 카카오 id를 문자열로 변환하고 비번처럼 사용
                    let password = String(id)
                    
                    do {
                        // firebase에 새 사용자로 회원가입 시도
                        let user = try await Auth.auth().createUser(withEmail: email, password: password).user
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        // 성공하면 결과 방출
                        single(.success(user))
                    } catch let error as NSError {
                        // 이미 존재하는 이메일이면 로그인 시도
                        if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                            let user = try await Auth.auth().signIn(withEmail: email, password: password).user
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            single(.success(user))
                        } else {
                            // 다른 에러면 그대로 실패 처리
                            single(.failure(error))
                        }
                    }
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    private var currentNonce: String?              // 요청‑응답 매칭용
    private var appleObserver: ((SingleEvent<FirebaseAuth.User>) -> Void)? // Rx 콜백 저장
    
    func signInWithApple(presentingVC: UIViewController) -> Single<FirebaseAuth.User> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                return Disposables.create()
            }
            
            // 1) nonce 생성
            let rawNonce = self.randomNonceString()
            self.currentNonce = rawNonce
            
            // 2) 애플 요청 생성
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(rawNonce)
            
            // 3) 컨트롤러 설정
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
            
            // 4) Rx observer 저장 (delegate에서 호출)
            self.appleObserver = observer
            
            return Disposables.create { self.appleObserver = nil }
        }
    }
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result  = ""
        var remaining = length
        
        while remaining > 0 {
            var random: UInt8 = 0
            guard SecRandomCopyBytes(kSecRandomDefault, 1, &random) == errSecSuccess else {
                fatalError("Unable to generate nonce.")
            }
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }
    
    /// SHA‑256 해시 (hex string)
    func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    
    func logout() -> Single<Void> {
        return Single.create { single in
            let firebaseAuth = Auth.auth()
            
            guard let uid = firebaseAuth.currentUser?.uid else {
                single(.failure(NSError(
                    domain: "LogoutError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "사용자 정보 없음"]
                )))
                return Disposables.create()
            }

            let db = Firestore.firestore()
            let tokensRef = db.collection("tokens").document(uid)
            let usersRef = db.collection("users").document(uid)

            // (1) tokens 문서 삭제
            tokensRef.delete { tokenError in
                if let tokenError = tokenError {
                    print("❌ tokens 문서 삭제 실패: \(tokenError.localizedDescription)")
                } else {
                    print("✅ tokens 문서 삭제 완료")
                }

                // (2) users 문서에서 fcmToken 필드만 삭제
                usersRef.updateData(["fcmToken": FieldValue.delete()]) { userError in
                    if let userError = userError {
                        print("⚠️ users 문서 fcmToken 필드 삭제 실패: \(userError.localizedDescription)")
                    } else {
                        print("✅ users 문서 fcmToken 필드 삭제 완료")
                    }

                    // (3) Firebase 로그아웃 수행
                    do {
                        try firebaseAuth.signOut()
                        single(.success(()))
                    } catch {
                        single(.failure(error))
                    }
                }
            }

            return Disposables.create()
        }
    }

    
    func deleteAccount() -> Single<Void> {
        return Single.create { single in
            /// // 현재 로그인한 유저가 있는지 확인
            if let user = Auth.auth().currentUser {
                // 유저 삭제 요청
                user.delete { error in
                    if let error = error {
                        // 실패 시 에러 반환
                        single(.failure(error))
                    } else {
                        print("탈퇴 성공")
                        // 성공 시 빈 성공 값 반환
                        single(.success(()))
                    }
                }
            } else {
                // 로그인 정보가 없을 경우 커스텀 에러 반환
                let error = NSError(
                    domain: "FirebaseAuth",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "로그인 정보가 존재하지 않습니다."]
                )
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

// MARK: - Apple Delegate & Presentation
extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 최상위 window 반환
        UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
    
    /// 성공
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityTokenData = appleIDCredential.identityToken,
            let idTokenString     = String(data: identityTokenData, encoding: .utf8),
            let rawNonce          = currentNonce
        else {
            appleObserver?(.failure(NSError(domain: "AppleAuth", code: -1)))
            return
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: appleIDCredential.fullName
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error {
                self?.appleObserver?(.failure(error))
            } else if let user = result?.user {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self?.appleObserver?(.success(user))
            } else {
                self?.appleObserver?(.failure(NSError(domain: "FirebaseAuth", code: -2)))
            }
            self?.appleObserver = nil   // clean‑up
        }
    }
    
    /// 실패
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        appleObserver?(.failure(error))
        appleObserver = nil
    }
    
}
