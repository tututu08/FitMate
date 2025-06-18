//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import RxSwift
import RxCocoa

class MateCodeViewController: BaseViewController {
    private let mateCodeView = MateCodeView()
    private let viewModel: MateCodeViewModel
    
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
        viewModel = MateCodeViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = mateCodeView
    }
    
    // 시스템 네비게이션바 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupActions()
    }
    
    override func bindViewModel() {
        let input = MateCodeViewModel.Input(
            enteredCode: mateCodeView.fillInMateCode.rx.text.orEmpty.asObservable(),
            completeTap: mateCodeView.completeButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.result
                    .drive(onNext: { [weak self] alert, navigation in
                        if let alert = alert {
                            self?.presentAlert(for: alert)
                        }
                        if let navigation = navigation {
                            self?.handleNavigation(navigation)
                        }
                    })
                    .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func setupActions() {
        mateCodeView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    private func handleNavigation(_ navigation: Navigation) {
        switch navigation {
        case .backTo:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Alert
    private func presentAlert(for alert: AlertType) {
        let alertController: UIAlertController
        
        switch alert {
        case .inviteSent(let nickname):
            alertController = UIAlertController(
                title: "초대 전송 완료",
                message: "\(nickname)님에게 메이트 요청을 보냈습니다.",
                preferredStyle: .alert
            )
        case .requestFailed(let message):
            alertController = UIAlertController(
                title: "실패",
                message: message,
                preferredStyle: .alert
            )
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alertController, animated: true)
    }
    
}
