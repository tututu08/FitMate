//
//  CustomTextField.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit


class CustomTextField: UITextField {
    
  
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray] // 컬러 변경 필요
        )

        self.borderStyle = .line
        self.layer.borderColor = UIColor.systemPurple.cgColor // 컬러 변경 필요
        self.layer.borderWidth = 1.5
        self.backgroundColor = .darkGray // 컬러 변경 필요
        self.translatesAutoresizingMaskIntoConstraints = false
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 기존 상태에서의 플레이스 홀더 위치
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    }
    /// 입력 중의 텍스트 위치
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    }
    /// 두 메서드는 각각 다른 상황에서 텍스트 위치를 제어함
    ///placeholder와 실제 텍스트의 위치가 따로 놀지 않게 하려면 둘 다 같은 inset을 적용해야 자연스러움

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.rightViewRect(forBounds: bounds)
        return original.offsetBy(dx: -8, dy: 0)
    }
    
}
