//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import AuthenticationServices

class LoginView: BaseView {
    
    private let fitMateLogo: UIImageView = {
       let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        logo.image = UIImage(named: "logo_bgX")
       return logo
    }()
    
    let kakaoLogin: SocialLoginButton = {
        let button = SocialLoginButton()
        button.configureUI(for: .kakao)
        return button
    }()
    
    let googleLogin: SocialLoginButton = {
        let button = SocialLoginButton()
        button.configureUI(for: .google)
        return button
    }()
    
    let appleLogin: SocialLoginButton = {
        let button = SocialLoginButton()
        button.configureUI(for: .apple)
        return button
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
        backgroundColor = .background800
        
        [fitMateLogo, kakaoLogin, googleLogin,
         appleLogin].forEach({addSubview($0)})
    }
    
    override func setLayoutUI() {
        fitMateLogo.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(144)
            make.centerX.equalToSuperview()
//            make.leading.trailing.equalTo(87)
            make.height.equalTo(60)
        }
       
        kakaoLogin.snp.makeConstraints { make in
            make.top.equalTo(fitMateLogo.snp.bottom).offset(140)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        googleLogin.snp.makeConstraints { make in
            make.top.equalTo(kakaoLogin.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        appleLogin.snp.makeConstraints { make in
            make.top.equalTo(googleLogin.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }
}
