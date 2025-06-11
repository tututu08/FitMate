//
//  CustomTextField.swift
//  FitMate
//
//  Created by Sophie on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
    }
    
   override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.rightViewRect(forBounds: bounds)
        return original.offsetBy(dx: -8, dy: 0)
    }
    
}
