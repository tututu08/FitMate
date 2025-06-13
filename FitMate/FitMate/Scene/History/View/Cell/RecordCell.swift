//
//  RecordCell.swift
//  FitMate
//
//  Created by 형윤 on 6/9/25.
//
//

import UIKit

final class RecordCell: UICollectionViewCell {
    static let identifier = "RecordCell"

    private let characterImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let detailLabel1 = UILabel()
    private let detailLabel2 = UILabel()
    private let detailLabel3 = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true

        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        characterImageView.widthAnchor.constraint(equalToConstant: 88).isActive = true
        characterImageView.heightAnchor.constraint(equalToConstant: 88).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [typeLabel, dateLabel, resultLabel])
        headerStack.axis = .horizontal
        headerStack.alignment = .top
        headerStack.spacing = 4
        headerStack.distribution = .equalSpacing

        [detailLabel1, detailLabel2, detailLabel3].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.text = "종목"
            $0.textAlignment = .center
            $0.textColor = .black
        }

        let detailStack = UIStackView(arrangedSubviews: [detailLabel1, detailLabel2, detailLabel3])
        detailStack.axis = .horizontal
        detailStack.spacing = 4
        detailStack.distribution = .fillEqually

        let mainContentStack = UIStackView(arrangedSubviews: [headerStack, detailStack])
        mainContentStack.axis = .vertical
        mainContentStack.spacing = 8

        let mainStack = UIStackView(arrangedSubviews: [characterImageView, mainContentStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with record: ExerciseRecord) {
        typeLabel.text = record.type.rawValue
        dateLabel.text = record.date
        resultLabel.text = record.result.rawValue
    }
}
