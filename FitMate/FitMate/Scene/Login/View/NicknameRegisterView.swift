//
//  NicknameRegisterView.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import SnapKit

class NicknameView: BaseView {

    let nicknameViewTitle: UILabel = {
        let title = UILabel()
        title.text = "닉네임 등록"
        title.textColor = .white
        title.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return title
    }()
    
    let nicknameHeader = CustomHeaderLabel(text: "닉네임")
    let nicknameField = CustomTextField(placeholder: "닉네임을 입력해주세요")
    
    let termsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkBox"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let privacyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "checkBox"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
//    let termsLabel: UIButton = {
//        let terms = UIButton()
//        terms.setTitle("이용약관(필수)", for: .normal)
//        terms.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
//        terms.titleLabel?.textColor = .background400
//        return terms
//    }()
//    
//    let privacyLabel: UIButton = {
//        let privacy = UIButton()
//        privacy.setTitle("개인정보 수집 및 이용동의(필수)", for: .normal)
//        privacy.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
//        privacy.titleLabel?.textColor = .background400
//        return privacy
//    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관(필수)"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background400
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "개인정보 수집 및 이용동의(필수)"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background400
        label.isUserInteractionEnabled = true
        return label
    }()

    
    lazy var termsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termsButton, termsLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    lazy var privacyStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [privacyButton, privacyLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    let validationMessageLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Pretendard-Regular", size: 12)
        label.textColor = .background400
        label.isHidden = true
        return label
    }()
    
    let registerButton: UIButton = {
        let register = UIButton()
        register.setTitle("등록완료", for: .normal)
        register.setTitleColor(.white, for: .normal)
        register.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        register.backgroundColor = .primary500
        register.layer.cornerRadius = 4
        register.clipsToBounds = true
        return register
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        configureUI()
        setLayoutUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureUI() {
        backgroundColor = .black
        [nicknameViewTitle, nicknameHeader, nicknameField,
         termsStack, privacyStack, validationMessageLabel,registerButton].forEach { addSubview($0) }
    }
    
    override func setLayoutUI() {
        nicknameViewTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(0)
            make.centerX.equalToSuperview()
        }
        
        nicknameHeader.snp.makeConstraints { make in
            make.top.equalTo(nicknameViewTitle.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(32)
        }
        
        nicknameField.snp.makeConstraints { make in
            make.top.equalTo(nicknameHeader.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        validationMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        termsStack.snp.makeConstraints { make in
            make.top.equalTo(validationMessageLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        privacyStack.snp.makeConstraints { make in
            make.top.equalTo(termsStack.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(20)
        }
        
        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)
        }
        
        termsButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        privacyButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
}
