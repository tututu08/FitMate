//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import Lottie
import SnapKit
import RxSwift

class LoadingViewController: BaseViewController {
    
    private let viewModel: LoadingViewModel // ViewModel 의존성 주입
    private let loadingView = LoadingView() // 뷰 객체 생성
    private var hasNavigatedToGame = false
    
    private let uid: String
    private let matchCode: String
    
    init(uid: String, matchCode: String) {
        // ViewModel 의존성 주입을 통해 운동 경기 코드를 전달
        self.uid = uid
        self.matchCode = matchCode
        //self.viewModel = LoadingViewModel(matchCode: matchCode)
        self.viewModel = LoadingViewModel(matchCode: matchCode, myUid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = loadingView
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.hidesBottomBarWhenPushed = true
    }
    
    /// ViewModel 바인딩
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel.matchStatusEvent
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] status in
                print("🔥 받은 상태: \(status)")
                guard let self else { return }
                
                // started 상태가 되면 시작
                if status == "started" && !self.hasNavigatedToGame {
                    print("✅ 동시에 시작 조건 충족 → 게임화면 이동")
                    self.hasNavigatedToGame = true
                    
                    // 실시간 감지 리스너 종료
                    MatchEventService.shared.stopMatchListening()
                    self.goToGameScreen()
                } else if status == "rejected" {
                    self.presentRejectedAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 게임 화면으로 이동하는 메서드
    private func goToGameScreen() {
        
        // MARK: - 게임 선택에 따른 화면 분기처리
        FirestoreService.shared.fetchDocument(collectionName: "matches", documentName: self.matchCode)
            .subscribe(onSuccess: { data in
                if let goalValue = data["goalValue"] as? Int,
                   let inviterUid = data["inviterUid"] as? String,
                   let inviteeUid = data["inviteeUid"] as? String,
                   let exerciseType = data["exerciseType"] as? String,
                   let mode = data["mode"] as? String {
                    
                    let mateUid = self.uid == inviterUid ? inviteeUid : inviterUid
                    
                    if mode == "battle" {
                        // 배틀모드
                        switch exerciseType {
                        case "걷기":
                            self.navigationController?.pushViewController(RunningBattleViewController(exerciseType: exerciseType, goalDistance: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "달리기":
                            self.navigationController?.pushViewController(RunningBattleViewController(exerciseType: exerciseType, goalDistance: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "자전거":
                            self.navigationController?.pushViewController(RunningBattleViewController(exerciseType: exerciseType, goalDistance: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "줄넘기":
                            self.navigationController?.pushViewController(JumpRopeBattleViewController(goalCount: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        default:
                            return
                        }
                    } else {
                        // 협동모드
                        switch exerciseType {
                        case "걷기":
                            self.navigationController?.pushViewController(RunningCoopViewController(exerciseType: exerciseType, goalDistance: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "달리기":
                            self.navigationController?.pushViewController(RunningCoopViewController(exerciseType: exerciseType, goalDistance: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "자전거":
                            self.navigationController?.pushViewController(
                                RunningCoopViewController(
                                    exerciseType: exerciseType, 
                                    goalDistance: goalValue,
                                    matchCode: self.matchCode,
                                    myUid: self.uid,
                                    mateUid: mateUid,
                                    myCharacter: "kaepy",
                                    mateCharacter: "kaepy"
                                ), animated: true)
                        case "플랭크":
                            self.navigationController?.pushViewController(PlankCoopViewController(goalMinutes: goalValue, matchCode: self.matchCode, myUID: self.uid, mateUID: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        case "줄넘기":
                            self.navigationController?.pushViewController(JumpRopeCoopViewController(goalCount: goalValue, matchCode: self.matchCode, myUid: self.uid, mateUid: mateUid, myCharacter: "kaepy", mateCharacter: "kaepy"), animated: true)
                        default:
                            return
                        }
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    /// 운동 요청 거절 시, 띄워지는 알림창 메서드
    private func presentRejectedAlert() {
        let alert = UIAlertController(title: "매칭 실패", message: "상대가 거절했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    deinit {
        print("LoadingViewController deinit")
    }
}
