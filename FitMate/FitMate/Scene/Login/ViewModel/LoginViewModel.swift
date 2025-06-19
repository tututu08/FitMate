//
//  LoginViewModel.swift
//  FitMate
//
//  Created by NH on 6/15/25.
//

import RxSwift
import RxCocoa
import FirebaseAuth
import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import CryptoKit

final class LoginViewModel {
    
    // 화면 이동 목적을 나타내는 enum (분기 판단용)
    enum LoginNavigation {
        case goToMainViewController(uid: String) // 메인 뷰로 이동
        case goToInputMateCode(uid: String)     // 메이트 코드 입력 화면으로 이동
        case goToInputNickName(uid: String)     // 닉네임 입력 화면으로 이동
        case error(String) // 에러 발생 (메시지 전달)
    }
    
    struct Input {
        // ViewModel은 오직 구독만 하고, 발행은 하지 않기 위해서
        let googleLoginTrigger: Observable<Void>
        let kakaoLoginTrigger: Observable<Void>
        let appleLoginTrigger: Observable<Void>
    }
    
    struct Output {
        let navigation: Driver<LoginNavigation>  // 분기/화면 전환 목적 정보
    }
    
    func transform(input: Input, presentingVC: UIViewController) -> Output {
        let gooeleLoginFlow = input.googleLoginTrigger
            .flatMapLatest {
                // 실제 로그인 시도
                AuthService.shared
                    .signInWithGoogle(presentingVC: presentingVC) // single<User> 를 반환
                    .map { Result.success($0) } // 성공시 Result로 래핑 / User → Result<User, Error>로 변환
                    .catch { .just(.failure($0)) } // 실패시 Result.failure로 변환 / catch는 에러를 잡아서, 에러 스트림 대신 Result.failure(error)를 담은 이벤트로 변환
                    .asObservable()
            }
            .flatMapLatest { result -> Observable<LoginNavigation> in
                // 로그인 결과에 따라 Firestore 조회 및 화면 분기
                switch result {
                case .success(let user): // 성공 시, 로그인 사용자 정보를 가져옴
                    let uid = user.uid // uid 정보 저장
                    // Firestore 조회를 Observable로 감쌈
                    return FirestoreService.shared
                        .fetchDocument(collectionName: "users", documentName: uid) // 사용자 문서 검색
                        .flatMap { data -> Single<LoginNavigation> in
                            // 닉네임이 있고
                            if let nickname = data["nickname"] as? String,
                               !nickname.isEmpty {
                                // 메이트가 있으면
                                if let mate = data["hasMate"] as? Bool, mate == true {
                                    // 메인 뷰로 이동
                                    return .just(.goToMainViewController(uid: uid))
                                } else {
                                    // 메이트가 없으면 메이트 등록 화면으로 이동
                                    return .just(.goToInputMateCode(uid: uid))
                                }
                            } else {
                                // 닉네임이 없으면 닉네임 입력 화면으로 이동
                                return .just(.goToInputNickName(uid: uid))
                            }
                        }
                        .catch { _ in // 사용자 문서가 존재하지 않다면
                            return FirestoreService.shared
                                .createUserDocument(uid: uid) // 사용자 uid 로 문서를 생성
                                .map { .goToInputNickName(uid: uid) } // .just(.goToInputNickName(uid: uid)로 반환
                        }
                        .asObservable()
                    
                case .failure(let error): // 로그인 정보를 가져오지 못하면
                    return .just(.error(error.localizedDescription)) // 에러 메시지 출력
                }
            }
        
        let kakaoLoginFlow = input.kakaoLoginTrigger
            .flatMapLatest {
                // 카카오 로그인 먼저 수행 (앱 or 웹)
                Observable<KakaoUser>.create { observer in
                    // 공통적으로 사용할 사용자 정보 요청 함수 정의
                    let handleUserApiMe: () -> Void = {
                        UserApi.shared.me { user, error in
                            if let error = error {
                                observer.onError(error)
                            } else if let user = user {
                                observer.onNext(user)
                                observer.onCompleted()
                            } else {
                                // 예외적으로 user도 error도 없을 경우 에러 처리
                                observer.onError(NSError(
                                    domain: "kakao",
                                    code: -1, // 임의로 NSError 정의
                                    userInfo: [NSLocalizedDescriptionKey: "유저 정보 없음"]
                                ))
                            }
                        }
                    }
                    
                    // 카카오톡 앱이 설치되어 있으면 앱으로 로그인 시도
                    if UserApi.isKakaoTalkLoginAvailable() {
                        UserApi.shared.loginWithKakaoTalk { _, error in
                            if let error = error {
                                print("카카오톡 앱 로그인 실패: \(error)")
                                observer.onError(error)
                            } else {
                                // 로그인 성공하면 사용자 정보 요청
                                handleUserApiMe()
                            }
                        }
                    } else {
                        // 앱이 없으면 웹 브라우저 로그인 시도
                        UserApi.shared.loginWithKakaoAccount { _, error in
                            if let error = error {
                                observer.onError(error)
                                print("카카오톡 웹 로그인 실패: \(error)")
                            } else {
                                handleUserApiMe()
                            }
                        }
                    }
                    
                    return Disposables.create()
                }
            }
            .flatMapLatest { kakaoUser in
                // 받아온 카카오 유저 정보를 이용해서 Firebase 로그인 시도
                AuthService.shared
                    .signInWithKakao(kakaoUser: kakaoUser)
                    .map { Result.success($0) }
                    .catch { .just(.failure($0)) }
                    .asObservable()
            }

        // MARK: - 수정 필요
            .flatMapLatest { result -> Observable<LoginNavigation> in
                // 로그인 결과에 따라 Firestore 조회 및 화면 분기
                switch result {
                case .success(let user): // 성공 시, 로그인 사용자 정보를 가져옴
                    let uid = user.uid // uid 정보 저장
                    // Firestore 조회를 Observable로 감쌈
                    return FirestoreService.shared
                        .fetchDocument(collectionName: "users", documentName: uid) // 사용자 문서 검색
                        .flatMap { data -> Single<LoginNavigation> in
                            // 닉네임이 있고
                            if let nickname = data["nickname"] as? String,
                               !nickname.isEmpty {
                                // 메이트가 있으면
                                if let mate = data["hasMate"] as? Bool, mate == true {
                                    // 메인 뷰로 이동
                                    return .just(.goToMainViewController(uid: uid))
                                } else {
                                    // 메이트가 없으면 메이트 등록 화면으로 이동
                                    return .just(.goToInputMateCode(uid: uid))
                                }
                            } else {
                                // 닉네임이 없으면 닉네임 입력 화면으로 이동
                                return .just(.goToInputNickName(uid: uid))
                            }
                        }
                        .catch { _ in // 사용자 문서가 존재하지 않다면
                            return FirestoreService.shared
                                .createUserDocument(uid: uid) // 사용자 uid 로 문서를 생성
                                .map { .goToInputNickName(uid: uid) } // .just(.goToInputNickName(uid: uid)로 반환
                        }
                        .asObservable()
                    
                case .failure(let error): // 로그인 정보를 가져오지 못하면
                    return .just(.error(error.localizedDescription)) // 에러 메시지 출력
                }
            }
        let appleLoginFlow = input.appleLoginTrigger
            .flatMapLatest {
                AuthService.shared.signInWithApple(presentingVC: presentingVC)
                    .map { Result.success($0) }
                    .catch { .just(.failure($0)) }
                    .asObservable()
            }
            .flatMapLatest { result -> Observable<LoginNavigation> in
                switch result {
                case .success(let user):
                    let uid = user.uid
                    return FirestoreService.shared
                        .fetchDocument(collectionName: "users", documentName: uid)
                        .flatMap { data -> Single<LoginNavigation> in
                            if let nickname = data["nickname"] as? String, !nickname.isEmpty {
                                if let mate = data["hasMate"] as? Bool, mate == true {
                                    return .just(.goToMainViewController(uid: uid))
                                } else {
                                    return .just(.goToInputMateCode(uid: uid))
                                }
                            } else {
                                return .just(.goToInputNickName(uid: uid))
                            }
                        }
                        .catch { _ in
                            FirestoreService.shared
                                .createUserDocument(uid: uid)
                                .map { .goToInputNickName(uid: uid) }
                        }
                        .asObservable()
                case .failure(let error):
                    return .just(.error(error.localizedDescription))
                }
            }
        /// 여러 로그인 플로우를 하나의 Observable로 병합
        /// 둘 중 하나라도 이벤트를 방출하면 mergedFlow에서 이벤트 생성
        let mergedFlow = Observable
            .merge(gooeleLoginFlow, kakaoLoginFlow, appleLoginFlow)
        /// 에러 발생 시 Driver로 변환하면서 기본 에러 처리 로직 지정
            .asDriver(onErrorRecover: { error in
                return Driver.just(.error(error.localizedDescription))
            })
        /// ViewModel의 Output으로 Driver<LoginNavigation>타입의 navigation 이벤트 전달
        return Output(navigation: mergedFlow)
        
    }
}
