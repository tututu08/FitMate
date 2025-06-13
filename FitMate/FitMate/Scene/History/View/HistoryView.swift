//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
// HistoryView.swift
//
//

import UIKit
import SnapKit

final class HistoryView: UIView {

    let categoryUnderlineView = UIView()

    let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero 
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    let recordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "운동 기록"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    let backButton: UIButton = { 
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1.0)

        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        recordCollectionView.register(RecordCell.self, forCellWithReuseIdentifier: RecordCell.identifier)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupLayout() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(categoryCollectionView)
        addSubview(categoryUnderlineView)
        addSubview(recordCollectionView)

        backButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.centerX.equalToSuperview()
        }

        categoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        categoryUnderlineView.backgroundColor = UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 1.0)
        categoryUnderlineView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        recordCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryUnderlineView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
