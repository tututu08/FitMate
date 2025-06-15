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

final class LoginViewModel {
    
    // 화면 이동 목적을 나타내는 enum (분기 판단용)
    enum LoginNavigation {
        case goToSeleteSport(uid: String) // 레디룸으로 이동
        case error(String) // 에러 발생 (메시지 전달)
    }

    struct Input {
        // ViewModel은 오직 구독만 하고, 발행은 하지 않기 위해서
        let googleLoginTrigger: Observable<Void>
    }
    
    struct Output {
        let navigation: Driver<LoginNavigation>  // 분기/화면 전환 목적 정보
    }

    func transform(input: Input, presentingVC: UIViewController) -> Output {
        let navigation = input.googleLoginTrigger
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
                            return .just(.goToSeleteSport(uid: uid)) // 사용자 문서가 존재하면 .just(.goToSeleteSport(uid: uid)로 반환
                        }
                        .catch { _ in // 사용자 문서가 존재하지 않다면
                            return FirestoreService.shared
                                .createUserDocument(uid: uid) // 사용자 uid 로 문서를 생성
                                .map { .goToSeleteSport(uid: uid) } // .just(.goToSeleteSport(uid: uid)로 반환
                        }
                        .asObservable()

                case .failure(let error): // 로그인 정보를 가져오지 못하면
                    return .just(.error(error.localizedDescription)) // 에러 메시지 출력
                }
            }
            .asDriver(onErrorJustReturn: .error("알 수 없는 에러"))

        return Output(navigation: navigation)
    }
}
