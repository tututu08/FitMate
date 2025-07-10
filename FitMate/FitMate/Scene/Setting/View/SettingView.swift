import UIKit

import SnapKit

final class SettingView: UIView {

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background900")?.withAlphaComponent(0.6)
        return view
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    // 상단 제목 설정
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "설정"
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()

    //닫기
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: "Background900")
        return button
    }()

    let noticeToggle = CustomSwitchView() // 푸시 알림 설정 스위치
    let effectToggle = CustomSwitchView() // 효과음 설정 스위치

    // 푸시알림
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "푸시알림"
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = UIColor(named: "Background900")
        return label
    }()

    // 효과음
    private let effectLabel: UILabel = {
        let label = UILabel()
        label.text = "효과음"
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = UIColor(named: "Background900")
        return label
    }()

    // 토글 섹션과 버튼을 하는 구분선
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Primary300")
        return view
    }()

    let partnerButton = SettingView.makeButton(title: "메이트 끊기")
    let logoutButton = SettingView.makeButton(title: "로그아웃")
    let withdrawButton = SettingView.makeButton(title: "회원탈퇴")

    // 위 3개의 버튼을 정렬하는 스택
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 전체 레이아웃
    private func setupLayout() {
        addSubview(backgroundView)
        addSubview(containerView)

        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(326)
            $0.height.equalTo(355)
        }

        [titleLabel, closeButton, separator].forEach {
            containerView.addSubview($0)
        }
        
        // 푸시알림/효과음을 각각 담는 스택
        let noticeStack = UIStackView(arrangedSubviews: [noticeLabel, noticeToggle])
        noticeStack.axis = .horizontal
        noticeStack.spacing = 6
        noticeStack.alignment = .center

        let effectStack = UIStackView(arrangedSubviews: [effectLabel, effectToggle])
        effectStack.axis = .horizontal
        effectStack.spacing = 6
        effectStack.alignment = .center

        // 위 두 스택을 하나로 묶는 스택
        let toggleStack = UIStackView(arrangedSubviews: [noticeStack, effectStack])
        toggleStack.axis = .horizontal
        toggleStack.spacing = 20
        toggleStack.alignment = .center
        toggleStack.distribution = .equalSpacing

        containerView.addSubview(toggleStack)

        [partnerButton, logoutButton, withdrawButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
        containerView.addSubview(buttonStack)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(24)
        }

        toggleStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(45)
            $0.height.equalTo(32)
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(toggleStack.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(193)
        }
    }

    // 공통된 스타일의 버튼을 생성하는 유틸리티
    private static func makeButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "Background500"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 16)
        button.backgroundColor = UIColor(named: "Background50")
        button.layer.cornerRadius = 4
        return button
    }
}
