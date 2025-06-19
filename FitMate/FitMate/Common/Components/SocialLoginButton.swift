//
//  SocialLoginButton.swift
//  FitMate
//
//  Created by soophie on 6/18/25.
//

enum SocialLoginType {
    case kakao, google, apple
    
    var title: String {
        switch self {
        case .kakao: return "카카오로 시작하기"
        case .google: return "Google로 시작하기"
        case .apple: return "Apple로 시작하기"
        }
    }
    
    var iconName: String {
        switch self {
        case .kakao: return "kakao_renew"
        case .google: return "google_renew"
        case .apple: return "apple_renew"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .kakao: return UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
        case .google: return .white
        case .apple: return .background900
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .kakao: return .background900
        case .google: return .background900
        case .apple: return .white
        }
    }
}

import UIKit
import SnapKit

class SocialLoginButton: UIButton {
    
    let iconImageView: UIImageView = {
        let iconImage = UIImageView()
        iconImage.contentMode = .scaleAspectFit
        return iconImage
    }()
    
    let loginTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Pretendard-Medium", size: 20)
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(for type: SocialLoginType) {
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 8
        clipsToBounds = true
        
        iconImageView.image = UIImage(named: type.iconName)
        loginTitle.text = type.title
        loginTitle.textColor = type.textColor
        
        addSubview(iconImageView)
        addSubview(loginTitle)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(73.5) // 공통 간격
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        loginTitle.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
}
