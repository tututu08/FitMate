//
//  NIcknameViewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NIcknameViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let nicknameViewTitle: UILabel = {
        let title = UILabel()
        title.text = "닉네임 등록"
        title.textColor = .white
        title.font = .systemFont(ofSize: 20)
        return title
    }()
    
    private let nicknameHeader = CustomHeader(text: "닉네임")
    private let nicknameField = CustomTextField(placeholder: "닉네임을 입력해주세요")
    
    private lazy var termsStack: UIStackView = setTermsStack()
    private lazy var privacyStack: UIStackView = setPrivacyStack()
    
    private let registerButton: UIButton = {
        let register = UIButton()
        register.setTitle("로그인", for: .normal)
        register.setTitleColor(.white, for: .normal)
        register.titleLabel?.font = UIFont.systemFont(ofSize: 22) // 폰트 변경 필요
        register.backgroundColor = .systemPurple // 컬러 변경 필요
        return register
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setUpUI()
        registerTapped()
    }
   
    private func setTermsStack() -> UIStackView {
        let checkBoxImage = UIImageView(image: UIImage(named: "check_1x"))
        checkBoxImage.contentMode = .scaleAspectFit
        checkBoxImage.snp.makeConstraints { $0.size.equalTo(24) }
        
        let termsTitle = UILabel()
        termsTitle.text = "이용약관(필수)"
        termsTitle.font = .systemFont(ofSize: 14)
        termsTitle.textColor = .lightGray
        
        let stack = UIStackView(
            arrangedSubviews: [checkBoxImage, termsTitle])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        return stack
    }
    
    private func setPrivacyStack() -> UIStackView {
        let checkBoxImage = UIImageView(image: UIImage(named: "check_1x"))
        checkBoxImage.contentMode = .scaleAspectFit
        checkBoxImage.snp.makeConstraints { $0.size.equalTo(24) }
        
        let privacyTitle = UILabel()
        privacyTitle.text = "이용약관(필수)"
        privacyTitle.font = .systemFont(ofSize: 14)
        privacyTitle.textColor = .lightGray
        
        let stack = UIStackView(
            arrangedSubviews: [checkBoxImage, privacyTitle])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        return stack
    }
    
    private func setUpUI() {
        
        [nicknameViewTitle, nicknameHeader, nicknameField, termsStack,
         privacyStack, registerButton].forEach({view.addSubview($0)})
        
        nicknameViewTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        nicknameHeader.snp.makeConstraints { make in
            make.top.equalTo(nicknameViewTitle.snp.bottom).offset(30)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        nicknameField.snp.makeConstraints { make in
            make.top.equalTo(nicknameHeader.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
        
        termsStack.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        privacyStack.snp.makeConstraints { make in
            make.top.equalTo(termsStack.snp.bottom).offset(6)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)

        }
    }
    
    private func registerTapped() {
        registerButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                let codeShareView = CodeShareVIewController()
                self?.navigationController?.pushViewController(codeShareView, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
