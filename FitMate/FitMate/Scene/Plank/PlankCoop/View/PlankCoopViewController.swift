import UIKit
import RxSwift
import RxCocoa

// 플랭크 협동모드(코드베이스) 뷰컨트롤러
final class PlankCoopViewController: BaseViewController {

    private let sportsView = PlankCoopView()
    private let viewModel: PlankCoopViewModel

    // Input 트리거들 (버튼/상태이벤트)
    private let startRelay = PublishRelay<Void>()      // 시작
    private let pauseRelay = PublishRelay<Void>()      // 내 일시정지
    private let resumeRelay = PublishRelay<Void>()     // 내 이어하기
    private let quitRelay = PublishRelay<Void>()       // 내 그만두기
    private let matePauseRelay = PublishRelay<Void>()  // 상대 일시정지
    private let mateResumeRelay = PublishRelay<Void>() // 상대 이어하기
    private let mateQuitRelay = PublishRelay<Void>()   // 상대 그만두기

    // 유저/매치 정보
    private let myCharacter: String      // 내 아바타
    private let mateCharacter: String    // 상대 아바타
    private let matchCode: String        // 경기 코드
    private let myUID: String            // 내 UID
    private let mateUID: String          // 상대 UID
    private let isInviter: Bool          // 내가 초대자인지 여부

    // 생성자(매치 기본정보 및 내/상대 정보 주입)
    init(
        goalMinutes: Int,
        matchCode: String,
        myUID: String,
        mateUID: String,
        isInviter: Bool,
        myCharacter: String,
        mateCharacter: String
    ) {
        self.matchCode = matchCode
        self.myUID = myUID
        self.mateUID = mateUID
        self.isInviter = isInviter
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter

        // 뷰모델 생성
        self.viewModel = PlankCoopViewModel(
            goalMinutes: goalMinutes,
            matchCode: matchCode,
            myUID: myUID,
            mateUID: mateUID,
            isInviter: isInviter,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter
        )
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("not implemented") }

    // 메인 뷰 할당
    override func loadView() { self.view = sportsView }

    // 최초 진입(화면 구성/이벤트 바인딩)
    override func viewDidLoad() {
        super.viewDidLoad()
        // 운동 중 화면 꺼짐 방지!
        UIApplication.shared.isIdleTimerDisabled = true

        // 목표/아바타 UI 업데이트
        sportsView.updateGoal("플랭크 \(viewModel.goalMinutes)분")
        sportsView.updateMyCharacter(myCharacter)
        sportsView.updateMateCharacter(mateCharacter)

        // 주요 Rx 바인딩/Firestore 실시간 리스너 연결
        bind()
        viewModel.bindProgressFromFirestore()
        viewModel.bindMatchStatus()
        viewModel.bindMateQuitListener()
        startRelay.accept(()) // 시작 트리거

        // 일시정지 버튼: 내 pauseRelay로 연결
        sportsView.pauseButton.rx.tap
            .bind(to: pauseRelay)
            .disposed(by: disposeBag)
        // 정지(그만두기) 버튼: 알럿 띄우고 quitRelay로 연결
        sportsView.stopButton.rx.tap
            .bind { [weak self] in
                self?.sportsView.showQuitAlert(
                    type: .myQuitConfirm,
                    onResume: {},
                    onQuit: { [weak self] in self?.quitRelay.accept(()) }
                )
            }
            .disposed(by: disposeBag)
    }

    // 화면 사라질 때(혹시나 꺼짐 방지 해제!)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // 만약 컨트롤러가 deinit될 때도 안전하게 해제
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // ViewModel과 Rx 바인딩 세팅
    private func bind() {
        // Input - 버튼 등에서 발생한 이벤트를 ViewModel로 전달
        let input = PlankCoopViewModel.Input(
            start: startRelay.asObservable(),
            pause: pauseRelay.asObservable(),
            matePause: matePauseRelay.asObservable(),
            resume: resumeRelay.asObservable(),
            mateResume: mateResumeRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable()
        )
        // Output - ViewModel이 push하는 값을 UI에 바인딩
        let output = viewModel.transform(input: input)

        // 상태(status)/타이머 등 여러 UI 값들을 한 번에 합쳐서 UI 업데이트
        Driver
            .combineLatest(output.status, output.timerText.map { Int($0) })
            .drive(onNext: { [weak self] tuple in
                guard let self = self else { return }
                let (status, timer) = tuple
                // 현재 상태, 남은시간 기반으로 UI 갱신
                self.sportsView.updateStatus(status, timer: timer ?? 0)
                // 내 턴일 때만 일시정지 버튼 활성화
                switch status {
                case .myTurn: self.sportsView.setPauseButtonEnabled(true)
                default:      self.sportsView.setPauseButtonEnabled(false)
                }

                // 일시정지 알럿: 상태/주체에 따라 다르게 분기
                switch status {
                case .paused(let isMine):
                    // 이미 알럿이 떠있으면 중복으로 띄우지 않음
                    if self.sportsView.alertView != nil { return }
                    if isMine {
                        // 내가 일시정지
                        self.sportsView.showPauseAlert(
                            type: .myPause,
                            onResume: { self.resumeRelay.accept(()) }, // 이어하기
                            onQuit:   { self.quitRelay.accept(()) }    // 그만두기
                        )
                    } else {
                        // 상대가 일시정지
                        self.sportsView.showPauseAlert(type: .matePause)
                    }
                default:
                    self.sportsView.hidePauseAlert()
                }

                // 종료(그만두기) 알럿: 상태/주체에 따라 분기
                switch status {
                case .quitting(let isMine):
                    if self.sportsView.alertView != nil { return }
                    if isMine {
                        // 내가 그만두기
                        self.sportsView.showQuitAlert(
                            type: .myQuitConfirm,
                            onResume: { self.sportsView.hideQuitAlert() },
                            onQuit:     { self.viewModel.finish(success: false) }
                        )
                    } else {
                        // 상대가 그만두기
                        self.sportsView.showQuitAlert(
                            type: .mateQuit,
                            onBack: { self.viewModel.finish(success: false) }
                        )
                    }
                default: break
                }
            })
            .disposed(by: disposeBag)

        // 타이머 텍스트 UI
        output.timerText
            .drive(sportsView.timerLabel.rx.text)
            .disposed(by: disposeBag)
        // 내 누적시간 텍스트 UI
        output.myTimeText
            .drive(with: self) { owner, text in
                owner.sportsView.updateMyRecord(text)
            }
            .disposed(by: disposeBag)
        // 상대 누적시간 텍스트 UI
        output.mateTimeText
            .drive(with: self) { owner, text in
                owner.sportsView.updateMateRecord(text)
            }
            .disposed(by: disposeBag)
        // 프로그레스바 UI
        output.progress
            .drive(with: self) { owner, ratio in
                owner.sportsView.updateProgress(ratio: ratio)
            }
            .disposed(by: disposeBag)
        // 게임 종료시 결과화면 이동
        output.didFinish
            .distinctUntilChanged({ prev, curr in
              let prevSuccess = prev
              let currSuccess = curr
              return prevSuccess == currSuccess ? true : false
            })
            .emit(with: self) { owner, success in
                owner.navigateToFinish(success: success)
            }
            .disposed(by: disposeBag)
        // 상대가 그만둔 경우: 알럿 띄움
        output.mateQuitEvent
            .emit(with: self) { owner, _ in
                owner.receiveMateQuit()
            }
            .disposed(by: disposeBag)
    }

    // 결과화면 이동(성공/실패)
    private func navigateToFinish(success: Bool) {
        // 내 아바타 타입 변환
        let avatarType = AvatarType(rawValue: self.myCharacter) ?? .kaepy
        // 결과 화면용 뷰모델 생성
        let finishVM = FinishViewModel(
            mode: .cooperation,
            sport: "플랭크",
            goal: viewModel.goalMinutes,
            goalUnit: "분",
            myDistance: Double(viewModel.myTime),
            avatarType: avatarType,
            success: success
        )
        // 결과 화면 푸시
        let vc = FinishViewController(
            uid: myUID,
            mateUid: mateUID,
            matchCode: matchCode,
            viewModel: finishVM
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // Rx 트리거 수동 호출 (상대방 액션 수신용)
    func receiveMatePaused()  { matePauseRelay.accept(()) }
    func receiveMateResumed() { mateResumeRelay.accept(()) }

    // 상대가 그만둔 경우(=퇴장) → 알럿/효과음 → 결과화면 이동
    func receiveMateQuit() {
        sportsView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                guard let self else { return }
                self.viewModel.finish(success: false)
                self.navigateToFinish(success: false)
            }
        )
    }
}
