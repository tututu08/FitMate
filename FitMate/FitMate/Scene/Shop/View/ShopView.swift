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
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return label
    }()
    
    let coinLabel: UILabel = {
        let coin = UILabel()
        coin.text = "100"
        coin.font = UIFont(name: "DungGeunMo", size: 26)
        coin.textColor = .secondary400
        return coin
    }()
    
    let coinIcon: UIImageView = {
        let coinImg = UIImageView()
        coinImg.image = UIImage(named: "coin")
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
    
    let selectedAvatarImg: UIImageView = {
       let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        avatar.image = nil
        avatar.transform = .identity
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
        configureUI()
        setLayoutUI()
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
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .estimated(100)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func configureUI() {
        backgroundColor = .background800
        avatartCollection.backgroundColor = .clear
        addSubview(topBar)
        topBar.addSubview(titleLabel)
        
        addSubview(coinIcon)
        addSubview(coinLabel)
        addSubview(categoryCollectionView)
        addSubview(categoryUnderlineView)
        addSubview(avatartCollection)
        addSubview(selectedAvatarImg)
        categoryUnderlineView.backgroundColor = .primary500
        
    }
    
    override func setLayoutUI() {
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        coinIcon.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(11)
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(23)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(11)
            make.leading.equalTo(coinIcon.snp.trailing).offset(8)
        }
        
        selectedAvatarImg.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(coinLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(112)
            make.height.equalTo(selectedAvatarImg.snp.width).multipliedBy(1.2)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedAvatarImg.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        categoryUnderlineView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        avatartCollection.snp.makeConstraints { make in
            make.top.equalTo(categoryUnderlineView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
