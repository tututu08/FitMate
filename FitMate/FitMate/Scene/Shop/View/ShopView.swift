//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class ShopView: BaseView {
    
    let topBar = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "상점"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let coinLabel: UILabel = {
        let coin = UILabel()
        coin.text = "100"
        coin.font = .systemFont(ofSize: 20)
        coin.textColor = .systemGreen
        return coin
    }()
    
    let coinIcon: UIImageView = {
        let coinImg = UIImageView()
        coinImg.image = UIImage(named: "Coin")
        coinImg.contentMode = .scaleAspectFit
        coinImg.clipsToBounds = true
        return coinImg
    }()
    
    lazy var categoryCollectionView: UICollectionView = {
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
    
    let categoryUnderlineView = UIView()
    
    let mainAvatar: UIImageView = {
       let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar.image = UIImage(named: "bbari")
        avatar.setContentHuggingPriority(.required, for: .vertical)
        avatar.setContentHuggingPriority(.required, for: .horizontal)
        return avatar
    }()
    
    lazy var avatartCollection = UICollectionView(
        frame: .zero,
        collectionViewLayout: setCollection()
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        categoryCollectionView.register(ShopCategoryCell.self, forCellWithReuseIdentifier: ShopCategoryCell.id)
        
        avatartCollection.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.id)
        setUpUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCollection() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 7,
            leading: 7,
            bottom: 7,
            trailing: 7
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1/3)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    func setUpUI() {
        addSubview(topBar)
        topBar.addSubview(titleLabel)
        
        addSubview(categoryCollectionView)
        addSubview(categoryUnderlineView)
        addSubview(avatartCollection)
        addSubview(mainAvatar)
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        coinIcon.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(11)
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(23)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.centerY.equalTo(topBar)
            make.leading.equalTo(coinIcon.snp.trailing).offset(8)
        }
        
        mainAvatar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(coinLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(112)
            make.height.equalTo(mainAvatar.snp.width).multipliedBy(1.2)
        }
        
        categoryUnderlineView.backgroundColor = .systemPurple
        categoryUnderlineView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
    }
    
    
}
