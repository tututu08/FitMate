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

    required init?(coder: NSCoder) { fatalError("not implemented") }

    override func loadView() {
        self.view = finishView
    }

    override func bindViewModel() {
        let output = viewModel.transform(input: .init())

        output.modeText
            .drive(onNext: { [weak self] text in self?.finishView.updateMode(text) })
            .disposed(by: disposeBag)
        
        output.goalText
            .drive(onNext: { [weak self] text in self?.finishView.updateGoal(text)})
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
            .drive(onNext: { [weak self] text in self?.finishView.resultLabel.text = text })
            .disposed(by: disposeBag)
        
        output.resultImageName
            .drive(onNext: { [weak self] name in self?.finishView.resultImage.image = UIImage(named: name) })
            .disposed(by: disposeBag)
        
        output.characterImageName
            .drive(onNext: { [weak self] name in self?.finishView.updateCharacter(name) })
            .disposed(by: disposeBag)
        
        
        finishView.rewardButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                if let nav = self.presentingViewController?.navigationController {
                    self.dismiss(animated: true) {
                        nav.popToRootViewController(animated: true)
                    }
                } else {
                    self.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
