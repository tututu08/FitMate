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
    private let viewModel: CodeShareViewModel
    
    private let uid: String // 로그인 사용자 uid
    
    init(uid: String) {
        self.uid = uid // 의존성 주입
        print("uid : \(uid)")
        viewModel = CodeShareViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = codeShareView
    }
    
    // 네이게이션 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func bindViewModel() {
        // 메이트 코드 입력 버튼
        codeShareView.mateCodeButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                let next = MateCodeViewController()
                self?.navigationController?.pushViewController(next, animated: true)
        
        // 상단 X 버튼
        codeShareView.xButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                //         let moveIn = MainViewController()
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
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
