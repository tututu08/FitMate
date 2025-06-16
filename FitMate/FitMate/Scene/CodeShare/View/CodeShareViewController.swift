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
    
    private let uid: String // 로그인 사용자 uid
    
    init(uid: String) {
        self.uid = uid // 의존성 주입
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
    }
}
