//
//  LanguagesView.swift
//  FitMate
//
//  Created by sophie on 7/23/25.
//

import UIKit
import SnapKit

class LanguagesView: BaseView {
    
    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "언어 선택"
        title.textColor = .white
        title.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return title
    }()
    
    private let options: [LanguagesOption] = [.korean, .english, .japanese, .chinese]
    private var languagesButton: [CustomButton] = []
    var languagesButtons: [CustomButton] {
        return self.languagesButton
    }
    
    private let languageButtonStack: UIStackView = {
       let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 43
        stack.distribution = .fillEqually
        return stack
    }()
    
    let selectButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("선택 완료", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        btn.backgroundColor = .primary500
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background800
        configureUI()
        setLayoutUI()
        setButtonStack()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        [customNavBar, languageButtonStack, selectButton].forEach { addSubview($0) }
        
        customNavBar.addSubview(titleLabel)
    }
    
    override func setLayoutUI() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        languageButtonStack.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom).offset(110)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(92 * options.count)
        }
        
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(languageButtonStack.snp.bottom).offset(93)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(selectButton.snp.width).multipliedBy(0.179)
        }
    }
    
    private func setButtonStack() {
        options.forEach { option in
            let button = CustomButton()
            button.setTextOnlyUI(for: .language(type: option, isSelected: false))
            languagesButton.append(button)
            languageButtonStack.addArrangedSubview(button)
        }
    }
    
    func updateSelectedLanguage(_ selected: LanguagesOption?) {
        for (index, option) in options.enumerated() {
            let isSelected = (option == selected)
            languagesButton[index].setTextOnlyUI(for: .language(type: option, isSelected: isSelected))
        }
    }
    
}
