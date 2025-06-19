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

/// 사용자에게 표시할 알림 종류 정의
enum AlertType {
    case inviteSent(String) // "OOO님에게 초대가 전송되었습니다."
    case requestFailed(String)
}

/// 화면 전환 목적 정의
enum Navigation {
    case backTo // 이전 화면으로 돌아가기
}

/// 메이트 코드 입력 화면의 ViewModel
class MateCodeViewModel {
    
    // MARK: - Input / Output
    /// ViewController → ViewModel로 전달되는 입력 값들
    struct Input {
        let enteredCode: Observable<String> // 사용자가 입력한 초대 코드
        let completeTap: Observable<Void> // '입력 완료' 버튼 탭 이벤트
    }
    
    /// ViewModel → ViewController로 전달되는 처리 결과
    struct Output {
        let result: Driver<(AlertType?, Navigation?)> // 알림 및 화면 전환 정보
        let buttonActivated: Driver<Bool> // 버튼 활성화 여부
    }
    
    // MARK: - Properties
    private let uid: String // 현재 사용자 uid (의존성 주입)
    private let firestoreService = FirestoreService.shared // Firestore 데이터 처리 서비스 (싱글톤)
    private let disposeBag = DisposeBag() // 메모리 관리를 위한 DisposeBag
    
    // MARK: - Init
    init(uid: String) {
        self.uid = uid
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        /// 입력 필드에 문자열이 존재할 때만 버튼을 활성화하도록 처리
        let buttonActivated = input.enteredCode
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } // 공백만 있으면 false
            .distinctUntilChanged() // 동일한 값은 무시
            .asDriver(onErrorJustReturn: false) // 에러 발생 시 비활성화 처리
        
        /// '입력 완료' 버튼이 눌렸을 때 가장 최신 코드 값을 가져와서 처리
        let result = input.completeTap
            .withLatestFrom(input.enteredCode) // 버튼 누를 시점의 입력값 사용
            .flatMapLatest { [weak self] code -> Observable<(AlertType?, Navigation?)> in
                // ViewModel이 해제되었을 경우 에러 처리
                guard let self = self else {
                    return Observable.just((.requestFailed("사용자 인증 실패"), nil))
                }

                // 입력한 초대 코드로 Firestore에서 해당 유저 문서 조회
                return self.firestoreService
                    .fetchUserByInviteCode(code)
                    .flatMap { inviterData -> Single<(AlertType?, Navigation?)> in
                        // 조회된 데이터에서 uid, nickname 추출
                        guard let inviterUid = inviterData["uid"] as? String,
                              let inviterNickname = inviterData["nickname"] as? String else {
                            return .just((.requestFailed("올바르지 않은 사용자 정보입니다"), nil))
                        }

                        // 해당 사용자의 문서에 초대 상태, 보낸 사람 UID 업데이트
                        let fields: [String: Any] = [
                            "fromUid": self.uid,
                            "inviteStatus": "invited",
                            "updatedAt": FieldValue.serverTimestamp()
                        ]

                        // 문서 업데이트 성공 시 알림 + 화면 뒤로 이동 신호 반환
                        return self.firestoreService
                            .updateDocument(collectionName: "users", documentName: inviterUid, fields: fields)
                            .map { (.inviteSent(inviterNickname), .backTo) }
                    }
                    .asObservable()
                    .catch { error in
                        // 에러 발생 시 실패 알림 반환
                        return Observable.just((.requestFailed(error.localizedDescription), nil))
                    }
            }
            .asDriver(onErrorRecover: { error in
                // 예상치 못한 오류에도 안전하게 처리
                return Driver.just((.requestFailed(error.localizedDescription), nil))
            })

        // Output으로 전달
        return Output(
            result: result,
            buttonActivated: buttonActivated
        )
    }
}
