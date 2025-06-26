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
    private var hasIcon: UIImageView? = nil
    private let alertTitle = UILabel()
    private let alertMessage = UILabel()
    private let buttonStack = UIStackView()
    private let background = UIView() // alert 뒤에 화면
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(
        icon: UIImageView? = nil,
        title: String? = nil,
        message: String? = nil,
        resumeButton: UIButton? = nil,
        stopButton: UIButton? = nil
    ) {
        if let icon = icon {
            self.hasIcon = icon
            icon.contentMode = .scaleAspectFit
            addSubview(icon)
        }
        [alertTitle, alertMessage,
         buttonStack].forEach({addSubview($0)})
        alertTitle.text = title
        alertTitle.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        alertTitle.textColor = .background900
        alertTitle.textAlignment = .center
        alertTitle.numberOfLines = 0
        
        if let message = message {
            let alertStyle = NSMutableParagraphStyle()
            alertStyle.lineSpacing = 6
            alertStyle.alignment = .center
            
            let messageStyle = NSAttributedString(
                string: message,
                attributes: [
                    .font: UIFont(name: "Pretendard-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.background400,
                    .paragraphStyle: alertStyle
                ]
            )
            alertMessage.numberOfLines = 0
            alertMessage.attributedText = messageStyle
        }
        
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        
        resumeButton?.layer.cornerRadius = 4
        stopButton?.layer.cornerRadius = 4
        if let resume = resumeButton {
            buttonStack.addArrangedSubview(resume)
        }
        
        if let stop = stopButton {
            buttonStack.addArrangedSubview(stop)
        }
    }
    
    func setConstraints() {
        
        if let icon = hasIcon {
            icon.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(32)
                make.leading.trailing.equalToSuperview().inset(120)
                make.height.equalTo(icon.snp.width).multipliedBy(1.0)
            }
            
            alertTitle.snp.makeConstraints{ make in
                make.top.equalTo(icon.snp.bottom).offset(32)
                make.leading.trailing.equalToSuperview().inset(60.5)
            }
        } else {
            alertTitle.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(32)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        }
        
        alertMessage.snp.makeConstraints { make in
            make.top.equalTo(alertTitle.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(26)
            make.bottom.lessThanOrEqualTo(buttonStack.snp.top).offset(-24)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(alertMessage.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(20)
        }
        
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
        func buildAlert() -> CustomAlertView {
            let alert = CustomAlertView()
            alert.setUp(
                icon: icon,
                title: title,
                message: message,
                resumeButton: resumeButton,
                stopButton: stopButton
            )
            alert.setConstraints()
            return alert
        }
    }
}
