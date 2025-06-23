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
        view.backgroundColor = UIColor(named: "Background50")
        view.layer.cornerRadius = 12
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트 연결 종료"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방이 메이트를 종료했습니다."
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(named: "Background600")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primary500
        button.layer.cornerRadius = 8
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

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
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

