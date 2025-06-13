//
//  NicknameRegisterView.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import SnapKit

class NicknameView: UIView {

    let nicknameViewTitle: UILabel = {
        let title = UILabel()
        title.text = "닉네임 등록"
        title.textColor = .white
        title.font = .systemFont(ofSize: 20)
        return title
    }()
    
    let nicknameHeader = CustomHeaderLabel(text: "닉네임")
    let nicknameField = CustomTextField(placeholder: "닉네임을 입력해주세요")
    
    lazy var termsStack: UIStackView = {
        let image = UIImageView(image: UIImage(named: "check_1x"))
        image.contentMode = .scaleAspectFit
        image.snp.makeConstraints { $0.size.equalTo(24) }
        
        let label = UILabel()
        label.text = "이용약관(필수)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [image, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    lazy var privacyStack: UIStackView = {
        let image = UIImageView(image: UIImage(named: "check_1x"))
        image.contentMode = .scaleAspectFit
        image.snp.makeConstraints { $0.size.equalTo(24) }
        
        let label = UILabel()
        label.text = "이용약관(필수)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [image, label])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    let registerButton: UIButton = {
        let register = UIButton()
        register.setTitle("로그인", for: .normal)
        register.setTitleColor(.white, for: .normal)
        register.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        register.backgroundColor = .systemPurple
        register.layer.cornerRadius = 4
        register.clipsToBounds = true
        return register
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [nicknameViewTitle, nicknameHeader, nicknameField,
         termsStack, privacyStack, registerButton].forEach { addSubview($0) }
    }
    
    private func setupLayout() {
        nicknameViewTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(-23)
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
        
        termsStack.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom).offset(20)
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
    }
}
