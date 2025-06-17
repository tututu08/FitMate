//
//  AppleLoginTestViewController.swift
//  FitMate
//
//  Created by 김은서 on 6/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AuthenticationServices   // Sign in with Apple
import CryptoKit        // SHA‑256 해시 계산
import FirebaseAuth     // Firebase 인증

class AppleLoginTestViewController: UIViewController, ASAuthorizationControllerDelegate {

    // Apple 로그인 버튼
    private let signButton = ASAuthorizationAppleIDButton()
    
    private let disposeBag = DisposeBag()
    
    // Apple 로그인 요청과 응답 매칭을 위한 nonce (임의 문자열)
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white            // 배경을 흰색으로 설정
        view.addSubview(signButton)              // Apple 로그인 버튼 추가
        
        // SnapKit을 이용한 버튼 오토레이아웃 설정
        signButton.snp.makeConstraints {
            $0.center.equalToSuperview()        // 화면 중앙 배치
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
        bind() // 버튼 탭 이벤트 바인딩
    }

    // Apple 로그인 버튼 탭 이벤트 바인딩
    private func bind() {
        // ASAuthorizationAppleIDButton은 UIButton이지만 RxCocoa의 controlEvent로 탭 감지 가능
        signButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                // 로그인 요청 시작
                self?.startSignInWithAppleFlow()
            })
            .disposed(by: disposeBag)
    }

    // 임의 문자열(nonce) 생성 함수 (Firebase가 요구)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // 랜덤 바이트로부터 charset 중 하나를 선택
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    // 문자열을 SHA256 해시로 변환 <- 단방향 암호화 함수
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    // Apple 로그인 요청 시작
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()           // 랜덤 nonce 생성
        currentNonce = nonce                      // 응답 시 비교를 위해 저장
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // 이름, 이메일 요청
        request.nonce = sha256(nonce)             // nonce는 해시 처리해서 넣어야 함

        // 인증 컨트롤러 설정 및 실행
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// Apple 로그인 창을 띄울 때 어느 윈도우에서 띄울지를 지정
extension AppleLoginTestViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension AppleLoginTestViewController {
    // Apple 로그인 성공 시 호출되는 메서드
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // nonce는 반드시 있어야 함
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Apple이 제공한 ID 토큰 (JWT) 받아오기
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            // 토큰 데이터를 문자열로 변환
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            // Firebase용 OAuth credential 생성
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce, // hash 이전의 원본 nonce
                fullName: appleIDCredential.fullName // 이름 (최초 로그인만 전달됨)
            )

            // Firebase Auth 로그인 시도
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    return
                }
                print("Firebase login 성공: \(String(describing: authResult?.user.uid))")
            }
        }
    }

    // Apple 로그인 실패 시 호출
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple 실패: \(error.localizedDescription)")
    }
}
