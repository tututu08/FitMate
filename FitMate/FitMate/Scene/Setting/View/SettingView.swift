
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
        view.backgroundColor = UIColor(named: "Background50")
        view.layer.cornerRadius = 8
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "설정"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(named: "Background900")
        return button
    }()

    let noticeToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(named: "Primary400")?.withAlphaComponent(0.4)
        toggle.thumbTintColor = UIColor(named: "Primary400")?.withAlphaComponent(0.4)
        return toggle
    }()

    let effectToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(named: "Primary400")?.withAlphaComponent(0.4)
        toggle.thumbTintColor = UIColor(named: "Primary400")?.withAlphaComponent(0.4)
        return toggle
    }()

    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "푸시알림"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "Background900")
        return label
    }()

    private let effectLabel: UILabel = {
        let label = UILabel()
        label.text = "효과음"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "Background900")
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Primary400")
        return view
    }()

    let partnerButton = SettingView.makeButton(title: "파트너 종료")
    let logoutButton = SettingView.makeButton(title: "로그아웃")
    let withdrawButton = SettingView.makeButton(title: "회원탈퇴")

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

    private func setupLayout() {
        addSubview(backgroundView)
        addSubview(containerView)

        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(326)
            $0.height.equalTo(345)
        }

        [titleLabel, closeButton, separator].forEach {
            containerView.addSubview($0)
        }

        let noticeStack = UIStackView(arrangedSubviews: [noticeLabel, noticeToggle])
        noticeStack.axis = .horizontal
        noticeStack.spacing = 4
        noticeStack.alignment = .center

        let effectStack = UIStackView(arrangedSubviews: [effectLabel, effectToggle])
        effectStack.axis = .horizontal
        effectStack.spacing = 4
        effectStack.alignment = .center

        let toggleStack = UIStackView(arrangedSubviews: [noticeStack, effectStack])
        toggleStack.axis = .horizontal
        toggleStack.spacing = 24
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
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(24)
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(toggleStack.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(193)
        }
    }

    private static func makeButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "Background600"), for: .normal)
        button.backgroundColor = UIColor(named: "Background100")
        button.layer.cornerRadius = 6
        return button
    }
}
