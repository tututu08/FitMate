import UIKit
import RxSwift
import RxCocoa

// 운동 종료 결과를 보여주는 컨트롤러
class FinishViewController: BaseViewController {
    
    private let finishView = FinishView()
    private let viewModel: FinishViewModel
    let uid: String
    let mateUid: String
    let matchCode: String
    
    init(uid: String, mateUid: String, matchCode: String, viewModel: FinishViewModel) {
        self.uid = uid
        self.mateUid = mateUid
        self.matchCode = matchCode
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    
    override func loadView() {
        self.view = finishView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reward = calculateReward(
            exerciseType: viewModel.sport,
            goalValue: viewModel.goal,
            mode: viewModel.mode,
            isWin: viewModel.success
        )
        
        //print("보상 : \(reward)\n")
        
        finishView.updateReward(text: "\(reward)", hideCoin: viewModel.success)
    }
    
    override func bindViewModel() {
        let output = viewModel.transform(input: .init())
        
        output.modeText
            .drive(onNext: { [weak self] text in
                self?.finishView.updateMode(text)
            })
            .disposed(by: disposeBag)
        
        output.goalText
            .drive(onNext: { [weak self] text in
                self?.finishView.updateGoal(text)
            })
            .disposed(by: disposeBag)
        
        output.rewardText
            .drive(onNext: { [weak self] text in
                self?.finishView.rewardLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.hideCoin
            .drive(onNext: { [weak self] hide in
                self?.finishView.coinBackImage.isHidden = hide
            })
            .disposed(by: disposeBag)
        
        output.resultText
            .drive(onNext: { [weak self] text in
                self?.finishView.resultLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.resultImageName
            .drive(onNext: { [weak self] name in
                self?.finishView.resultImage.image = UIImage(named: name)
            })
            .disposed(by: disposeBag)
        
        output.characterImageName
            .drive(onNext: { [weak self] name in self?.finishView.updateCharacter(name) })
            .disposed(by: disposeBag)
        
        // 게임 결과 저장
        finishView.rewardButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                
                if viewModel.success {
                    SoundManage.shared.coinSound()
                }
                
                // 보상 결과
                let reward = calculateReward(
                    exerciseType: viewModel.sport,
                    goalValue: viewModel.goal,
                    mode: viewModel.mode,
                    isWin: viewModel.success
                )
                
                //print("보상 : \(reward)\n")
                
                // 코인 가산
                rewardCoins(coinAmount: reward)
                
                FirestoreService.shared.updateMatchResult(
                    matchCode: self.matchCode,
                    myUid: self.uid,
                    mateUid: self.mateUid,
                    mode: viewModel.mode,
                    isWinner: viewModel.success,
                    goal: viewModel.goal,
                    myDistance: viewModel.myDistance,
                    exerciseType: viewModel.sport
                )
                .andThen(
                    self.viewModel.saveRecord(
                        uid: self.uid,
                        mateUid: self.mateUid,
                        matchCode: self.matchCode
                    )
                )
                .subscribe(onCompleted: {
                    print("유저 기록 저장 완료")
                    
                    let tabBarVC = TabBarController(uid: self.uid)
                    tabBarVC.modalPresentationStyle = .fullScreen
                    if let window = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                        .first {
                        window.rootViewController = tabBarVC
                        window.makeKeyAndVisible()
                    }
                }, onError: { error in
                    print("유저 기록 저장 실패: \(error.localizedDescription)")
                })
                .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    /// 코인 보상 계산
    private func calculateReward(
        exerciseType: String,
        goalValue: Int,    // km, 분, 개수(줄넘기)
        mode: FinishViewModel.Mode,
        isWin: Bool = false
    ) -> Int {
        // 운동 계수
        let exerciseFactor: Double = {
            switch exerciseType {
            case "걷기", "달리기": return 1.5
            case "자전거": return 1.0
            case "플랭크": return 1.6
            case "줄넘기": return 1.4
            default: return 1.0
            }
        }()
        
        // 모드 계수
        let modeFactor: Double = {
            switch mode {
            case .cooperation: return 0.5
            case .battle: return isWin ? 1.0 : 0.0
            }
        }()

        // 지속 보너스 계수
        let durationBonus: Double = {
            switch exerciseType {
            case "걷기":
                if goalValue < 5 { return 0.5 }
                else if goalValue < 11 { return 1.0 }
                else if goalValue < 16 { return 1.5 }
                else if goalValue < 20 { return 1.8 }
                else { return 2.0 }
            case "달리기":
                if goalValue < 5 { return 0.5 }
                else if goalValue < 11 { return 1.0 }
                else if goalValue < 16 { return 1.5 }
                else if goalValue < 20 { return 1.8 }
                else if goalValue < 26 { return 2.0 }
                else if goalValue < 30 { return 2.5 }
                else if goalValue < 36 { return 3.0 }
                else { return 4.0 }
            case "자전거":
                if goalValue < 11 { return 0.5 }
                else if goalValue < 15 { return 0.8 }
                else if goalValue < 30 { return 1.0 }
                else if goalValue < 36 { return 1.5 }
                else if goalValue < 40 { return 1.8 }
                else if goalValue < 46 { return 2.0 }
                else if goalValue < 50 { return 2.5 }
                else if goalValue < 56 { return 3.0 }
                else { return 4.0 }
            case "플랭크":
                if goalValue < 3 { return 0.5 }
                else if goalValue < 4 { return 0.7 }
                else if goalValue < 5 { return 0.9 }
                else if goalValue < 6 { return 1.2 }
                else if goalValue < 7 { return 1.5 }
                else if goalValue < 8 { return 1.8 }
                else if goalValue < 9 { return 2.0 }
                else if goalValue < 10 { return 2.3 }
                else { return 2.5 }
            case "줄넘기":
                if goalValue < 400 { return 0.5 }
                else if goalValue < 700 { return 0.8 }
                else if goalValue < 1000 { return 1.0 }
                else if goalValue < 1300 { return 1.3 }
                else if goalValue < 1600 { return 1.6 }
                else if goalValue < 1900 { return 2.0 }
                else { return 2.5 }
            default:
                return 1.0
            }
        }()

        //print("운동계수 : \(exerciseFactor)\n모드계수 : \(modeFactor)\n지속 보너스 : \(durationBonus)\n목표치 : \(goalValue)\n")
        let reward = (exerciseFactor * 100 * modeFactor * durationBonus).rounded(.toNearestOrEven)
        //print("함수 안 reward: \(reward)")
        return Int((reward / 10.0).rounded() * 10)
    }
    
    /// 코인 보상 지급
    private func rewardCoins(coinAmount: Int = 10) {
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: self.uid)
            .subscribe(
                onSuccess: { [weak self] data in
                    guard let self else { return }
                    
                    //print(" 문서 데이터: \(data)")
                    
                    let myCoin = data["coin"] as? Int
                    
                    FirestoreService.shared.updateDocument(collectionName: "users", documentName: self.uid, fields: ["coin": (myCoin ?? 0) + coinAmount])
                        .subscribe(
//                            onSuccess: {
//                                //print("업데이트 성공!")
//                            },
//                            onFailure: { error in
//                                //print("실패: \(error.localizedDescription)")
//                            }
                        )
                        .disposed(by: self.disposeBag)
                    
                }, onFailure: { error in
                    print(" 문서 가져오기 실패: \(error.localizedDescription)")
                }
            ).disposed(by: disposeBag)
    }
}
