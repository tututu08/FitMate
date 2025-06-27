//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

/// 메이트 초대 코드 공유 화면의 ViewModel (MVVM + RxSwift 적용)
final class CodeShareViewModel: ViewModelType {

    // MARK: - Input / Output 정의

    /// ViewController로부터 입력받는 사용자 인터랙션
    struct Input {
        let copyTap: Observable<Void>          // 초대 코드 복사 버튼 탭
        let mateCodeTap: Observable<Void>      // 메이트 코드 입력 버튼 탭
        let closeTap: Observable<Void>         // 닫기(X) 버튼 탭
    }

    /// ViewModel이 출력하는 이벤트/상태 스트림
    struct Output {
        let copiedMessage: Driver<String>      // 복사 완료 토스트 메시지
        let navigateToMateCode: Driver<Void>   // 메이트 코드 입력 화면으로 전환
        let dismiss: Driver<Void>              // 현재 화면 종료
        let showInviteAlert: Signal<String>    // 상대방으로부터 초대 요청 받음 Alert
        let inviteCode: Driver<String>         // 현재 사용자 초대 코드
        let transitionToMain: Signal<Void>     // 매칭 완료 시 TabBarController로 전환
        let rejectionAlert: Signal<String>
    }

    // MARK: - Properties

    private let uid: String                                // 현재 사용자 uid
    private let firestoreService = FirestoreService.shared // Firestore CRUD 처리 서비스
    private let db = Firestore.firestore()                 // Firestore 인스턴스
    private let disposeBag = DisposeBag()                  // 메모리 해제용 DisposeBag

    private let inviteAlertRelay = PublishRelay<String>()  // 초대 알림 Signal용
    private let inviteCodeRelay = BehaviorRelay<String>(value: "") // 현재 사용자 초대 코드
    private var nickname: String = ""                      // 현재 사용자 닉네임 저장
    private var listener: ListenerRegistration?            // Firestore 실시간 리스너 핸들러
    private let acceptanceRelay = PublishRelay<Void>()     // 매칭 완료 시 화면 전환 Trigger
    private let rejectionAlertRelay = PublishRelay<String>()

    var rejectionAlert: Signal<String> {
        return rejectionAlertRelay.asSignal()
    }
    
    var acceptanceDetected: Signal<Void> {
        return acceptanceRelay.asSignal()
    }

    // MARK: - 초기화
    init(uid: String) {
        self.uid = uid
        fetchMyUserInfo()             // Firestore에서 내 정보 불러오기 (닉네임, 초대코드)
        startListeningInviteStatus()  // inviteStatus 상태 변화 실시간 감지
    }

    func setNickname(_ name: String) {
        self.nickname = name
    }

    // MARK: - Transform (Input → Output)
    func transform(input: Input) -> Output {
        // 1. 초대 코드 복사
        let copiedMessage = input.copyTap
            .map { [weak self] in
                guard let self else { return "복사 실패"}
                UIPasteboard.general.string = self.inviteCodeRelay.value
                return "초대 코드가 복사되었습니다"
            }
            .asDriver(onErrorJustReturn: "복사 실패")

        // 2. 메이트 코드 입력 화면으로 전환
        let navigateToMateCode = input.mateCodeTap
            .asDriver(onErrorJustReturn: ())

        // 3. 현재 화면 닫기
        let dismiss = input.closeTap
            .asDriver(onErrorJustReturn: ())

        return Output(
            copiedMessage: copiedMessage,
            navigateToMateCode: navigateToMateCode,
            dismiss: dismiss,
            showInviteAlert: inviteAlertRelay.asSignal(),
            inviteCode: inviteCodeRelay.asDriver(),
            transitionToMain: acceptanceDetected,
            rejectionAlert: rejectionAlert
        )
    }

    // MARK: - 사용자 정보 불러오기 (초기 진입 시)
    private func fetchMyUserInfo() {
        firestoreService.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(onSuccess: { [weak self] data in
                self?.nickname = data["nickname"] as? String ?? "알 수 없음"
                let code = data["inviteCode"] as? String ?? "------"
                
                self?.inviteCodeRelay.accept(code)
            }, onFailure: { error in
                print("유저 정보 가져오기 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 초대 상태 감지 (실시간)
    private func startListeningInviteStatus() {
        let ref = db.collection("users").document(uid)

        listener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let status = data["inviteStatus"] as? String else {
                return
            }

            // 상대방이 내 초대코드 입력 → invited 상태
            if status == "invited", let fromUid = data["fromUid"] as? String {
                self.firestoreService.fetchDocument(collectionName: "users", documentName: fromUid)
                    .subscribe(onSuccess: { doc in
                        let nickname = doc["nickname"] as? String ?? "상대방"
                        self.inviteAlertRelay.accept(nickname)
                    })
                    .disposed(by: self.disposeBag)
            }

            // 상대방이 수락 완료 → accepted 상태
            if status == "accepted" {
                self.acceptanceRelay.accept(())
            }
            
            // 상대방이 초대를 거절함 → rejected 상태
            if status == "rejected" {
                rejectionAlertRelay.accept("상대방이 메이트 요청을 거절했습니다.")
            }
        }
    }

    // MARK: - 초대 수락 처리 (양방향 업데이트)
    /// 상대방 uid를 기반으로 내 문서와 상대방 문서 모두 업데이트
    func acceptInvite(fromUid: String) -> Completable {
        return firestoreService.fetchDocument(collectionName: "users", documentName: fromUid)
            .flatMapCompletable { [weak self] data in
                guard let self = self else {
                    return .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "self 해제됨"]))
                }

                let opponentNickname = data["nickname"] as? String ?? "상대방"

                // 내 문서 업데이트
                let todayString = FirestoreService.dateFormatter.string(from: Date())

                let updateMyDoc = self.firestoreService.updateDocument(
                    collectionName: "users", documentName: self.uid, fields: [
                    "inviteStatus": "accepted",
                    "mate": [
                        "uid": fromUid,
                        "nickname": opponentNickname,
                        "startDate": todayString   // D-Day(연결일) 저장
                    ],
                    "hasMate": true,
                    "updatedAt": FieldValue.serverTimestamp()
                ])

                let updateOtherDoc = self.firestoreService.updateDocument(
                    collectionName: "users", documentName: fromUid, fields: [
                    "inviteStatus": "accepted",
                    "mate": [
                        "uid": self.uid,
                        "nickname": self.nickname,
                        "startDate": todayString   // 상대 문서에도 저장
                    ],
                    "hasMate": true,
                    "updatedAt": FieldValue.serverTimestamp()
                ])

                return Completable.zip(
                    updateMyDoc.asCompletable(),
                    updateOtherDoc.asCompletable()
                )
            }
    }

    // MARK: - 초대 거절 처리
    func rejectInvite() -> Completable {
        return firestoreService.fetchDocument(collectionName: "users", documentName: uid)
            .flatMapCompletable { [weak self] data in
                guard let self = self else { return .empty() }
                guard let fromUid = data["fromUid"] as? String else { return .empty() }

                // 내 문서 초기화
                let resetMyDoc = self.firestoreService.updateDocument(collectionName: "users", documentName: self.uid, fields: [
                    "fromUid": FieldValue.delete(),
                    "inviteStatus": "waiting",
                    "updatedAt": FieldValue.serverTimestamp()
                ])

                // 상대방 문서 → rejected 상태로 업데이트
                let updateSenderDoc = self.firestoreService.updateDocument(collectionName: "users", documentName: fromUid, fields: [
                    "inviteStatus": "rejected",
                    "updatedAt": FieldValue.serverTimestamp()
                ])

                return Completable.zip(resetMyDoc.asCompletable(), updateSenderDoc.asCompletable())
            }
    }

    // MARK: - 실시간 리스너 종료 (화면 전환 시)
    func stopListening() {
        listener?.remove()
    }
}
