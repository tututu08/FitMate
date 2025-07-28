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
    
    /// 언어 옵션 배열 -> options 를 기반으로 버튼을 생성하고 스택뷰에 추가하는 메서드
    /// 초기 UI 구성 시 사용되고 유저가 버튼 선택 전 초기 상태를 설정
    private func setButtonStack() {
        options.forEach { option in
            let button = CustomButton()
            button.setTextOnlyUI(for: .language(type: option, isSelected: false))
            languagesButton.append(button) // 내부 배열에 버튼 저장 → 추후 상태 업데이트 등에 활용
            languageButtonStack.addArrangedSubview(button) // 스택뷰에 버튼 추가 → 화면에 표시
        }
    }
    
    /// 선택된 언어에 따라 버튼 UI 업데이트하는 메서드
    /// 모든 버튼을 순회하면서 선택된 버튼만 강조 표시하고 나머지는 선택 해제 상태로 설정
    func updateSelectedLanguage(_ selected: LanguagesOption?) {
        for (index, option) in options.enumerated() {
            let isSelected = (option == selected) // 현재 옵션이 선택된 언어와 일치하는지 확인
            languagesButton[index].setTextOnlyUI(for: .language(type: option, isSelected: isSelected)) // 해당 버튼에 선택 상태에 따라 UI 갱신
        }
    }
}
