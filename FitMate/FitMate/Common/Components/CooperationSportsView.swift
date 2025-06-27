import UIKit
import SnapKit

class CooperationSportsView: BaseView {
    
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.text = "협력 모드"
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return label
    }()
    
    private let goalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "goalbackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.text = "종목 목표치"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let myLabel: UILabel = {
        let label = UILabel()
        label.text = "나"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let mateLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let myRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "나의기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let mateRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var recordStackView: UIStackView = {
        let myStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [myLabel,myRecordLabel])
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.alignment = .center
            return stackView
        }()
        let mateStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [mateLabel,mateRecordLabel])
            stackView.axis = .horizontal
            stackView.spacing = 10
            stackView.alignment = .center
            return stackView
        }()
        let mergeStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [myStackView,mateStackView])
            stackView.axis = .vertical
            stackView.spacing = 15
            stackView.alignment = .leading
            return stackView
        }()
        return mergeStackView
    }()
    
    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.primary200.cgColor
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let progressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary500
        return view
    }()
    
    private var progressWidthConstraint: Constraint?

    private let coopImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "coopBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let middleContainer = UIView()
    
    private let myCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kaepy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let mateCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "morano")
        imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("그만하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "350button"), for: .normal)
        return button
    }()

    override func configureUI() {
        self.backgroundColor = .background800
        goalImage.addSubview(goalLabel) // 목표 라벨을 이미지 위에 올림(중앙 표시)
        progressBackgroundView.addSubview(progressForegroundView) // 진행률 바 layering
        coopImage.addSubview(myCharacterImage)
        coopImage.addSubview(mateCharacterImage)
        [ modeLabel,
          goalImage,
          recordStackView,
          progressBackgroundView,
//          coopImage,
          middleContainer,
          stopButton
        ].forEach{self.addSubview($0)}
        
        middleContainer.addSubview(coopImage)
    }

    // SnapKit으로 레이아웃 제약 설정
    override func setLayoutUI() {
        let safeArea = self.safeAreaLayoutGuide
        let contentWidthRatio: CGFloat = 0.88
        let contentWidth = UIScreen.main.bounds.width * contentWidthRatio
        
        modeLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea.snp.top).offset(36)
            $0.centerX.equalToSuperview()
        }
        
        goalImage.snp.makeConstraints {
            $0.top.equalTo(modeLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(50)
        }
        goalLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        recordStackView.snp.makeConstraints{
            $0.top.equalTo(goalImage.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
        }
        
        progressBackgroundView.snp.makeConstraints {
            $0.top.equalTo(recordStackView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(34)
        }
        
        progressForegroundView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(6)
            progressWidthConstraint = $0.width.equalTo(0).priority(.high).constraint
        }
        
        middleContainer.snp.makeConstraints {
            $0.top.equalTo(progressBackgroundView.snp.bottom).offset(0)
            $0.bottom.equalTo(stopButton.snp.top).offset(0)
            $0.leading.trailing.equalToSuperview()
        }
        
        coopImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(contentWidth * 0.72)
        }
        
        myCharacterImage.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalToSuperview().multipliedBy(0.32)
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        
        mateCharacterImage.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.width.equalToSuperview().multipliedBy(0.32)
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        
        stopButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(coopImage.snp.bottom).offset(16)
            $0.bottom.equalTo(safeArea.snp.bottom).inset(36)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(60)
        }
    }
    
    func updateMyRecord(_ text: String) {
         myRecordLabel.text = text
    }
    func updateMateRecord(_ text: String) {
         mateRecordLabel.text = text
    }
    func updateGoal(_ text: String) {
         goalLabel.text = text
    }
    func updateMyCharacter(_ name: String) {
        myCharacterImage.image = UIImage(named: name)
    }
    func updateMateCharacter(_ name: String) {
        mateCharacterImage.image = UIImage(named: name)
    }

    func updateProgress(ratio: CGFloat) {
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            let width = self.progressBackgroundView.bounds.width - 12
            self.progressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}
