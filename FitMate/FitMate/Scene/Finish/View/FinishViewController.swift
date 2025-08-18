import UIKit
import RxSwift
import RxCocoa

// 운동 종료 결과를 보여주는 컨트롤러
class FinishViewController: BaseViewController {
    
    private let finishView = FinishView()
    private let viewModel: FinishViewModel
    
    init(viewModel: FinishViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func loadView() {
        self.view = finishView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel.success {
            SoundManage.shared.playSuccess()
        } else {
            SoundManage.shared.playFail()
        }
    }
    
    override func bindViewModel() {
        let input = FinishViewModel.Input(
            rewardTap: finishView.rewardButton.rx.tap.asSignal()
        )
        let output = viewModel.transform(input: input)
        
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
        
        // 저장 완료 → 화면 전환
        output.saveCompleted
            .emit(onNext: { [weak self] in
                guard let self else { return }
                let tabBarVC = TabBarController(uid: viewModel.uid)
                tabBarVC.modalPresentationStyle = .fullScreen
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
                    window.rootViewController = tabBarVC
                    window.makeKeyAndVisible()
                }
            }).disposed(by: disposeBag)
        
        output.saveFailed
            .emit(onNext: { errorMsg in
                print("유저 기록 저장 실패: \(errorMsg)")
                // 필요 시 토스트/알럿
            })
            .disposed(by: disposeBag)
    }
}
