//
//  CustomAlertView.swift
//  FitMate
//
//  Created by Sophie on 6/8/25.
//

import UIKit
import SnapKit

class CustomAlertView: UIView {
    
    private let containerView = UIView() //  알림 전체를 담는 박스 -> 기본 배경 뷰에 올라감
    private var hasIcon: UIImageView? = nil // 아이콘이 있으면 이 프로퍼티에 저장됨
    let alertTitle = UILabel() // 제목 라벨 (외부에서 접근 가능)
    private let alertMessage = UILabel() // 본문 메시지 라벨
    private let buttonStack = UIStackView() // 버튼들을 담는 가로 스택 뷰
    
    // 초기화: 배경색과 cornerRadius 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Alert 뷰 구성 요소 설정 함수
    func setUp(
        icon: UIImageView? = nil,
        title: String? = nil,
        message: String? = nil,
        resumeButton: UIButton? = nil,
        stopButton: UIButton? = nil
    ) {
        // 아이콘이 있을 경우 추가
        if let icon = icon {
            self.hasIcon = icon
            icon.contentMode = .scaleAspectFit
            addSubview(icon)
        }
        // 타이틀, 메시지, 버튼 스택뷰 추가
        [alertTitle, alertMessage,
         buttonStack].forEach({addSubview($0)})
        
        // 제목 스타일 설정
        alertTitle.text = title
        alertTitle.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        alertTitle.textColor = .background900
        alertTitle.textAlignment = .center
        alertTitle.numberOfLines = 0
        
        // 메시지가 있을 경우 스타일 지정
        if let message = message {
            let alertStyle = NSMutableParagraphStyle()
            alertStyle.lineSpacing = 6
            alertStyle.alignment = .center
            // 메시지에 스타일 적용 (line spacing 포함)
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
        
        // 버튼 스택 기본 설정
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        // 버튼 코너 라운드 적용
        resumeButton?.layer.cornerRadius = 4
        stopButton?.layer.cornerRadius = 4
        // 버튼이 있을 경우 스택뷰에 추가
        if let resume = resumeButton {
            buttonStack.addArrangedSubview(resume)
        }
        
        if let stop = stopButton {
            buttonStack.addArrangedSubview(stop)
        }
    }
    // 오토레이아웃 설정 함수
    func setConstraints() {
        // 아이콘이 있을 경우 레이아웃 포함
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
            //  아이콘이 없으면 타이틀은 상단에서 시작
            alertTitle.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(32)
                make.leading.trailing.equalToSuperview().inset(20)
            }
        }
        // 메시지 레이아웃
        alertMessage.snp.makeConstraints { make in
            make.top.equalTo(alertTitle.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(26)
            make.bottom.lessThanOrEqualTo(buttonStack.snp.top).offset(-24)
        }
        // 버튼 스택 레이아웃
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(alertMessage.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    // Builder 패턴 -> alertView 생성을 유연하게 만들기 위한 클래스
    class AlertBuilder {
        // alert 본체를 구성할 요소들
        private var icon: UIImageView?
        private var title: String?
        private var message: String?
        private var resumeButton: UIButton?
        private var stopButton: UIButton?
        // 아이콘 설정 메서드
        func setIcon(_ icon: UIImageView) -> AlertBuilder {
            self.icon = icon
            /// 함수 자체를 chaining
            /// 다음 호출을 이어가기 위한 객체(self) 자체를 반환해야지
            /// icon을 리턴하면 다른 요소들 설정 메서드를 이어서 못씀
            /// return self -> builder pattern의 핵심 문법
            return self
        }
        // 타이틀 설정
        func setTitle(_ title: String) -> AlertBuilder {
            self.title = title
            return self
        }
        // 메시지 설정
        func setMessage(_ message: String) -> AlertBuilder {
            self.message = message
            return self
        }
        // 왼쪽 버튼 설정
        func setResumeButton(_ button: UIButton) -> AlertBuilder {
            self.resumeButton = button
            return self
        }
        // 오른쪽 버튼 설정
        func setStopButton(_ button: UIButton) -> AlertBuilder {
            self.stopButton = button
            return self
        }
        
        // 모든 요소들을 바탕으로 최종 alertView 생성
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
