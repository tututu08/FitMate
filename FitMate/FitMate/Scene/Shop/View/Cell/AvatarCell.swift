//
//  AvatarCell.swift
//  FitMate
//
//  Created by soophie on 6/27/25.
//

import UIKit
import SnapKit

final class AvatarCell: UICollectionViewCell {
    
    static let id = "MarketCell"
    
    private let avatarImage: UIImageView = {
       let image = UIImageView()
        return image
    }()
    
    private let unlockLabel: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "unlockpause")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private let backgroundImg: UILabel = {
        let label = UILabel()
        label.backgroundColor = .darkGray
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private let blackFilter: UILabel = {
        let filter = UILabel()
        filter.backgroundColor = UIColor.black.withAlphaComponent(0.6) // 투명도
        filter.layer.cornerRadius = 8
        filter.layer.masksToBounds = true
        return filter
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        contentView.addSubview(backgroundImg)
        [avatarImage, blackFilter, unlockLabel].forEach({backgroundImg.addSubview($0)})
        
        backgroundImg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            /// 셀이 처음 만들어질 때만 한 번만 설정되는 제약
            /// 이때는 아직 어떤 아바타가 들어올지 모르니까 기본 배치만 잡는 정도
            make.height.equalTo(avatarImage.snp.width).multipliedBy(1.0)
        }
        
        blackFilter.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        unlockLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.bottom.equalToSuperview().inset(22)
        }
    }
    
    func configure(with model: AvatarModel) {
        avatarImage.image = UIImage(named: model.imageName)
        
        /// 현재 아바타 모델에 맞는 비율로 제약을 새로 설정
//        avatarImage.snp.remakeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.equalTo(64)
//            make.height.equalTo(avatarImage.snp.width).multipliedBy(model.finalRatio)
//        }

        /// 아바타 해금 안됐으면
        /// 필터랑 자물쇠 표시
        let isLocked = !model.isUnlocked
        blackFilter.isHidden = !isLocked
        unlockLabel.isHidden = !isLocked
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? UIColor.green.cgColor : UIColor.clear.cgColor
        }
    }

}
