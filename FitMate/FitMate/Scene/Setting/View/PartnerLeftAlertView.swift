//
//  MateEndedPopupView.swift
//  FitMate
//
//  Created by 김은서 on 6/23/25.
//

import UIKit
import SnapKit

final class PartnerLeftAlertView: UIView {

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
        label.text = "상대방이 메이트를\n 종료하였습니다."
        label.numberOfLines = 0
        label.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "기록은 보관되어 있으니 언제든 확인할 수 있습니다.\n새로운 메이트를 추가해 운동을 이어가보세요."
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(named: "Background400")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primary500
        button.layer.cornerRadius = 4
        return button
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

        [titleLabel, descriptionLabel, confirmButton].forEach {
            containerView.addSubview($0)
        }

        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            //$0.width.equalTo(326)
            $0.horizontalEdges.equalToSuperview().inset(24)
            //$0.height.equalTo(210)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    func configure(title: String? = nil, description: String? = nil) {
        if let title = title {
            titleLabel.text = title
        }
        if let description = description {
            descriptionLabel.text = description
        }
    }
}

