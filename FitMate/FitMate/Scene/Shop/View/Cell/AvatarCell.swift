//
//  AvatarCell.swift
//  FitMate
//
//  Created by soophie on 6/27/25.
//

import UIKit
import SnapKit
import Kingfisher

final class AvatarCell: UICollectionViewCell {
    
    static let id = "AvatarCell"
    
    private let avatarImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private let unlockLabel: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "lock")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private let blackFilter: UILabel = {
        let filter = UILabel()
        filter.backgroundColor = UIColor.black.withAlphaComponent(0.6) // 투명도
        filter.layer.cornerRadius = 8
        filter.layer.masksToBounds = true
        return filter
    }()
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected
            ? 3
            : 0
            contentView.layer.borderColor = isSelected
            ? UIColor(named: "Secondary500")?.cgColor
            : UIColor.clear.cgColor
            contentView.layer.cornerRadius = 8
            contentView.layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        [avatarImage, blackFilter, unlockLabel].forEach({ contentView.addSubview($0) })
        contentView.backgroundColor = .background800
        contentView.clipsToBounds = true // 셀 외곽 넘침 방지
        
        avatarImage.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(0.8)
            
            blackFilter.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            unlockLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(24)
                make.height.equalTo(unlockLabel.snp.width).multipliedBy(0.9)
            }
        }
    }
    
    func configure(with model: AvatarModel) {
        
        if let url = URL(string: model.imageUrl) {
            avatarImage.kf.setImage(with: url)
        }
        
        let isLocked = !model.isUnlocked
        blackFilter.isHidden = !isLocked
        unlockLabel.isHidden = !isLocked
    }
}
