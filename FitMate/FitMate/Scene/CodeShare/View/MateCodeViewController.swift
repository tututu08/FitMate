//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//
import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class MateCodeViewController: BaseViewController {
    
    private let mateCodeView = MateCodeView()
    private let mateViewModel = MateCodeViewModel()
    
    override func loadView() {
        self.view = mateCodeView
        bindViewModel()
    }
    // 시스템 네비게이션바 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func bindViewModel() {
        let input = MateCodeViewModel.Input(
            completeTap: mateCodeView.completeButton.rx.tap.asDriver(),
            enteredCode: mateCodeView.fillInMateCode.rx.text.orEmpty.asDriver(),
            backTap: mateCodeView.backButton.rx.tap.asDriver()
        )
        
        let output = mateViewModel.transform(input: input)
        
        // 알림 처리
        output.alert
            .compactMap { $0 }
            .drive(onNext: { [weak self] type in
                guard let self = self else { return }
                
                switch type {
                case .codeSent:
                    let alert = UIAlertController(
                        title: SystemAlertType.codeSent.title,
                        message: nil,
                        preferredStyle: .alert
                    )
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                    
                case .invalidCode:
                    let alert = UIAlertController(
                        title: SystemAlertType.invalidCode.title,
                        message: nil,
                        preferredStyle: .alert
                    )
                    SystemAlertType.invalidCode.actions.forEach { alert.addAction($0) }
                    self.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // 화면 전환 처리
        output.navigation
            .compactMap { $0 }
            .drive(onNext: { [weak self] nav in
                guard let self = self else { return }
                
                switch nav {
                case .goToMain(let uid):
                    let mainVC = MainViewController(uid: uid)
                    self.navigationController?.pushViewController(mainVC, animated: true)
                case .backTo:
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        output.buttonActivated
            .drive(onNext: { [weak self] activated in
                guard let self = self else { return }
                let button = self.mateCodeView.completeButton
                
                button.isEnabled = activated // 버튼 활성화 여부 설정
                button.backgroundColor = activated ? UIColor.primary500 : UIColor.background50
                button.setTitleColor(activated ? .white : .background500, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
}



