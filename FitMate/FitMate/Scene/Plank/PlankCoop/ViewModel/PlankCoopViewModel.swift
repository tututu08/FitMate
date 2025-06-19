import Foundation
import RxSwift
import RxCocoa

// 플랭크 협력 모드 상태 정의
enum PlankStatus {
    case ready                      // 준비 중 (5초)
    case myTurn                     // 내 차례 (30초)
    case mateTurn                   // 메이트 차례 (30초)
    case paused(isMine: Bool)       // 일시저ㅇ지 (내가/상대가 누름)
    case quitting(isMine: Bool)     // 그만두기 확인 (내가/상대가)
    case finished(success: Bool)    // 종료(성공/실패)
}

final class PlankCoopViewModel: ViewModelType {
    
    struct Input {
        let start: Observable<Void>         // 시작
        let pause: Observable<Void>         // 일시정지(내가)
        let matePause: Observable<Void>     // 일시정지(상대방)
        let resume: Observable<Void>        // 이어하기(내가)
        let mateResume: Observable<Void>    // 이어하기(상대방)
        let quit: Observable<Void>          // 그만두기(내가)
        let mateQuit: Observable<Void>      // 그만두기(상대방)
    }
    
    struct Output {
        let status: Driver<PlankStatus>       // 현재 상태(뷰 상태 변경)
        let timerText: Driver<String>       // 타이머 표시
        let myTimeText: Driver<String>      // 내 누적 기록
        let mateTimeText: Driver<String>    // 메이트 누적 기록
        let progress: Driver<CGFloat>       // 프로그레스바 (0 ~1)
        let didFinish: Signal<Bool>         // 종료 알림(성공/실패)
    }
    
    private let statusRelay = BehaviorRelay<PlankStatus>(value: .ready)
    let timerRelay = BehaviorRelay<Int>(value: 10 )
    private let myTimeRelay = BehaviorRelay<Int>(value: 0)
    private let mateTimeRelay = BehaviorRelay<Int>(value: 0)
    private let didFinishRelay = PublishRelay<Bool>()
    private let disposeBag = DisposeBag()
    private var pauseRemainTime: Int?

    var myTime: Int { myTimeRelay.value }
    var mateTime: Int { mateTimeRelay.value }
    let myCharacter: String
    let mateCharacter: String
    let goalMinutes: Int                // 목표 시간(분 단위)
    private var isMyTurn = true
    private var timer: Timer?
    
    init(goalMinutes: Int ,myCharacter: String, mateCharacter: String) {
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.goalMinutes = goalMinutes
    }
    
    func transform(input: Input) -> Output {
        input.start
            .subscribe(onNext: { [weak self] in self?.startGame() })
            .disposed(by: disposeBag)
        
        input.pause
            .subscribe(onNext: { [weak self] in self?.pause(isMine: true) })
            .disposed(by: disposeBag)
        input.matePause
            .subscribe(onNext: { [weak self] in self?.pause(isMine: false) })
            .disposed(by: disposeBag)
        
        input.resume
            .subscribe(onNext: { [weak self] in self?.resume() })
            .disposed(by: disposeBag)
        input.mateResume
            .subscribe(onNext: { [weak self] in self?.resume() })
            .disposed(by: disposeBag)
        
        input.quit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: true) })
            .disposed(by: disposeBag)
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
            .disposed(by: disposeBag)
        
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
            status: statusRelay.asDriver(onErrorJustReturn: .ready),
            timerText: timerRelay.map { "\($0)" }.asDriver(onErrorJustReturn: "0"),
            myTimeText: myTimeRelay.map { Self.formatTime($0) }.asDriver(onErrorJustReturn: "0초"),
            mateTimeText: mateTimeRelay.map { Self.formatTime($0) }.asDriver(onErrorJustReturn: "0초"),
            progress: progress,
            didFinish: didFinishRelay.asSignal(onErrorJustReturn: false)
        )
    }
    
    private func startGame() {
        statusRelay.accept(.ready)
        timerRelay.accept(5)
        myTimeRelay.accept(0)
        isMyTurn = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let remain = self.timerRelay.value - 1
            if remain > 0 {
                self.timerRelay.accept(remain)
            } else {
                t.invalidate()
                self.startTurn(isMyTurn: true)
            }
        }
    }
    
    private func startTurn(isMyTurn: Bool, resumeTime: Int? = nil) {
        self.isMyTurn = isMyTurn
        statusRelay.accept(isMyTurn ? .myTurn : .mateTurn)
        let seconds = resumeTime ?? 10 // 이어하기면 pauseRemainTime, 새턴이면 30
        timerRelay.accept(seconds)
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let remain = self.timerRelay.value - 1
            if remain >= 0 {
                self.timerRelay.accept(remain)
                if isMyTurn {
                    self.myTimeRelay.accept(self.myTimeRelay.value + 1)
                } else {
                    self.mateTimeRelay.accept(self.mateTimeRelay.value + 1)
                }
            } else {
                t.invalidate()
                let total = self.myTimeRelay.value + self.mateTimeRelay.value
                let goal = self.goalMinutes * 60
                if total >= goal {
                    self.finish(success: true)
                } else {
                    self.startTurn(isMyTurn: !isMyTurn)
                }
            }
        }
    }
    
    private func pause(isMine: Bool) {
        timer?.invalidate()
        pauseRemainTime = timerRelay.value
        statusRelay.accept(.paused(isMine: isMine))
    }
    
    private func resume() {
        timer?.invalidate()
        timerRelay.accept(5)
        statusRelay.accept(.ready)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let remain = self.timerRelay.value - 1
            if remain > 0 {
                self.timerRelay.accept(remain)
            } else {
                t.invalidate()
                self.startTurn(isMyTurn: self.isMyTurn, resumeTime: self.pauseRemainTime)
                self.pauseRemainTime = nil
            }
        }
    }
    
    private func confirmQuit(isMine: Bool) {
        timer?.invalidate()
        statusRelay.accept(.quitting(isMine: isMine))
        finish(success: false)
        // 실제로 완전히 끝내려면 finish(success: false) 호출 필요
    }
    
    func finish(success: Bool) {
        timer?.invalidate()
        statusRelay.accept(.finished(success: success))
        didFinishRelay.accept(success)
    }
    
    static func formatTime(_ seconds: Int) -> String {
        if seconds < 60 { return "\(seconds)초" }
        let min = seconds / 60
        let sec = seconds % 60
        return "\(min)분 \(sec)초"
    }
    
    deinit {
        timer?.invalidate()
    }
}
