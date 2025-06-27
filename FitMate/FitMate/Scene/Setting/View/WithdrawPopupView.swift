
import UIKit
import SnapKit

final class WithdrawPopupView: UIView {

    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "정말 탈퇴하시겠어요?"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "탈퇴 버튼 선택 시, 정보는\n삭제되며 복구되지 않습니다."
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(named: "Background400")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(named: "Background900"), for: .normal)
        button.backgroundColor = UIColor(named: "Background50")
        button.layer.cornerRadius = 4
        return button
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Primary500")
        button.layer.cornerRadius = 4
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(backgroundView)
        addSubview(containerView)

        [titleLabel, descriptionLabel, buttonStack].forEach {
            containerView.addSubview($0)
        }

        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(326)
            $0.height.equalTo(210)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        buttonStack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
    }
}
