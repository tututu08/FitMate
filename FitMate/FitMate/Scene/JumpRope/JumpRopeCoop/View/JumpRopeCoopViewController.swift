import RxSwift
import Foundation
import RxCocoa

// JumpRope 협동 모드 컨트롤러 (전체 흐름 제어, ViewModel과 View 연결 담당)
class JumpRopeCoopViewController: BaseViewController {
    
    // 루트 뷰
    private let rootView = JumpRopeCoopView()
    // 뷰모델 선언
    private var viewModel: JumpRopeCoopViewModel
    // 시작 트리거용(버튼, viewDidLoad 등에서 신호 보낼 때 사용)
    private let startRelay = PublishRelay<Void>()
    // 메이트 점프 횟수 수신용(상대방이 firebase에서 온 값으로 갱신할 때 쓸 수도 있음)
    private let mateCountRelay = PublishRelay<Int>()
    //private let myCharacter: String
    //private let mateCharacter: String
    
    init(goalCount: Int/*, myCharacter: String, mateCharacter: String matchID: String, myUID: String, mateUID: String*/) {
        //self.myCharacter = myCharacter
        //self.mateCharacter = mateCharacter
        self.viewModel = JumpRopeCoopViewModel(
               goalCount: goalCount,
               //myCharacter: myCharacter,
               //mateCharacter: mateCharacter
//               matchID: matchID,
//               myUID: myUID,
//               mateUID: mateUID
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    
    
    // loadView에서 커스텀 뷰 할당
    override func loadView() {
        self.view = rootView
    }
    
    // viewDidLoad에서 goal값 불러오기, 뷰모델 생성, 시작 신호
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.updateGoal("줄넘기 \(viewModel.goalCount)개")
        //rootView.updateMyCharacter(viewModel.myCharacter)
        //rootView.updateMateCharacter(viewModel.mateCharacter)
        startRelay.accept(())
    }
    // ViewModel과 UI 바인딩
    override func bindViewModel() {
        let input = JumpRopeCoopViewModel.Input(
            start: startRelay.asObservable(),
            mateCount: mateCountRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        // 내 점프 횟수 갱신할 때(문자열)
        output.myCountText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMyRecord(text)
            })
            .disposed(by: disposeBag)
        
        // 메이트 점프 횟수 갱신할 때(문자열)
        output.mateCountText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMateRecord(text)
            })
            .disposed(by: disposeBag)
        
        // 전체 진행률 바 갱신할 때(비율)
        output.progress
            .drive(onNext: { [weak self] ratio in
                self?.rootView.updateProgress(ratio: ratio)
            })
            .disposed(by: disposeBag)
    }
}
