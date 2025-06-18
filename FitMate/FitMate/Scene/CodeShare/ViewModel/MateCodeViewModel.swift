//
//  MateCodeViewModel.swift
//  FitMate
//
//  Created by soophie on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

enum AlertType {
    case inviteSent(String) // "OOO님에게 초대가 전송되었습니다."
    case requestFailed(String)
}

enum Navigation {
    case backTo
}

class MateCodeViewModel {
    
    // MARK: - Input / Output
    struct Input {
        let enteredCode: Observable<String>
        let completeTap: Observable<Void>
    }
    
    struct Output {
        let result: Driver<(AlertType?, Navigation?)>
    }
    
    // MARK: - Properties
    private let uid: String // 현재 사용자 uid (의존성 주입)
    private let firestoreService = FirestoreService.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(uid: String) {
        self.uid = uid
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let result = input.completeTap
            .withLatestFrom(input.enteredCode)
            .flatMapLatest { [weak self] code -> Observable<(AlertType?, Navigation?)> in
                guard let self = self else {
                    return Observable.just((.requestFailed("사용자 인증 실패"), nil))
                }

                return self.firestoreService
                    .fetchUserByInviteCode(code)
                    .flatMap { inviterData -> Single<(AlertType?, Navigation?)> in
                        guard let inviterUid = inviterData["uid"] as? String,
                              let inviterNickname = inviterData["nickname"] as? String else {
                            return .just((.requestFailed("올바르지 않은 사용자 정보입니다"), nil))
                        }

                        let fields: [String: Any] = [
                            "fromUid": self.uid,
                            "inviteStatus": "invited",
                            "updatedAt": FieldValue.serverTimestamp()
                        ]

                        return self.firestoreService
                            .updateDocument(collectionName: "users", documentName: inviterUid, fields: fields)
                            .map { (.inviteSent(inviterNickname), .backTo) }
                    }
                    .asObservable()
                    .catch { error in
                        return Observable.just((.requestFailed(error.localizedDescription), nil))
                    }
            }
            .asDriver(onErrorRecover: { error in
                return Driver.just((.requestFailed(error.localizedDescription), nil))
            })

        return Output(result: result)
    }
}
