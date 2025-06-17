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
            inviteCode: inviteCodeRelay.asDriver()
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
                  let status = data["inviteStatus"] as? String,
                  status == "invited",
                  let fromUid = data["fromUid"] as? String else {
                return
            }
            
            self.firestoreService.fetchDocument(collectionName: "users", documentName: fromUid)
                .subscribe(onSuccess: { doc in
                    let nickname = doc["nickname"] as? String ?? "상대방"
                    self.inviteAlertRelay.accept(nickname)
                })
                .disposed(by: self.disposeBag)
        }
    }

    // MARK: - Actions
    func acceptInvite(fromUid: String) -> Completable {
        let updateMyDoc = firestoreService.updateDocument(collectionName: "users", documentName: uid, fields: [
            "inviteStatus": "accepted",
            "mate": ["uid": fromUid, "nickname": "상대방"],
            "updatedAt": FieldValue.serverTimestamp()
        ])
        
        let updateOtherDoc = firestoreService.updateDocument(collectionName: "users", documentName: fromUid, fields: [
            "inviteStatus": "accepted",
            "mate": ["uid": uid, "nickname": nickname],
            "updatedAt": FieldValue.serverTimestamp()
        ])
        
        return Completable.zip(updateMyDoc.asCompletable(), updateOtherDoc.asCompletable())
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

// MARK: - 수정 전
//import UIKit
//import RxSwift
//import RxCocoa
//
//class CodeShareViewModel {
//    
//    private let copyRelay = BehaviorRelay<String>(value: "")
//    private let copyTapRelay = PublishRelay<Void>()
//    private let alertRelay = PublishRelay<SystemAlertType>()
//    
//    let uid: String
//    
//    init(uid: String) {
//        self.uid = uid
//    }
//    
//    var disposeBag = DisposeBag()
//    
//    struct Input {
//        let copyTab: Observable<Void>
//    }
//    
//    struct Output {
//        let copiedText: Observable<String>
//        let showAlert: Driver<SystemAlertType>
//    }
//    
//    /// 외부에서 전달받은 코드를 내부 relay로 전달
//    func setCode(_ code: String) {
//        copyRelay.accept(code)
//    }
//    
//    func transform(input: Input) -> Output {
//        FirestoreService.shared
//            .fetchDocument(collectionName: "codes", documentName: "mateCode")
//        // 가져온 Document에서 "value" 필드를 꺼내 String으로 변환
//            .map { $0["value"] as? String ?? "" }
//            .subscribe(onSuccess: { [weak self] code in
//                // 성공적으로 값을 받아오면 setCode 메서드를 통해 relay에 저장
//                self?.setCode(code)
//            }, onFailure: { error in
//                print("Firestore fetch error: \(error.localizedDescription)")
//            })
//            .disposed(by: disposeBag)
//        
//        // 복사 버튼
//        input.copyTab
//            .withLatestFrom(copyRelay)
//            .do(onNext: { code in
//                UIPasteboard.general.string = code
//            })
//            .map { _ in
//                SystemAlertType.copied
//            }
//            .bind(to: alertRelay)
//            .disposed(by: disposeBag)
//        
//        return Output(
//            copiedText: copyRelay.asObservable(),
//            showAlert: alertRelay.asDriver(onErrorDriveWith: .empty())
//        )
//    }
//}
