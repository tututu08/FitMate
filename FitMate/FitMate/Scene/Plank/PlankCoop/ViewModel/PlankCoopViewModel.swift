import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore

// 플랭크 협동 모드의 각 상태
enum PlankStatus: Equatable {
    case ready                      // 준비 중 (5초 카운트다운)
    case myTurn                     // 내 차례 (30초)
    case mateTurn                   // 메이트 차례 (30초)
    case paused(isMine: Bool)       // 일시정지 (내가/상대가 누름)
    case quitting(isMine: Bool)     // 그만두기 확인 (내가/상대가)
    case finished(success: Bool)    // 종료(성공/실패)
}

// 플랭크 협동 모드 뷰모델 (RxSwift MVVM)
final class PlankCoopViewModel: ViewModelType {
    
    // ViewModel에 입력으로 받는 트리거들 (버튼, 상대방 액션 등)
    struct Input {
        let start: Observable<Void>         // 게임 시작 트리거
        let pause: Observable<Void>         // 내가 일시정지
        let matePause: Observable<Void>     // 상대가 일시정지
        let resume: Observable<Void>        // 내가 이어하기
        let mateResume: Observable<Void>    // 상대가 이어하기
        let quit: Observable<Void>          // 내가 그만두기
        let mateQuit: Observable<Void>      // 상대가 그만두기
    }
    
    // ViewModel이 출력하는 바인딩 값들
    struct Output {
        let status: Driver<PlankStatus>         // 현재 상태
        let timerText: Driver<String>           // 중앙 타이머 텍스트
        let myTimeText: Driver<String>          // 내 누적 시간 텍스트
        let mateTimeText: Driver<String>        // 상대 누적 시간 텍스트
        let progress: Driver<CGFloat>           // 프로그레스바 비율
        let didFinish: Signal<Bool>             // 게임 종료 시(성공/실패)
        let mateQuitEvent: Signal<Void>         // 상대 종료 감지 시
    }
    
    // 프로퍼티들 (게임 진행 상태, 바인딩용 Rx Relay 등)
    private let statusRelay = BehaviorRelay<PlankStatus>(value: .ready)   // 상태 변경
    private let readyDuration = 5     // 준비시간(5초)
    private let turnDuration = 30     // 한 턴(30초)
    let timerRelay = BehaviorRelay<Int>(value: 5)     // 남은 시간 카운트
    private let myTimeRelay = BehaviorRelay<Int>(value: 0)    // 내 누적 시간(초)
    private let mateTimeRelay = BehaviorRelay<Int>(value: 0)  // 상대 누적 시간(초)
    private let didFinishRelay = PublishRelay<Bool>()         // 결과 알림
    private let mateQuitRelay = PublishRelay<Void>()          // 상대 종료 감지
    private let disposeBag = DisposeBag()                     // Rx 메모리 관리
    
    private var pauseRemainTime: Int?         // 일시정지 시 남은 시간 저장
    private var listener: Disposable?         // Firestore 리스너
    private var isListening = false           // 중복 리스닝 방지
    private let isInviter: Bool               // 내가 초대자인지 여부
    
    var myTime: Int { myTimeRelay.value }         // 내 누적 시간(외부 접근용)
    var mateTime: Int { mateTimeRelay.value }     // 상대 누적 시간(외부 접근용)
    
    let myCharacter: String       // 내 캐릭터(아바타)
    let mateCharacter: String     // 상대 캐릭터(아바타)
    let goalMinutes: Int          // 목표 시간(분)
    private let matchCode: String // 경기 코드(Firestore 문서 키)
    private let myUID: String     // 내 유저 UID
    private let mateUID: String   // 상대 유저 UID
    
    private var isMyTurn = true           // 현재 내 턴 여부(플래그)
    private var timer: Timer?             // 실시간 카운트다운 타이머
    private var lastStartAt: Date?        // 마지막 시작 시각(동기화 기준)
    
    // 생성자
    init(
        goalMinutes: Int,
        matchCode: String,
        myUID: String,
        mateUID: String,
        isInviter: Bool,
        myCharacter: String,
        mateCharacter: String
    ) {
        self.goalMinutes = goalMinutes
        self.matchCode = matchCode
        self.myUID = myUID
        self.mateUID = mateUID
        self.isInviter = isInviter
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
    }
    
    // transform (Input → Output)
    func transform(input: Input) -> Output {
        // 게임 시작
        input.start
            .subscribe(onNext: { [weak self] in self?.startGame() })
            .disposed(by: disposeBag)
        
        // 내가 일시정지
        input.pause
            .subscribe(onNext: { [weak self] in self?.pause(isMine: true) })
            .disposed(by: disposeBag)
        // 상대가 일시정지
        input.matePause
            .subscribe(onNext: { [weak self] in self?.pause(isMine: false) })
            .disposed(by: disposeBag)
        
        // 내가 이어하기(재개)
        input.resume
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let now = Date()
                // Firestore에 이어하기 신호 저장
                FirestoreService.shared.resumePlank(matchCode: self.matchCode)
                    .subscribe()
                    .disposed(by: self.disposeBag)
                self.resume(startAt: now)
            })
            .disposed(by: disposeBag)
        // 상대가 이어하기(재개)
        input.mateResume
            .subscribe()
            .disposed(by: disposeBag)
        
        // 내가 그만두기
        input.quit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: true) })
            .disposed(by: disposeBag)
        // 상대가 그만두기
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
            .disposed(by: disposeBag)
        
        // 프로그레스바 비율 계산 (총 진행 시간 / 목표 시간)
        let progress = Observable
            .combineLatest(myTimeRelay, mateTimeRelay)
            .map { [weak self] my, mate in
                guard let self = self else { return CGFloat(0) }
                let total = my + mate
                let goalSec = self.goalMinutes * 60
                return CGFloat(min(1.0, Double(total) / Double(goalSec)))
            }
            .asDriver(onErrorJustReturn: CGFloat(0))
        
        return Output(
            status: statusRelay.asDriver(onErrorJustReturn: .ready),            // 현재 상태
            timerText: timerRelay.map { "\($0)" }.asDriver(onErrorJustReturn: "0"), // 남은 타이머 텍스트
            myTimeText: myTimeRelay.map { Self.formatTime($0) }.asDriver(onErrorJustReturn: "0초"), // 내 시간
            mateTimeText: mateTimeRelay.map { Self.formatTime($0) }.asDriver(onErrorJustReturn: "0초"), // 상대 시간
            progress: progress,                         // 프로그레스 비율
            didFinish: didFinishRelay.asSignal(onErrorJustReturn: false),       // 종료 알림
            mateQuitEvent: mateQuitRelay.asSignal(onErrorJustReturn: ())        // 상대 종료 감지
        )
    }
    
    // Firestore에서 실시간 진행상황 바인딩(내 기록/상대 기록)
    func bindProgressFromFirestore() {
        Observable
            .combineLatest(
                FirestoreService.shared.observeMyProgress(matchCode: matchCode, myUid: myUID),      // 내 기록
                FirestoreService.shared.observeMateProgress(matchCode: matchCode, mateUid: mateUID) // 상대 기록
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] my, mate in
                guard let self else { return }
                self.myTimeRelay.accept(Int(my))
                self.mateTimeRelay.accept(Int(mate))
                // 목표 시간 달성 시 성공 처리
                let total = Int(my) + Int(mate)
                if total >= self.goalMinutes * 60 {
                    self.finish(success: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // Firestore의 match 상태 리스너(턴, 일시정지, 상대 종료 등)
    func bindMatchStatus() {
        guard !isListening else { return }
        isListening = true
        listener = FirestoreService.shared.listenToMatchStatus(matchCode: matchCode)
            .subscribe(onNext: { [weak self] data in
                guard let self else { return }
                // Firestore match 문서에서 필요한 값 추출
                guard let ts = data["timerStartAt"] as? Timestamp,
                      let turn = data["turn"] as? String else { return }
                let startAt = ts.dateValue()
                let paused = data["paused"] as? Bool ?? false
                let myTurn = self.isInviter ? (turn == "my") : (turn == "mate")
                
                // 최초 진입 (혹은 세션 새로 시작)
                if self.lastStartAt == nil {
                    self.lastStartAt = startAt
                    self.isMyTurn = myTurn
                    if paused {
                        self.pause(isMine: false)
                    } else {
                        self.resume(startAt: startAt)
                    }
                }
                // 일시정지 상태 변화 감지 (내가 누른게 아니어도 실시간 반영)
                else if paused && !(self.statusRelay.value == .paused(isMine: false) || self.statusRelay.value == .paused(isMine: true)) {
                    self.pause(isMine: false)
                }
                // 일시정지 → 해제(재개) 신호 감지
                else if !paused && (self.statusRelay.value == .paused(isMine: false) || self.statusRelay.value == .paused(isMine: true)) {
                    self.resume(startAt: startAt)
                }
                // 턴 전환 감지(준비 없이 바로 다음 턴)
                else if self.isMyTurn != myTurn {
                    self.isMyTurn = myTurn
                    self.startTurn(isMyTurn: myTurn)
                }
                // 상대 종료 감지
                if let quitMap = data["quitStatus"] as? [String: Bool],
                   quitMap[self.mateUID] == true {
                    self.mateQuitRelay.accept(())
                }
            })
    }
    
    // 상대방이 종료했는지 실시간 감지
    func bindMateQuitListener() {
        FirestoreService.shared.listenMateQuitStatus(matchCode: matchCode, myUid: myUID)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] didQuit in
                guard didQuit else { return }
                self?.mateQuitRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    // 게임 시작 (처음 1회만!)
    private func startGame() {
        statusRelay.accept(.ready)
        timerRelay.accept(readyDuration)
        myTimeRelay.accept(0)
        isMyTurn = isInviter
        // 초대자만 Firestore에서 게임 세션 초기화
        if isInviter {
            FirestoreService.shared.startPlankSession(matchCode: matchCode, isMyTurn: true)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    // 내 턴/상대 턴 시작(타이머 작동)
    private func startTurn(isMyTurn: Bool, remainSeconds: Int? = nil) {
        timer?.invalidate()
        // 준비 단계 없이 바로 턴 시작
        let totalRemain = goalMinutes * 60 - myTimeRelay.value - mateTimeRelay.value
        let seconds = min(remainSeconds ?? turnDuration, totalRemain)
        timerRelay.accept(seconds)
        statusRelay.accept(isMyTurn ? .myTurn : .mateTurn)
        // 1초마다 남은 시간 감소(0되면 턴 종료)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let remain = self.timerRelay.value - 1
            if remain >= 0 {
                self.timerRelay.accept(remain)
                if isMyTurn {
                    // 내 턴일 때 내 기록 Firestore에 push
                    self.myTimeRelay.accept(self.myTimeRelay.value + 1)
                    FirestoreService.shared.updatePlankProgress(
                        matchCode: self.matchCode,
                        uid: self.myUID,
                        progress: self.myTimeRelay.value
                    )
                    .subscribe()
                    .disposed(by: self.disposeBag)
                } else {
                    // 상대 턴일 때는 내 기록 X
                    self.mateTimeRelay.accept(self.mateTimeRelay.value + 1)
                }
            } else {
                t.invalidate()
                // 턴이 끝났을 때 목표 달성하면 종료
                let total = self.myTimeRelay.value + self.mateTimeRelay.value
                let goal = self.goalMinutes * 60
                if total >= goal {
                    self.finish(success: true)
                } else {
                    // 턴 넘김 (Firestore의 turn 값 변경)
                    // 내 턴이 끝났을 때만 다음 턴으로 넘김
                    if isMyTurn {
                        // Firestore에는 초대자 기준으로 다음 턴을 저장
                        let nextTurnIsMy = !self.isInviter
                        FirestoreService.shared.updatePlankTurn(
                            matchCode: self.matchCode,
                            isMyTurn: nextTurnIsMy
                        )
                        .subscribe()
                        .disposed(by: self.disposeBag)
                        self.pauseRemainTime = nil
                        // 준비(ready) 단계 없음!
                    }
                }
            }
        }
    }
    
    // (일시정지 →) 재개 시 타이머/상태 복구
    private func resume(startAt: Date) {
        timer?.invalidate()
        timerRelay.accept(readyDuration)
        statusRelay.accept(.ready)
        lastStartAt = startAt
        // 5초 카운트다운 후 바로 내 턴/상대 턴 진입
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let remain = self.timerRelay.value - 1
            if remain > 0 {
                self.timerRelay.accept(remain)
            } else {
                t.invalidate()
                self.startTurn(isMyTurn: self.isMyTurn, remainSeconds: self.pauseRemainTime)
                self.pauseRemainTime = nil
            }
        }
    }
    
    // 일시정지 처리 (타이머 멈춤, 상태 갱신)
    private func pause(isMine: Bool) {
        timer?.invalidate()
        pauseRemainTime = timerRelay.value
        statusRelay.accept(.paused(isMine: isMine))
        // 내가 누르면 Firestore에도 반영
        if isMine {
            FirestoreService.shared.pausePlank(matchCode: matchCode)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    // 종료(그만두기) 처리
    private func confirmQuit(isMine: Bool) {
        timer?.invalidate()
        statusRelay.accept(.quitting(isMine: isMine))
        if isMine {
            // Firestore에 quitStatus 업데이트(내가 먼저 그만둘 때만)
            FirestoreService.shared.updateMyQuitStatus(matchCode: matchCode, uid: myUID)
                .subscribe(onCompleted: {
                    print("quitStatus Firestore에 저장 완료")
                }, onError: { error in
                    print("quitStatus Firestore 저장 실패: \(error)")
                })
                .disposed(by: disposeBag)
        }
        finish(success: false)
    }
    
    // 게임 종료 처리(성공/실패)
    func finish(success: Bool) {
        timer?.invalidate()
        statusRelay.accept(.finished(success: success))
        didFinishRelay.accept(success)
    }
    
    // 초/분 포맷 변호ㅏㄴ
    static func formatTime(_ seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)초" }
        let min = seconds / 60
        let sec = seconds % 60
        return "\(min)분 \(sec)초"
    }
    
    // 메모리 누수 방지
    deinit { timer?.invalidate(); listener?.dispose() }
}
