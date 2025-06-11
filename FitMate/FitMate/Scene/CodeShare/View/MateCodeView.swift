//
//  MateCodeView.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import SnapKit

class MateCodeView: UIView {
    
    let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    let backButton: UIButton = {
        let back = UIButton()
        back.setImage(UIImage(named: "backButton"), for: .normal)
        back.setTitle("              메이트 코드 입력", for: .normal)
        back.setTitleColor(.white, for: .normal)
        back.titleLabel?.font = .systemFont(ofSize: 20)
        back.contentHorizontalAlignment = .leading
        return back
    }()
    
    let mateDefaultAvatar: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.image = UIImage(named: "mumu")
        return image
    }()
    
    let fillInMateCode = CustomTextField(placeholder: "파트너 코드를 입력해주세요")
    
    let completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("입력 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
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
        [customNavBar, mateDefaultAvatar, fillInMateCode, completeButton].forEach { addSubview($0) }
        customNavBar.addSubview(backButton)
    }

    private func setupLayout() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        mateDefaultAvatar.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom).offset(86)
            make.leading.trailing.equalToSuperview().inset(110)
            make.height.equalTo(mateDefaultAvatar.snp.width)
        }

        fillInMateCode.snp.makeConstraints { make in
            make.top.equalTo(mateDefaultAvatar.snp.bottom).offset(83)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }

        completeButton.snp.makeConstraints { make in
            make.top.equalTo(fillInMateCode.snp.bottom).offset(20)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)
        }
    }
}
