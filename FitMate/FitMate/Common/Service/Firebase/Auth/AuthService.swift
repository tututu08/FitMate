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

final class AuthService {

    static let shared = AuthService()

    private init() {
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
}
