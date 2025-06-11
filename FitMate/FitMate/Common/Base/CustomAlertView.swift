//
//  CustomAlertView.swift
//  FitMate
//
//  Created by Sophie on 6/8/25.
//

import UIKit
import SnapKit

class CustomAlertView: UIView {

    private let containerVIew = UIView() // alert 본체
    private let iconContainer = UIView()
    private let alertTitle = UILabel()
    private let alertMessage = UILabel()
    private let buttonStack = UIStackView()
    private let background = UIView() // alert 뒤에 화면
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class AlertBuilder {
        // alert 본체를 구성할 요소들
        private var icon: UIImageView?
        private var title: String?
        private var message: String?
        private var resumeButton: UIButton?
        private var stopButton: UIButton?
        
        func setIcon(_ icon: UIImageView) -> AlertBuilder {
            self.icon = icon
            /// 함수 자체를 chaining
            /// 다음 호출을 이어가기 위한 객체(self) 자체를 반환해야지
            /// icon을 리턴하면 다른 요소들 설정 메서드를 이어서 못씀
            /// return self -> builder pattern의 핵심 문법
            return self
        }
        
        func setTitle(_ title: String) -> AlertBuilder {
            self.title = title
            return self
        }
        
        func setMessage(_ message: String) -> AlertBuilder {
            self.message = message
            return self
        }
        
        func setResumeButton(_ button: UIButton) -> AlertBuilder {
            self.resumeButton = button
            return self
        }
        
        func setStopButton(_ button: UIButton) -> AlertBuilder {
            self.stopButton = button
            return self
        }
        
        // alert 본체 set하는 메서드
        func buildAlert() -> UIView {
            
            
            let alertView: UIView = {
                let view = UIView()
                view.backgroundColor = .white
                return view
            }()
            
            alertView.snp.makeConstraints { make in
                make.height.equalTo(349)
                make.width.equalTo(326)
            }
            
            guard let icon = self.icon else {
                    return alertView // 또는 return UIView() 등 선택 가능
                }
            
            let alertTitle: UILabel = {
                let titleLabel = UILabel()
                titleLabel.text = self.title
                titleLabel.font = UIFont.systemFont(ofSize: 24)
                titleLabel.textColor = .darkGray
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 0
                return titleLabel
            }()
            
            let alertMessage: UILabel = {
                let messageLabel = UILabel()
                messageLabel.text = self.message
                messageLabel.font = UIFont.systemFont(ofSize: 14)
                messageLabel.textColor = .darkGray
                messageLabel.textAlignment = .center
                messageLabel.numberOfLines = 0
                return messageLabel
            }()
            
            let buttonStack: UIStackView = {
                let stack = UIStackView()
                stack.axis = .horizontal
                stack.spacing = 20
                stack.distribution = .fillEqually
                return stack
            }()
            
            if let resume = resumeButton {
                buttonStack.addArrangedSubview(resume)
            }
            
            if let stop = stopButton {
                buttonStack.addArrangedSubview(stop)
            }
            [icon, alertTitle, alertMessage, buttonStack].forEach({alertView.addSubview($0)})
            
            icon.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(32)
                make.leading.trailing.equalToSuperview().inset(120)
                make.height.equalTo(icon.snp.width).multipliedBy(1.0)
            }
            
            alertTitle.snp.makeConstraints{ make in
                make.top.equalTo(icon.snp.bottom).offset(32)
                make.leading.trailing.equalToSuperview().inset(60.5)
            }
            
            alertMessage.snp.makeConstraints { make in
                make.top.equalTo(alertTitle.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(26)
            }
            
            buttonStack.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(26)
                make.leading.trailing.equalToSuperview().inset(20)
            }
            
            return alertView
        }
    }
}
