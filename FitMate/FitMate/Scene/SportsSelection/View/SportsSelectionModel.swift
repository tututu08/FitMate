import UIKit
import SnapKit

class CarouselCell: UICollectionViewCell {
    
    private let imageBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 8
        backgroundView.backgroundColor = .secondary50
        return backgroundView
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "DungGeunMo", size: 32)
        label.textColor = .background900
        label.textAlignment = .left
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background500
        label.text = "칼로리 소모량"
        label.textAlignment = .left
        return label
    }()
    private var calorieTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .background900
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    private let exerciseDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background500
        label.text = "운동 설명"
        label.textAlignment = .left
        return label
    }()
    private var exerciseDescriptionTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .background900
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    private let exerciseEffectLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = .background500
        label.text = "운동 효과"
        label.textAlignment = .left
        return label
    }()
    private var exerciseEffectTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.textColor = .background900
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        configure()
    }
    
    private func configure() {
        contentView.backgroundColor = .secondary400
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = false // 그림자 표시를 위해 false로 설정

        // 셀 그림자 설정 (셀 외부에 부드러운 그림자 표시)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15 // 그림자 투명도
        layer.shadowRadius = 6 // 그림자 번짐 정도
        layer.shadowOffset = CGSize(width: 0, height: 3) // 그림자 위치
        layer.masksToBounds = false // 그림자 표시 위해 false
        
        imageBackgroundView.addSubview(imageView)
        
        [imageBackgroundView, titleLabel, calorieLabel, calorieTextLabel,
         exerciseDescriptionLabel, exerciseDescriptionTextLabel,
         exerciseEffectLabel, exerciseEffectTextLabel].forEach {
            contentView.addSubview($0)
        }
        
        imageBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(151)
            $0.height.equalTo(226)
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(132)
            $0.height.equalTo(144)
            $0.width.equalTo(172)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(31.5)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(42)
            $0.width.equalTo(172)
        }
        calorieLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(21)
            $0.width.equalTo(172)
        }
        calorieTextLabel.snp.makeConstraints {
            $0.top.equalTo(calorieLabel.snp.bottom).offset(2)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(172)
        }
        exerciseDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(calorieTextLabel.snp.bottom).offset(8)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(21)
            $0.width.equalTo(172)
        }
        exerciseDescriptionTextLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseDescriptionLabel.snp.bottom).offset(2)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(155)
        }
        exerciseEffectLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseDescriptionTextLabel.snp.bottom).offset(8)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(21)
            $0.width.equalTo(172)
        }
        exerciseEffectTextLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseEffectLabel.snp.bottom).offset(2)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(155)
        }
    }
    
    func configureCell(with item: CarouselViewModel.ExerciseItem) {
        imageView.image = item.image
        titleLabel.text = item.title
        calorieTextLabel.text = item.calorie
        exerciseDescriptionTextLabel.text = item.description
        exerciseEffectTextLabel.text = item.effect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

