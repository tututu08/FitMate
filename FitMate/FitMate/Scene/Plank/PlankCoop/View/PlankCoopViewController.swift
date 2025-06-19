import UIKit
import RxSwift
import RxCocoa

final class PlankCoopViewController: BaseViewController {
    
    // 메인 뷰
    private let sportsView = PlankCoopView()
    private let viewModel: PlankCoopViewModel
    
    // 입력 이벤트용 Relay
    private let startRelay = PublishRelay<Void>()
    private let pauseRelay = PublishRelay<Void>()
    private let resumeRelay = PublishRelay<Void>()
    private let quitRelay = PublishRelay<Void>()
    private let matePauseRelay = PublishRelay<Void>()
    private let mateResumeRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()
    private let myCharacter: String
    private let mateCharacter: String
    private let matchCode: String
    private let mateUID: String
    private let myUID: String
    
    // 초기화 (목표 분 단위)
    init(goalMinutes: Int, matchCode: String, myUID: String, mateUID: String,  myCharacter: String, mateCharacter: String) {
        self.matchCode = matchCode
        self.myUID = myUID
        self.mateUID = mateUID
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        
        self.viewModel = PlankCoopViewModel(
            goalMinutes: goalMinutes,
            matchCode: myCharacter,
            myUID: mateCharacter,
            mateUID: matchCode,
            myCharacter: myUID,
            mateCharacter: mateCharacter
        )
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("not implemented") }
    
    override func loadView() {
        self.view = sportsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sportsView.updateGoal("플랭크 \(viewModel.goalMinutes)분") // 또는 회, 개, whatever
        sportsView.updateMyCharacter(myCharacter)
        sportsView.updateMateCharacter(mateCharacter)
        
        bind()
        startRelay.accept(())
        // 버튼 Rx 바인딩
        sportsView.pauseButton.rx.tap
            .bind(to: pauseRelay)
            .disposed(by: disposeBag)
        sportsView.stopButton.rx.tap
            .bind { [weak self] in
                self?.sportsView.showQuitAlert(
                    type: .myQuitConfirm, // 내가 종료 시도
                    onResume: {
                        // 그냥 닫고 아무 동작 없음 (계속 운동)
                    },
                    onQuit: { [weak self] in
                        // 진짜로 종료 → 기록 저장 & 화면 이동 등
                        self?.viewModel.finish(success: false)
                        // 혹은 didFinishRelay 트리거 등
                    }
                )
            }
            .disposed(by: disposeBag)
        
        MatchEventService.shared.markReady(matchCode: matchCode, myUid: myUid)
        listenStartTime()
        
    }
    
    private func listenStartTime() {
            MatchEventService.shared.listenStartTime(matchCode: matchCode)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] startTime in
                    guard let self = self else { return }
                    let delay = startTime.timeIntervalSinceNow
                    print("운동 시작까지 \(delay)초 대기")

                    if delay > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.startWorkout()
                        }
                    } else {
                        self.startWorkout()
                    }
                })
                .disposed(by: disposeBag)
        }

        private func startWorkout() {
            print("운동 시작!")
            // 운동 타이머 시작, UI 업데이트 등
        }
    
    private func bind() {
        let input = PlankCoopViewModel.Input(
            start: startRelay.asObservable(),
            pause: pauseRelay.asObservable(),
            matePause: matePauseRelay.asObservable(),
            resume: resumeRelay.asObservable(),
            mateResume: mateResumeRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        // status와 timer 동시 바인딩 → status별 알럿/상태분기 & UI 업데이트
        Driver
            .combineLatest(output.status, output.timerText.map { Int($0) })
            .drive(onNext: { [weak self] tuple in
                guard let self = self else { return }
                let (status, timer) = tuple
                self.sportsView.updateStatus(status, timer: timer ?? 0)
                switch status {
                case .myTurn:
                    self.sportsView.setPauseButtonEnabled(true)
                default:
                    self.sportsView.setPauseButtonEnabled(false)
                }
                // 알럿 상태 분기
                switch status {
                case .paused(let isMine):
                    if self.sportsView.alertView != nil { return }
                    if isMine {
                        self.sportsView.showPauseAlert(
                            type: .myPause,
                            onResume: { self.resumeRelay.accept(()) },
                            onQuit:   { self.quitRelay.accept(()) }
                        )
                    } else {
                        self.sportsView.showPauseAlert(type: .matePause)
                    }
                default:
                    self.sportsView.hidePauseAlert()
                }
                // 종료 분기
                switch status {
                case .quitting(let isMine):
                    if self.sportsView.alertView != nil { return }
                    if isMine {
                        self.sportsView.showQuitAlert(
                            type: .myQuitConfirm,
                            onResume: { self.sportsView.hideQuitAlert() },
                            onQuit:     { self.viewModel.finish(success: false) }
                        )
                    } else {
                        self.sportsView.showQuitAlert(
                            type: .mateQuit,
                            onBack: { self.viewModel.finish(success: false) }
                        )
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        output.timerText
            .drive(sportsView.timerLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.myTimeText
            .drive(with: self) { owner, text in
                owner.sportsView.updateMyRecord(text)
            }
            .disposed(by: disposeBag)
        output.mateTimeText
            .drive(with: self) { owner, text in
                owner.sportsView.updateMateRecord(text)
            }
            .disposed(by: disposeBag)
        
        output.progress
            .drive(with: self) { owner, ratio in
                owner.sportsView.updateProgress(ratio: ratio)
            }
            .disposed(by: disposeBag)
        
        output.didFinish
            .emit(with: self) { owner, success in
                owner.navigateToFinish(success: success)
            }
            .disposed(by: disposeBag)
    }
    private func navigateToFinish(success: Bool) {
        let finishVM = FinishViewModel(
            mode: .cooperation,
            sport: "플랭크",
            goal: viewModel.goalMinutes,
            goalUnit: "분",
            character: myCharacter,
            success: success
        )
        let vc = FinishViewController(uid: myUID, viewModel: finishVM)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    // 외부(네트워크 등)에서 상대방 이벤트 수신 시 호출
    func receiveMatePaused() { matePauseRelay.accept(()) }
    func receiveMateResumed() { mateResumeRelay.accept(()) }
    func receiveMateQuit()    {
        sportsView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                // 피니쉬화면으로 이동 등
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
    }
}
