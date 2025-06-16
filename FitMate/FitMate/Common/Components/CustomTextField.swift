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
    let overLimitRelay = PublishRelay<Void>()
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray] // 컬러 변경 필요
        )
        self.contentVerticalAlignment = .center
        self.borderStyle = .line
        self.layer.borderColor = UIColor.systemPurple.cgColor // 컬러 변경 필요
        self.layer.borderWidth = 1.5
        self.backgroundColor = .darkGray // 컬러 변경 필요
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.delegate = self
    }
    
}

/// shouldChangeCharactersIn는 텍스트 필드에 사용자가 입력할 때마다 호출되는 메서드
///
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
            overLimitRelay.accept(())
            return false
        }
        /// 제한 범위 이내면 입력 허용
        return true
    }
}


