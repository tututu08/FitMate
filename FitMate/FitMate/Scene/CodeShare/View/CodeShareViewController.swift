//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//


import UIKit
import RxSwift
import RxCocoa

class CodeShareVIewController: BaseViewController {

    private let codeShareView = CodeShareView()

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
            //    let moveIn = MainViewController()
                self?.navigationController?.popViewController(animated: true)
            })
        
    }
}
