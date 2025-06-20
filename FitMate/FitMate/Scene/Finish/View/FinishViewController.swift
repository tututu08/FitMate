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
        
        //        output.rewardText
        //            .drive(onNext: { [weak self] text in
        //                self?.finishView.rewardLabel.text = text
        //            })
        //            .disposed(by: disposeBag)
        //
        //        output.hideCoin
        //            .drive(onNext: { [weak self] hide in
        //                self?.finishView.coinBackImage.isHidden = hide
        //            })
        //            .disposed(by: disposeBag)
        
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
        
        
        finishView.rewardButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                let tabBarVC = TabBarController(uid: self.uid)
                       tabBarVC.modalPresentationStyle = .fullScreen
                // rootViewController를 통째로 교체
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                    .first {
                    window.rootViewController = tabBarVC
                    window.makeKeyAndVisible()
                }
            }
            .disposed(by: disposeBag)
        
        // 게임 결과 저장
        finishView.rewardButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                

                print("self.matchCode: \(self.matchCode)\nmyUid: \(self.uid)\nmateUid: \(self.mateUid)\nmode: \(viewModel.mode)\nisWinner: \(viewModel.success)\ngoal: \(viewModel.goal)\nexerciseType: \(viewModel.sport)")
                
                // 업데이트 실행
                FirestoreService.shared.updateMatchResult(
                    matchCode: self.matchCode,
                    myUid: self.uid,
                    mateUid: self.mateUid,
                    mode: viewModel.mode,
                    isWinner: viewModel.success,
                    goal: viewModel.goal,
                    exerciseType: viewModel.sport
                )
                .subscribe(onCompleted: {
                    print("파이어스토어 업데이트 완료")

                    let tabBarVC = TabBarController(uid: self.uid)
                    tabBarVC.modalPresentationStyle = .fullScreen
                    if let window = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                        .first {
                        window.rootViewController = tabBarVC
                        window.makeKeyAndVisible()
                    }
                }, onError: { error in
                    print("업데이트 실패: \(error)")
                })
                .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel
            .saveRecord(uid: self.uid, mateUid: mateUid, matchCode: matchCode)
            .subscribe(onCompleted: {
                print("✅ 유저 기록 저장 완료")
            }, onError: { error in
                print("❌ 유저 기록 저장 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
