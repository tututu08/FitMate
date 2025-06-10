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
    
    private let eyeToggleButton = UIButton()
    private let disposeBag = DisposeBag()
    private let isSecureRelay = BehaviorRelay<Bool>(value: true)
    
    init(placeholder: String /*isSecure: Bool = true*/) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.lightGray] // 컬러 변경 필요
        )
//        self.isSecureTextEntry = isSecure
        self.borderStyle = .line
        self.layer.borderColor = UIColor.systemPurple.cgColor // 컬러 변경 필요
        self.layer.borderWidth = 1.5
        self.backgroundColor = .darkGray // 컬러 변경 필요
        self.translatesAutoresizingMaskIntoConstraints = false
        
//        setEyeToggle()
        bind()
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
    
//    func setEyeToggle() {
//        eyeToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
//        eyeToggleButton.tintColor = .lightGray
//        
//        // 우측 배치
//        rightView = eyeToggleButton
//        rightViewMode = .always
//    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.rightViewRect(forBounds: bounds)
        return original.offsetBy(dx: -8, dy: 0)
    }
    
    func bind() {
        eyeToggleButton.rx.tap
            .withLatestFrom(isSecureRelay) // 옵저버블의 최신값 가져옴
            .map { !$0 } // 값 변형
            .bind(to: isSecureRelay) // bind는 종결 연산자라 마지막에 써야 함
        
        isSecureRelay
            .asDriver(onErrorJustReturn: true)
            .drive(onNext:{ [weak self] isSecure in
                self?.isSecureTextEntry = isSecure
                
                let icon = isSecure ? "eye.slash" : "eye"
                self?.eyeToggleButton.setImage(UIImage(systemName: icon), for: .normal)
            })
            .disposed(by: disposeBag)
        
    }
    
}
