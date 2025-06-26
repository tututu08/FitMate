import RxSwift
import Foundation
import RxCocoa
import FirebaseFirestore

// JumpRope 대결 모드 컨트롤러 (전체 흐름 제어, ViewModel과 View 연결 담당)
class JumpRopeBattleViewController: BaseViewController {
    
    // 루트 뷰
    private let sportsView = JumpRopeBattleView()
    // 뷰모델 선언
    private var viewModel: JumpRopeBattleViewModel
    // 시작 트리거용(버튼, viewDidLoad 등에서 신호 보낼 때 사용)
    private let startRelay = PublishRelay<Void>()
    // 메이트 점프 횟수 수신용(상대방이 firebase에서 온 값으로 갱신할 때 쓸 수도 있음)
    private let mateCountRelay = PublishRelay<Double>()
    private let quitRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()
    private let myCharacter: String
    private let mateCharacter: String
    private let matchCode: String
    private let mateUid: String
    private let myUid: String
    
    init(goalCount: Int, matchCode: String, myUid: String, mateUid: String,  myCharacter: String, mateCharacter: String) {
        self.matchCode = matchCode
        self.myUid = myUid
        self.mateUid = mateUid
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        
        self.viewModel = JumpRopeBattleViewModel(
            goalCount: goalCount,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter,
            matchCode: matchCode,
            myUID: myUid,
            mateUID:mateUid
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
        //(파이널베이스 내의 만약 캐릭터 이미지 바인딩 시 이곳에서)
        sportsView.updateMyCharacter(myCharacter)
        sportsView.updateMateCharacter(mateCharacter)
        
//        FirestoreService.shared
//            .observeMateProgress(matchCode: matchCode, mateUid: mateUid)
//            .bind(to: mateCountRelay)
//            .disposed(by: disposeBag)
        
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
                        //self?.viewModel.finish(success: false)
                        self?.quitRelay.accept(())
                        // 혹은 didFinishRelay 트리거 등
                    }
                )
            }
            .disposed(by: disposeBag)
    }
    
    // ViewModel과 UI 바인딩
    override func bindViewModel() {
        let input = JumpRopeBattleViewModel.Input(
            start: startRelay.asObservable(),
            //mateCount: mateCountRelay.asObservable(),
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
        
        output.didFinish
            .emit(onNext: { [weak self] success in
                self?.navigateToFinish(success: success)
            })
            .disposed(by: disposeBag)
        
        // 내 진행률바(비율)
        output.myProgressView
            .drive(onNext: { [weak self] ratio in
                self?.sportsView.myUpdateProgress(ratio: ratio)
            })
            .disposed(by: disposeBag)
        
        // 메이트 진행률바(비율)x
        output.mateProgressView
            .drive(onNext: { [weak self] ratio in
                self?.sportsView.mateUpdateProgress(ratio: ratio)
            })
            .disposed(by: disposeBag)
        
        output.mateQuitEvent
            .emit(onNext: { [weak self] in
                self?.receiveMateQuit()
            })
            .disposed(by: disposeBag)
    }
    
    // 피니쉬화면으로 이동
    private func navigateToFinish(success: Bool) {
        let finishVM = FinishViewModel(
            mode: .battle,
            sport: "줄넘기",
            goal: viewModel.goalCount,
            goalUnit: "개",
            myDistance: Double(viewModel.myCount),
            character: myCharacter,
            success: success
        )
        
        let vc = FinishViewController(
            uid: myUid,
            mateUid: mateUid,
            matchCode: matchCode,
            viewModel: finishVM
        )
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func navigateToFinish() {
        Firestore.firestore().collection("matches").document(matchCode)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let data = snapshot?.data(),
                      let players = data["players"] as? [String: Any],
                      let myData = players[self.myUid] as? [String: Any],
                      let isWinner = myData["isWinner"] as? Bool else {
                    print("🔥 승자 정보 불러오기 실패")
                    return
                }

                let finishVM = FinishViewModel(
                    mode: .battle,
                    sport: "줄넘기",
                    goal: self.viewModel.goalCount,
                    goalUnit: "개",
                    myDistance: Double(self.viewModel.myCount),
                    character: self.myCharacter,
                    success: isWinner  // ✅ Firestore에서 가져온 최종 결과
                )

                let vc = FinishViewController(
                    uid: self.myUid,
                    mateUid: self.mateUid,
                    matchCode: self.matchCode,
                    viewModel: finishVM
                )
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
    }
    
    func receiveMateQuit()    {
        viewModel.stopLocationUpdates()
        
        sportsView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                // 피니쉬화면으로 이동 등
                //self?.navigationController?.popToRootViewController(animated: true)
                
                self?.viewModel.finish(success: true) // ✅ 위치 정지 및 기록 저장
                //self?.navigateToFinish(success: true)
                self?.navigateToFinish()
            }
        )
    }
}
