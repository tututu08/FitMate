//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let loginLabel: UILabel = {
        let login = UILabel()
        login.text = "로그인"
        login.font = .systemFont(ofSize: 20)
        login.textColor = .white
        return login
    }()
    
    private let idLabel: UILabel = {
        let id = UILabel()
        id.text = "아이디"
        id.font = .systemFont(ofSize: 14)
        id.textColor = .lightGray
        return id
    }()
    
    private let idTextField = CustomTextField(placeholder: "아이디를 입력해주세요")
    
    private let passwordLabel: UILabel = {
        let password = UILabel()
        password.text = "비밀번호"
        password.font = .systemFont(ofSize: 14)
        return password
    }()
    
    private let passwordField = CustomTextField(placeholder: "비밀번호를 입력해주세요")
    
    private let saveIDButton: UIButton = {
        let saveID = UIButton()
        saveID.setTitle("아이디 저장", for: .normal)
        saveID.setTitleColor(.darkGray, for: .normal)
        saveID.titleLabel?.font = .systemFont(ofSize: 14)
        saveID.tintColor = .systemPurple
        saveID.contentHorizontalAlignment = .left // 체크박스 좌측 배치
        return saveID
    }()
    
    private let findIDandPW: UIButton = {
        let findBtn = UIButton()
        findBtn.setTitle("아이디/비밀번호 찾기", for: .normal)
        findBtn.setTitleColor(.lightGray, for: .normal) // 컬러 변경 필요
        findBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14) // 폰트 변경 필요
        return findBtn
    }()
    
    private let loginButton: UIButton = {
        let loginBtn = UIButton()
        loginBtn.setTitle("로그인", for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22) // 폰트 변경 필요
        loginBtn.backgroundColor = .systemPurple // 컬러 변경 필요
        return loginBtn
    }()
    
    private let kakaoLogo: UIImageView = {
        let kakaoLabel = UIImageView()
        kakaoLabel.image = UIImage(named: "kakaoLogo")
        kakaoLabel.contentMode = .scaleAspectFit
        return kakaoLabel
    }()
    
    private let googleLogo: UIImageView = {
        let googleLabel = UIImageView()
        googleLabel.image = UIImage(named: "googleLogo")
        googleLabel.contentMode = .scaleAspectFit
        return googleLabel
    }()
    
    private let appleLogo: UIImageView = {
        let appleLabel = UIImageView()
        appleLabel.image = UIImage(named: "appleLogo")
        appleLabel.contentMode = .scaleAspectFit
        return appleLabel
    }()
    
    private let askingSignUp: UILabel = {
        let askingSignUp = UILabel()
        askingSignUp.text = "아직 회원이 아니신가요?"
        askingSignUp.font = .systemFont(ofSize: 14)
        askingSignUp.textColor = .lightGray // 컬러 변경 필요
        return askingSignUp
    }()
    
    private let signUpButton: UIButton = {
        let signUpBtn = UIButton()
        let title = "회원가입"
        
        let titleEffect = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemPurple,
                .font: UIFont.systemFont(ofSize: 16) // 폰트 변경 필요
            ])
        signUpBtn.setAttributedTitle(titleEffect, for: .normal)
        return signUpBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 컬러 변경 필요

        [loginLabel, idLabel, idTextField, passwordLabel,
         passwordField, saveIDButton, findIDandPW, loginButton,
         kakaoLogo, googleLogo, appleLogo, askingSignUp, signUpButton].forEach({view.addSubview($0)})
        setConstraints()
    }
    
    private func setConstraints() {
        loginLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(idLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        saveIDButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        findIDandPW.snp.makeConstraints { make in
            make.top.equalTo(passwordField).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(saveIDButton.snp.bottom).offset(42)
            make.width.equalTo(335)
            make.height.equalTo(60)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        kakaoLogo.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(48)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(82)
        }
        
        googleLogo.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(48)
            make.leading.equalTo(kakaoLogo.snp.trailing).inset(16)
        }
        
        appleLogo.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(48)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        askingSignUp.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(52)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(92)
            make.trailing.equalTo(signUpButton.snp.leading).inset(4)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(52)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(88)
            
        }
        
        
    }
}
