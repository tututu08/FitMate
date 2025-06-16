//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    private let fitMateLogo: UIImageView = {
       let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        logo.image = UIImage(named: "logo_bgX")
       return logo
    }()
    
    let kakaoLogin: UIButton = {
        let kakaoLabel = UIButton()
        kakaoLabel.setImage(UIImage(named: "kakao"), for: .normal)
        kakaoLabel.contentMode = .scaleAspectFit
        return kakaoLabel
    }()
    
    let googleLogin: UIButton = {
        let googleLabel = UIButton()
        googleLabel.setImage(UIImage(named: "google"), for: .normal)
        googleLabel.contentMode = .scaleAspectFit
        return googleLabel
    }()
    
    let appleLogin: UIButton = {
        let appleLabel = UIButton()
        appleLabel.setImage(UIImage(named: "apple"), for: .normal)
        appleLabel.contentMode = .scaleAspectFit
        return appleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        backgroundColor = .background800
        
        [fitMateLogo, kakaoLogin, googleLogin,
         appleLogin].forEach({addSubview($0)})
    }
    
    func setUpLayout() {
        fitMateLogo.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(144)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
       
        kakaoLogin.snp.makeConstraints { make in
            make.top.equalTo(fitMateLogo.snp.bottom).offset(140)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
            //make.width.equalTo(343)
        }
        
        googleLogin.snp.makeConstraints { make in
            make.top.equalTo(kakaoLogin.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
            //make.width.equalTo(343)
        }
        
        appleLogin.snp.makeConstraints { make in
            make.top.equalTo(googleLogin.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
            //make.width.equalTo(343)
        }
    }
}
