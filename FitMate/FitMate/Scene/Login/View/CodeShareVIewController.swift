//
//  CodeShareVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CodeShareVIewController: UIViewController {

    private let codeShareViewTitle: UILabel = {
        let title = UILabel()
        title.text = "코드 공유"
        title.textColor = .white // 색상 변경
        title.font = .systemFont(ofSize: 20) // 폰트 변경
        return title
    }()
    
    private let guideMent: UILabel = {
        let guide = UILabel()
        guide.text = "파트너 연결 후 시작해보세요"
        guide.textColor = .lightGray // 색상 변경
        guide.font = .systemFont(ofSize: 16) // 폰트 변경
        return guide
    }()
    
    private let defaultAvatarImage: UIImageView = {
        let defaultAvatar = UIImageView()
        defaultAvatar.contentMode = .scaleAspectFit
        defaultAvatar.clipsToBounds = true
        defaultAvatar.image = UIImage(named: "mumu") //  이미지 추가
        return defaultAvatar
    }()
    
    private let copyMyCodeButton: UIButton = {
        let myCode = UIButton()
        myCode.setTitle("나의 코드 복사", for: .normal)
        myCode.setTitleColor(.white, for: .normal)
        myCode.titleLabel?.font = UIFont.systemFont(ofSize: 22) // 폰트 변경 필요
        myCode.backgroundColor = .systemPurple // 컬러 변경 필요
        return myCode
    }()
    
    private let mateCodeButton: UIButton = {
        let mateCode = UIButton()
        mateCode.setTitle("메이트 코드 입력", for: .normal)
        mateCode.setTitleColor(.white, for: .normal)
        mateCode.titleLabel?.font = UIFont.systemFont(ofSize: 22) // 폰트 변경 필요
        mateCode.backgroundColor = .systemPurple // 컬러 변경 필요
        return mateCode
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // 컬러 변경 필요
        [codeShareViewTitle, guideMent, defaultAvatarImage,
         copyMyCodeButton, mateCodeButton].forEach({view.addSubview($0)})
        
        setConstraints()
    }
    
    private func setConstraints() {
        codeShareViewTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        guideMent.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(113)
            make.leading.trailing.equalToSuperview().inset(94)
        }
        
        defaultAvatarImage.snp.makeConstraints { make in
            make.top.equalTo(guideMent.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(110)
            make.height.equalTo(defaultAvatarImage.snp.width).multipliedBy(1.0)
        }
        
        copyMyCodeButton.snp.makeConstraints { make in
            make.top.equalTo(defaultAvatarImage.snp.bottom).offset(83)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)

        }
        
        mateCodeButton.snp.makeConstraints { make in
            make.top.equalTo(copyMyCodeButton.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)

        }
    }
    
    private func mateCodeButtonTapped() {
        mateCodeButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                let moveToMateCode = MateCodeViewController()
                self?.navigationController?.pushViewController(moveToMateCode, animated: true)
            })
    }

}
