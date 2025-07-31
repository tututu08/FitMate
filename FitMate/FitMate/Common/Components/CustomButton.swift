//
//  SocialLoginButton.swift
//  FitMate
//
//  Created by soophie on 6/18/25.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = .background900
        return label
    }()
    
    private lazy var loginStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, loginTitleLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private let radioButtonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let languageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = .background900
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(for type: SocialLoginType) {
        loginStack.isHidden = false
        
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 8
        clipsToBounds = true
        
        iconImageView.image = UIImage(named: type.iconName)
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        loginTitleLabel.text = type.title
        loginTitleLabel.textColor = type.textColor
    }
    
    func setTextOnlyUI(for type: TextOnlyType) {
        loginStack.isHidden = true
        
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 8
        clipsToBounds = true
        
        languageTitleLabel.text = type.title
        languageTitleLabel.textColor = type.textColor
        
        if let buttonImageName = type.buttonImageName {
            radioButtonImageView.image = UIImage(named: buttonImageName)
        }
    }
    
    private func setupLayout() {
        addSubview(loginStack)
        [loginStack, radioButtonImageView, languageTitleLabel].forEach({addSubview($0)})
        loginStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        radioButtonImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(22)
            make.size.equalTo(20)
        }
        
        languageTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
