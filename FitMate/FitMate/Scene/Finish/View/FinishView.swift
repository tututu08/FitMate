//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit


final class FinishView: BaseView {
    
    // 모드 표시용 (대결/협력)
    let modeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textColor = .white
        return label
    }()
    
    // 목표/보상 영역 배경 이미지
    private let goalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "goalbackground") // 목표 아이콘
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // 목표값(라벨로 중앙에 노출)
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.text = "종목 목표치" // 예: "목표 100회"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    // 운동 결과 문구 라벨
    let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let middleContainer = UIView()

    // 배경 이미지
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "finishbackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // 결과 이미지 (왕관/비구름 등)
    let resultImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 사용자 캐릭터 이미지
    let characterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
//    let coinBackImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "coinbackground")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    // 코인 이미지 (성공 시 노출)
//    let coinImage: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "blackcoin")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
    
    // 보상 라벨(예: 10코인)
//    let rewardLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = .boldSystemFont(ofSize: 15)
//        label.textColor = .black
//        return label
//    }()

    // 보상 수령 버튼
    let rewardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(named: "350button"), for: .normal)
        button.setTitle("돌아가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return button
    }()
    
    override func configureUI() {
        backgroundColor = .background800
        goalImage.addSubview(goalLabel)
        backgroundImage.addSubview(resultImage)
        backgroundImage.addSubview(characterImage)
//        coinBackImage.addSubview(coinImage)
//        coinBackImage.addSubview(rewardLabel)
        
        [modeLabel,
         goalImage,
         resultLabel,
         backgroundImage,
         middleContainer,
//         coinBackImage,
         rewardButton
        ].forEach{self.addSubview($0)}
        
        middleContainer.addSubview(backgroundImage)
    }
    
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
//        rewardLabel.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
        
        goalLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        resultLabel.snp.makeConstraints{
            $0.top.equalTo(goalImage.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
        }
        
        middleContainer.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(0)
            $0.bottom.equalTo(rewardButton.snp.top).offset(0)
            $0.leading.trailing.equalToSuperview()
        }
        
        backgroundImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(contentWidth * 0.72)
        }
        
        resultImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backgroundImage.snp.top).offset(-10)
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalToSuperview().multipliedBy(0.30)

        }
        
        characterImage.snp.makeConstraints {
            $0.top.equalTo(resultImage.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
        
//        coinBackImage.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalTo(rewardButton.snp.top).offset(-7)
//            $0.height.equalTo(50)
//            $0.width.equalTo(130)
//        }
//
//        coinImage.snp.makeConstraints {
//            $0.width.height.equalTo(20)
//            $0.top.equalTo(coinBackImage.snp.top).offset(7)
//            $0.leading.equalTo(coinBackImage.snp.leading).offset(30)
//
//        }
//        rewardLabel.snp.makeConstraints {
//            $0.height.equalTo(24)
//            $0.width.equalTo(20)
//            $0.top.equalTo(coinBackImage.snp.top).offset(7)
//            $0.trailing.equalTo(coinBackImage.snp.trailing).inset(-5)
//        }
        
        rewardButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(resultImage.snp.bottom).offset(16)
            $0.bottom.equalTo(safeArea.snp.bottom).inset(36)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(60)
        }
    }
    
    func updateMode(_ text: String) {
        modeLabel.text = text
    }
    
    func updateGoal(_ text: String) {
        goalLabel.text = text
    }
//    func updateReward(text: String, hideCoin: Bool) {
//        rewardLabel.text = text
//        coinBackImage.isHidden = hideCoin
//    }
    
    func updateResult(text: String, imageName: String) {
        resultLabel.text = text
        resultImage.image = UIImage(named: imageName)
    }
    
    func updateCharacter(_ name: String) {
        characterImage.image = UIImage(named: name)
    }
}
