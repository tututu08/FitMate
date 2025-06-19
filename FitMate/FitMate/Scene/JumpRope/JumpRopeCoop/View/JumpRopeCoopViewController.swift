import RxSwift
import Foundation
import RxCocoa

// JumpRope 협동 모드 컨트롤러 (전체 흐름 제어, ViewModel과 View 연결 담당)
class JumpRopeCoopViewController: BaseViewController {
    
    // 루트 뷰
    private let sportsView = JumpRopeCoopView()
    // 뷰모델 선언
    private var viewModel: JumpRopeCoopViewModel
    // 시작 트리거용(버튼, viewDidLoad 등에서 신호 보낼 때 사용)
    private let startRelay = PublishRelay<Void>()
    // 메이트 점프 횟수 수신용(상대방이 firebase에서 온 값으로 갱신할 때 쓸 수도 있음)
    private let mateCountRelay = PublishRelay<Int>()
    private let myCharacter: String
    private let mateCharacter: String
    private let quitRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()
    
    init(goalCount: Int, myCharacter: String, mateCharacter: String /*matchID: String, myUID: String, mateUID: String*/) {
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.viewModel = JumpRopeCoopViewModel(
               goalCount: goalCount,
               myCharacter: myCharacter,
               mateCharacter: mateCharacter
//               matchID: matchID,
//               myUID: myUID,
//               mateUID: mateUID
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    
    
    // loadView에서 커스텀 뷰 할당
    override func loadView() {
        self.view = sportsView
    }
    
    // viewDidLoad에서 goal값 불러오기, 뷰모델 생성, 시작 신호
    override func viewDidLoad() {
        super.viewDidLoad()
        sportsView.updateGoal("줄넘기 \(viewModel.goalCount)개")
        sportsView.updateMyCharacter(viewModel.myCharacter)
        sportsView.updateMateCharacter(viewModel.mateCharacter)
        startRelay.accept(())
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
    }
    // ViewModel과 UI 바인딩
    override func bindViewModel() {
        let input = JumpRopeCoopViewModel.Input(
            start: startRelay.asObservable(),
            mateCount: mateCountRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        // 내 점프 횟수 갱신할 때(문자열)
        output.myCountText
            .drive(onNext: { [weak self] text in
                self?.sportsView.updateMyRecord(text)
            })
            .disposed(by: disposeBag)
        
        // 메이트 점프 횟수 갱신할 때(문자열)
        output.mateCountText
            .drive(onNext: { [weak self] text in
                self?.sportsView.updateMateRecord(text)
            })
            .disposed(by: disposeBag)
        
        // 전체 진행률 바 갱신할 때(비율)
        output.progress
            .drive(onNext: { [weak self] ratio in
                self?.sportsView.updateProgress(ratio: ratio)
            })
            .disposed(by: disposeBag)
        
        output.didFinish
                    .emit(onNext: { [weak self] success in
                        self?.navigateToFinish(success: success)
                    })
                    .disposed(by: disposeBag)
            }

            private func navigateToFinish(success: Bool) {
                let finishVM = FinishViewModel(
                    mode: .cooperation,
                    sport: "줄넘기",
                    goal: viewModel.goalCount,
                    goalUnit: "개",
                    character: myCharacter,
                    success: success
                )
                let vc = FinishViewController(viewModel: finishVM)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
    }
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
