//
//  CustomTextField.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class CustomTextField: UITextField {
    // 텍스트 필드에 입력될 문자열 리밋 설정
    var stringLimit: Int = Int.max
    
    // 기존 코드
    //let overLimitRelay = PublishRelay<Void>()
    
    // MARK: 알림 enum 타입으로 변경
    let overLimitRelay = PublishRelay<SystemAlertType>()
    
    // 텍스트 변경을 외부에서 감지
    let textRelay = BehaviorRelay<String>(value: "")
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray] // 컬러 변경 필요
        )
        self.contentVerticalAlignment = .center
        self.textColor = .white
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.borderStyle = .line
        self.layer.borderColor = UIColor.systemPurple.cgColor // 컬러 변경 필요
        self.layer.borderWidth = 1.5
        self.backgroundColor = .darkGray // 컬러 변경 필요
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftPadding()
        // 텍스트 변경 이벤트 등록
        self.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.delegate = self
    }
    
    // MARK: - Editing Changed: 사용자 입력이 확정된 후 텍스트 반영
    // 아래 shouldChangeCharactersIn 함수는 입력 반영 전에 호출되어 제대로 닉네임 값을 가져오지 못함
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        textRelay.accept(textField.text ?? "")
    }
    
}

/// shouldChangeCharactersIn는 텍스트 필드에 사용자가 입력할 때마다 호출되는 메서드
/// shouldChangeCharactersIn 입력이 반영되기 전 에 호출
extension CustomTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //// 현재 텍스트 필드에 입력되어 있는 문자열
        let fillInText = textField.text ?? ""
        
        /// 입력 범위 range 설정
        guard let stringRange = Range(range, in: fillInText) else { return false }
        
        /// 사용자가 입력하려는 값을 기존 문자열에 반영한 결과
        let updatedText = fillInText.replacingCharacters(in: stringRange, with: string)
        
        /// 글자 수가 제한을 초과한 경우 입력 막고
        if updatedText.count > stringLimit {
            // 기존 코드
            // overLimitRelay.accept(())
            
            // MARK: 오류 정보 바로 전달
            overLimitRelay.accept(.overLimit)
            textRelay.accept(updatedText)
            return false
        }
        
        if string.contains(" ") {
            // 필요 시 사용자에게 알림 전달
            overLimitRelay.accept(.dontUseSpacing)
            textRelay.accept(updatedText) 
            return false
        }
        /// 제한 범위 이내면 입력 허용
        return true
    }
    
    /// UITextField의 leftView는 내부 좌측에 뷰를 추가해서 텍스트 입력 시작 위치를 오른쪽으로 밀어주는 용도
    /// leftViewMode를 항상 활성화 시켜서 padding 효과를 나타내주는것처럼 해줍니다.
    func leftPadding() {
        // paddingView의 크기를 텍스트필드 높이에 맞추기
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always // 항상 이 뷰를 보이게 설정
    }
}


