//
//  SIgnUpViewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SIgnUpViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let signUpLabel: UILabel = {
        let signUp = UILabel()
        signUp.text = "회원가입"
        signUp.textColor = .white
        signUp.font = .systemFont(ofSize: 20)
        return signUp
    }()
    
    private let nickNameHeader = CustomHeader(text: "닉네임")
    private let nickNameField = CustomTextField(placeholder: "닉네임을 입력해주세요", isSecure: false)
    
    private let idHeader = CustomHeader(text: "아이디")
    private let idField = CustomTextField(placeholder: "아이디를 입력해주세요", isSecure: false)
    
    private let passwordHeader = CustomHeader(text: "비밀번호")
    private let passwordField = CustomTextField(placeholder: "비밀번호를 입력해주세요", isSecure: true)
    
    private let checkPasswordHeader = CustomHeader(text: "비밀번호 확인")
    private let checkPasswordLabel = CustomTextField(placeholder: "비밀번호를 한번 더 입력해주세요", isSecure: true)
    
    private let termsCheckBox: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "check_1x"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let termasLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var termsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [saveIDCheckBox, saveIDLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    

    

}
