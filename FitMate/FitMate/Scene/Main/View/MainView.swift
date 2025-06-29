//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class MainView: BaseView {
    
    let topBar: UINavigationBar = {
        let view = UINavigationBar()
        return view
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
//    
//    let bellButton: UIButton = {
//        let bell = UIButton()
//        bell.setImage(UIImage(named: "bell"), for: .normal)
//        return bell
//    }()
    
    let explainLabel: UILabel = {
        let explain = UILabel()
        explain.text = "함께 운동한지"
        explain.font = UIFont(name: "Pretendard-Regular", size: 14)
        explain.textColor = .background400
        return explain
    }()
    
    let dDaysLabel: UILabel = {
        let dDay = UILabel()
        dDay.text = "1일째"
        dDay.font = UIFont(name: "DungGeunMo", size: 40)
        dDay.textColor = .secondary500
//        dDay.minimumScaleFactor = 0.1 // 외부 제약이 명시적일때 그 제약에 맞게
        dDay.adjustsFontSizeToFitWidth = true
        return dDay
    }()
    
    let myAvatarImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "kaepy")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let myNicknameStack = NicknameStackView(
        nickname: "", textColor: .white,
        font: UIFont(name: "Pretendard-Regular", size: 16) ?? .systemFont(ofSize: 16),
        arrowColor: .white
    )

    private let mateNicknameStack = NicknameStackView(
        nickname: "", textColor: .background300,
        font: UIFont(name: "Pretendard-Regular", size: 12) ?? .systemFont(ofSize: 12),
        arrowColor: .background300
    )
    
    let mateAvatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kaepy")
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        return imageView
    }()
    
    let exerciseButton: UIButton = {
        let exercise = UIButton()
        exercise.setTitle("운동 선택", for: .normal)
        exercise.setTitleColor(.white, for: .normal)
        exercise.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        exercise.backgroundColor = .primary500
        exercise.layer.cornerRadius = 4
        exercise.clipsToBounds = true
        return exercise
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        backgroundColor = .background800
            [topBar, explainLabel, dDaysLabel, myAvatarImage,
             mateAvatarImage, exerciseButton,
             myNicknameStack, mateNicknameStack].forEach { addSubview($0) }
        [coinLabel, coinIcon ].forEach({topBar.addSubview($0)})
//        [coinLabel, coinIcon, bellButton].forEach({topBar.addSubview($0)})
    }
    
    override func setLayoutUI() {
        
        topBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        coinIcon.snp.makeConstraints { make in
            make.centerY.equalTo(topBar)
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(23)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.centerY.equalTo(topBar)
            make.leading.equalTo(coinIcon.snp.trailing).offset(8)
        }
//        
//        bellButton.snp.makeConstraints{ make in
//            make.centerY.equalTo(topBar)
//            make.trailing.equalToSuperview().inset(20)
//            make.size.equalTo(28)
//        }
        
        explainLabel.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(18)
            make.leading.equalToSuperview().inset(28)
        }
        
        dDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(explainLabel.snp.bottom)
            make.leading.equalToSuperview().inset(28)
            make.width.equalTo(dDaysLabel.snp.height).multipliedBy(2.3)
        }
        
        myAvatarImage.snp.makeConstraints { make in
//            make.top.equalTo(dDaysLabel.snp.bottom).offset(45)
            make.leading.equalToSuperview().inset(68)
            make.trailing.equalToSuperview().inset(67)
            make.bottom.equalTo(exerciseButton.snp.top).offset(-40)
//            make.width.equalTo(hasMate ? 208 : 240)
            make.height.equalTo(309)
        }
        
        exerciseButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(exerciseButton.snp.width).multipliedBy(0.17)
        }

    }
    
    /// - 메이트 유무에 따라 레이아웃을 다르게
    /// - hasMate를 기준으로 비교 연산자를 활용해서
    /// - true일때 크기 및 위치 / false일 때 크기 및 위치 잡고
    /// - 메이트는 isHidden으로 hasMate: true일때 true로
    func changeAvatarLayout(hasMate: Bool, myNickname: String, mateNickname: String) {
        myNicknameStack.updateNickname(myNickname)
        mateNicknameStack.updateNickname(mateNickname)
        
        myNicknameStack.isHidden = false
            mateNicknameStack.isHidden = !hasMate
            mateAvatarImage.isHidden = !hasMate
        
        // 내 아바타 위치 및 크기 설정
        myAvatarImage.snp.remakeConstraints { make in
//            make.top.equalTo(dDaysLabel.snp.bottom).offset(45)
            make.leading.equalToSuperview().inset(hasMate ? 44: 68)
            make.trailing.equalToSuperview().inset(hasMate ? 123 : 67)
            make.bottom.equalTo(exerciseButton.snp.top).offset(-40)
            make.height.equalTo(myAvatarImage.snp.width).multipliedBy(1.283)
        }
        // 내 아바타 상단 닉네임 라벨 위치 설정
        myNicknameStack.snp.remakeConstraints { make in
            make.centerX.equalTo(myAvatarImage)
            make.bottom.equalTo(myAvatarImage.snp.top).inset(hasMate ? -20 : -11)
        }
        // 상대방 아바타 위치 및 크기 설정
        mateAvatarImage.snp.remakeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(240)
            make.trailing.equalToSuperview().inset(26)
            make.height.equalTo(mateAvatarImage.snp.width).multipliedBy(0.9)
        }
        // 상대방 아바타 상단 닉네임 라벨 위치 설정
        mateNicknameStack.snp.remakeConstraints { make in
            make.centerX.equalTo(mateAvatarImage)
            make.bottom.equalTo(mateAvatarImage.snp.top).inset(-10)
        }
        
//        // 메이트 없을 때는 안보이게 처리
//        mateAvatarImage.isHidden = !hasMate // = hasMate가 false면 안보이도록
//        print("기대값false:\(hasMate)")
//        mateNicknameStack.isHidden = !hasMate
    }
}
