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
    private let viewModel: NicknameViewModel
    
    private let uid: String // 로그인 사용자 uid
    
    init(uid: String) {
        self.uid = uid // 의존성 주입
        viewModel = NicknameViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = nicknameView
        nicknameView.nicknameField.stringLimit = 8 // 입력 텍스트 제한
    }
    
    override func bindViewModel() {
//        nicknameView.registerButton.rx.tap
//            .asDriver(onErrorDriveWith: .empty())
//            .drive(onNext: { [weak self] _ in
//                guard let self else { return }
//                let codeShareView = CodeShareViewController(uid: self.uid)
//                self.navigationController?.pushViewController(
//                    codeShareView, animated: true)
//            })
//            .disposed(by: disposeBag)
        
        let input = NicknameViewModel.Input(
            enteredCode: nicknameView.nicknameField.rx.text.orEmpty.asDriver(),
            textFieldLimit: nicknameView.nicknameField.overLimitRelay.asDriver(onErrorDriveWith: .empty()),
            termsTap: nicknameView.termsButton.rx.tap.asObservable(),
            privacyTap: nicknameView.privacyButton.rx.tap.asObservable(),
            
            // 텍스트 필드 입력
            nicknameText: nicknameView.nicknameField.textRelay.asObservable(),
            // 등록완료 버튼 탭
            registerTap: nicknameView.registerButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        // 닉네임 저장
        output.nicknameSaved
            .drive(onNext: { [weak self] in
                guard let self else { return }
                let codeShareView = CodeShareViewController(uid: self.uid, hasMate: false)
                self.navigationController?.pushViewController(codeShareView, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // 버튼 활성화 여부
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
        
        input.termsTap
            .bind { [weak self] in
                let vc = WebViewController()
                vc.urlString = "https://www.notion.so/2151c704065180778da1d2d1dfc4629d"
                vc.urlTitle = "이용약관"
                vc.modalPresentationStyle = .pageSheet // 또는 .automatic, .formSheet 등 취향대로
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)

        input.privacyTap
            .bind { [weak self] in
                let vc = WebViewController()
                vc.urlString = "https://www.notion.so/2151c7040651805f89e8f53d7777c91a"
                vc.urlTitle = "개인정보처리방침"
                vc.modalPresentationStyle = .pageSheet
                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)

    }
}
