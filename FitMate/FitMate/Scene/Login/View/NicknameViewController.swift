//
//  NicknameViewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import RxSwift
import RxCocoa

class NicknameViewController: BaseViewController {
    
    private let nicknameView = NicknameView()
    private let viewModel = NicknameViewModel()
    
    override func loadView() {
        self.view = nicknameView
        nicknameView.nicknameField.stringLimit = 8
    }
    
    override func bindViewModel() {
        nicknameView.registerButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                let codeShareView = CodeShareVIewController()
                self?.navigationController?.pushViewController(
                    codeShareView, animated: true)
            })
            .disposed(by: disposeBag)
        
        let input = NicknameViewModel.Input(
            enteredCode: nicknameView.nicknameField.rx.text.orEmpty.asDriver(),
            textFieldLimit: nicknameView.nicknameField.overLimitRelay.asDriver(onErrorDriveWith: .empty()),
            termsTap: nicknameView.termsButton.rx.tap.asObservable(),
            privacyTap: nicknameView.privacyButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.buttonActivated
            .drive(onNext: { [weak self] activated in
                guard let self = self else { return }
                let button = self.nicknameView.registerButton
                
                button.isEnabled = activated // 버튼 활성화 여부 설정
                button.backgroundColor = activated ? UIColor.primary500 : UIColor.background50
                button.setTitleColor(activated ? .white : .background500, for: .normal)
            })
            .disposed(by: disposeBag)
        // 얼럿 띄우기
        output.showAlert
            .drive(onNext: { [weak self] alertType in
                guard let self = self else { return }
                let alert = alertType.makeAlertController()
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 버튼 체크되면 이미지 변경
        output.termsChecked
            .drive(onNext: { isChecked in
                let image = UIImage(named: isChecked ? "checkBox_checked" : "checkBox")
                self.nicknameView.termsButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        // 버튼 체크되면 이미지 변경
        output.privacyChecked
            .drive(onNext: { isChecked in
                let image = UIImage(named: isChecked ? "checkBox_checked" : "checkBox")
                self.nicknameView.privacyButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    
}
