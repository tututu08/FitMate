//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//


import UIKit
import RxSwift
import RxCocoa

class CodeShareViewController: BaseViewController {
    
    private let codeShareView = CodeShareView()
    private let viewModel = CodeShareViewModel()
    
    override func loadView() {
        self.view = codeShareView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func bindViewModel() {
        codeShareView.mateCodeButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                let next = MateCodeViewController()
                self?.navigationController?.pushViewController(next, animated: true)
            })
            .disposed(by: disposeBag)
        
        codeShareView.xButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext:  { [weak self] in
                //         let moveIn = MainViewController()
                self?.navigationController?.popViewController(animated: true)
            })
        let input = CodeShareViewModel.Input(
            copyTab: codeShareView.copyRandomCodeButton.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.showAlert
            .drive(onNext: { [weak self] alertType in
                let alert = UIAlertController(
                    title: alertType.title,
                    message: alertType.message,
                    preferredStyle: .alert
                )
                alertType.actions.forEach { alert.addAction($0) }
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.copiedText
            .bind(to: codeShareView.copyRandomCodeButton.randomCode.rx.text)
            .disposed(by: disposeBag)
        
    }
    
}

