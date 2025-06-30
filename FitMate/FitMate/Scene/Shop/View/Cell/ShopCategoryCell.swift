//
//  CategoryCell.swift
//  FitMate
//
//  Created by soophie on 6/27/25.
//

import UIKit
import SnapKit

class ShopCategoryCell: UICollectionViewCell {
    
    static let id = "CategoryCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = UIColor(named: "Background50")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 10
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.masksToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with category: RankCategory, isSelected: Bool) {
        titleLabel.text = category.rawValue
        contentView.backgroundColor = isSelected ? .primary500 : .clear
        titleLabel.textColor = isSelected ? .white : .primary100
    }
    
}
