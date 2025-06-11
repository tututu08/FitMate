import UIKit
import SnapKit

class CarouselCell: UICollectionViewCell {
    
    private let imageBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 20
        backgroundView.backgroundColor = .white // 변경 필요 시 수정
        return backgroundView
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.text = "칼로리 소모량"
        return label
    }()
    private var calorieTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let exerciseDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.text = "운동 설명"
        
        return label
    }()
    private var exerciseDescriptionTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private let exerciseEffectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.text = "운동 효과"
        return label
    }()
    private var exerciseEffectTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        configure()
    }
    
    private func configure() {
        contentView.backgroundColor = UIColor(red: 191, green: 255, blue: 0, alpha: 1)
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
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(31.5)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        calorieLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        calorieTextLabel.snp.makeConstraints {
            $0.top.equalTo(calorieLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        exerciseDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(calorieTextLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        exerciseDescriptionTextLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseDescriptionLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        exerciseEffectLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseDescriptionTextLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
        }
        exerciseEffectTextLabel.snp.makeConstraints {
            $0.top.equalTo(exerciseEffectLabel.snp.bottom).offset(4)
            $0.leading.equalTo(imageBackgroundView.snp.trailing).offset(20)
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

