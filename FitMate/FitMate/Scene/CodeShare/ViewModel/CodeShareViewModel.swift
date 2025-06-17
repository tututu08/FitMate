//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

final class CodeShareViewModel: ViewModelType {
    
    // MARK: - Input / Output
    struct Input {
        let copyTap: Observable<Void>
        let mateCodeTap: Observable<Void>
        let closeTap: Observable<Void>
    }

    struct Output {
        let copiedMessage: Driver<String>
        let navigateToMateCode: Driver<Void>
        let dismiss: Driver<Void>
        let showInviteAlert: Signal<String>
        let inviteCode: Driver<String>
        let transitionToMain: Signal<Void>
    }

    // MARK: - Properties
    private let uid: String
    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    private let inviteAlertRelay = PublishRelay<String>()
    private let inviteCodeRelay = BehaviorRelay<String>(value: "")
    private var nickname: String = ""
    private var listener: ListenerRegistration?
    private let acceptanceRelay = PublishRelay<Void>()

    var acceptanceDetected: Signal<Void> {
        return acceptanceRelay.asSignal()
    }
    
    init(uid: String) {
        self.uid = uid
        fetchMyUserInfo()
        startListeningInviteStatus()
    }
    
    func setNickname(_ name: String) {
        self.nickname = name
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        // 1. 복사 버튼 탭
        let copiedMessage = input.copyTap
            .map { [weak self] in
                guard let self else { return "복사 실패"}
                UIPasteboard.general.string = self.inviteCodeRelay.value
                return "초대 코드가 복사되었습니다"
            }
            .asDriver(onErrorJustReturn: "복사 실패")

        // 2. 화면 전환
        let navigateToMateCode = input.mateCodeTap
            .asDriver(onErrorJustReturn: ())

        // 3. 닫기
        let dismiss = input.closeTap
            .asDriver(onErrorJustReturn: ())

        return Output(
            copiedMessage: copiedMessage,
            navigateToMateCode: navigateToMateCode,
            dismiss: dismiss,
            showInviteAlert: inviteAlertRelay.asSignal(),
            inviteCode: inviteCodeRelay.asDriver(),
            transitionToMain: acceptanceDetected
        )
    }
    
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

    // MARK: - Listen for Invite
    private func startListeningInviteStatus() {
        let ref = db.collection("users").document(uid)

        listener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  let status = data["inviteStatus"] as? String else {
                return
            }

            if status == "invited", let fromUid = data["fromUid"] as? String {
                self.firestoreService.fetchDocument(collectionName: "users", documentName: fromUid)
                    .subscribe(onSuccess: { doc in
                        let nickname = doc["nickname"] as? String ?? "상대방"
                        self.inviteAlertRelay.accept(nickname)
                    })
                    .disposed(by: self.disposeBag)
            }

            if status == "accepted" {
                self.acceptanceRelay.accept(())
            }
        }
    }

    // MARK: - Actions
    func acceptInvite(fromUid: String) -> Completable {
        // Step 1: 먼저 상대방의 사용자 문서를 가져와야 함
        return firestoreService.fetchDocument(collectionName: "users", documentName: fromUid)
            .flatMapCompletable { [weak self] data in
                guard let self = self else {
                    return .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "self 해제됨"]))
                }
                
                let opponentNickname = data["nickname"] as? String ?? "상대방"
                
                // 내 문서 업데이트 (상대방 uid, 닉네임 포함)
                let updateMyDoc = self.firestoreService.updateDocument(collectionName: "users", documentName: self.uid, fields: [
                    "inviteStatus": "accepted",
                    "mate": [
                        "uid": fromUid,
                        "nickname": opponentNickname
                    ],
                    "hasMate": true,
                    "updatedAt": FieldValue.serverTimestamp()
                ])
                
                // 상대방 문서 업데이트 (나의 uid, 닉네임 포함)
                let updateOtherDoc = self.firestoreService.updateDocument(collectionName: "users", documentName: fromUid, fields: [
                    "inviteStatus": "accepted",
                    "mate": [
                        "uid": self.uid,
                        "nickname": self.nickname
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
    
    func rejectInvite() -> Completable {
        return firestoreService.updateDocument(collectionName: "users", documentName: uid, fields: [
            "fromUid": FieldValue.delete(),
            "inviteStatus": "waiting",
            "updatedAt": FieldValue.serverTimestamp()
        ]).asCompletable()
    }
    
    func stopListening() {
        listener?.remove()
    }
}
