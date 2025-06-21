//
//  MainViewModel.swift
//  FitMate
//
//  Created by NH on 6/16/25.
//
import RxSwift
import RxCocoa
import FirebaseFirestore

class MainViewModel {
    
    private let uid: String // 현재 로그인한 사용자 UID
    private let disposeBag = DisposeBag() // 메모리 관리용 disposeBag
    
    // 사용자 상호작용에 따른 이벤트 전달용 Relay
    private let hasNoMateRelay = PublishRelay<Void>() // 메이트가 없을 때
    private let moveToExerciseRelay = PublishRelay<Void>() // 메이트가 있을 때
    private let moveToMatePageRelay =  PublishRelay<String>()
    
    // 운동 초대 이벤트: MatchEventService에서 공유되는 relay 사용
    private let matchEventRelay = MatchEventService.shared.matchEventRelay
   
    let showMateDisconnectedAlert = PublishRelay<Void>() // 메이트 끊김
    let showMateWithdrawnAlert = PublishRelay<Void>() // 메이트 회원 탈퇴
    private var listener: ListenerRegistration? // 메이트 끊김 리스너
    
    
    /// UID 주입을 통해 사용자 정보 가져오기
    init(uid: String) {
        self.uid = uid
        listenToMateDisconnection()
    }
    
    private func listenToMateDisconnection() {
        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let data = snapshot?.data(),
                      error == nil else { return }
                
                let status = data["inviteStatus"] as? String
                
                switch status {
                case "disconnectedByMate":
                    self.showMateDisconnectedAlert.accept(())
                case "disconnectedByWithdrawal":
                    self.showMateWithdrawnAlert.accept(())
                default:
                    break
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
    
    /// 사용자 상호작용 입력 정의
    struct Input {
        let exerciseTap: Observable<Void> // 운동 버튼 탭
        let mateAvatarTap: Observable<Void> // 메이트 아바타 탭
    }
    
    /// 뷰로 전달되는 출력 이벤트 정의
    struct Output {
        let hasNoMate: Driver<Void> // 메이트 없을 때 alert 띄움
        let moveToExercise: Driver<Void> // 메이트 있을 때 운동 선택 화면 이동
        let showMatchEvent: Driver<String> // 운동 초대 이벤트 수신
        let moveToMatePage: Driver<String>// 메이트 uid 전달
        let showMateDisconnected: Driver<Void>      // 끊긴 경우
        let showMateWithdrawn: Driver<Void>         // 탈퇴한 경우
    }
    
    /// 사용자의 상호작용(Input)을 받아서 이벤트(Output)로 변환
    func transform(input: Input) -> Output {
        
        // 운동 버튼을 탭했을 때 → Firestore에서 hasMate 값을 조회
        input.exerciseTap
            .flatMapLatest { [weak self] _ -> Single<Bool> in
                guard let self else { return .just(false) }
                return FirestoreService.shared
                    .fetchDocument(collectionName: "users", documentName: self.uid)
                    .map { document in
                        // hasMate가 없으면 false 처리
                        document["hasMate"] as? Bool ?? false
                    }
            }
            .subscribe(onNext: { [weak self] hasMate in
                // 메이트 여부에 따라 분기 처리
                if hasMate {
                    self?.moveToExerciseRelay.accept(())
                } else {
                    self?.hasNoMateRelay.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.mateAvatarTap
            .flatMapLatest { [weak self] _ -> Single<String?> in
                   guard let self else { return .just(nil) }
                   return FirestoreService.shared
                       .fetchDocument(collectionName: "users", documentName: self.uid)
                       .map { document in
                           let mate = document["mate"] as? [String: Any]
                           return mate?["uid"] as? String
                       }
               }
            .subscribe(onNext: { [weak self] mateUid in
                guard let self, let mateUid else { return }
                self.moveToMatePageRelay.accept(mateUid)
            })
            .disposed(by: disposeBag)

        // Output: Driver로 변환하여 뷰에 전달
        let hasNoMate = hasNoMateRelay.asDriver(onErrorDriveWith: .empty())
        let moveToExercise = moveToExerciseRelay.asDriver(onErrorDriveWith: .empty())
        let showMatchEvent = matchEventRelay.asDriver(onErrorDriveWith: .empty())
        let moveToMatePage = moveToMatePageRelay.asDriver(onErrorDriveWith: .empty())
        let showMateDisconnected = showMateDisconnectedAlert.asDriver(onErrorDriveWith: .empty())
        let showMateWithdrawn = showMateWithdrawnAlert.asDriver(onErrorDriveWith: .empty())
        return Output(
            hasNoMate: hasNoMate,
            moveToExercise: moveToExercise,
            showMatchEvent: showMatchEvent,
            moveToMatePage: moveToMatePage,
            showMateDisconnected: showMateDisconnected,
            showMateWithdrawn: showMateWithdrawn
        )
    }
}

