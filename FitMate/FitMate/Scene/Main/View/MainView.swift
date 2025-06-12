//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class MainView: UIView {
    let coinLabel: UILabel = {
        let coin = UILabel()
        coin.text = "100"
        coin.font = UIFont.systemFont(ofSize: 26)
        coin.textColor = .systemGreen
        return coin
    }()
    
    let coinIcon: UIImageView = {
        let coinImg = UIImageView()
        coinImg.image = UIImage(named: "coin")
        coinImg.contentMode = .scaleAspectFit
        coinImg.clipsToBounds = true
        return coinImg
    }()
    
    let bellButton: UIButton = {
        let bell = UIButton()
        bell.setImage(UIImage(named: "bell"), for: .normal)
        return bell
    }()
    
    let explainLabel: UILabel = {
        let explain = UILabel()
        explain.text = "함께 운동한지"
        explain.font = UIFont.systemFont(ofSize: 14)
        explain.textColor = .systemGreen
        return explain
    }()
    
    let dDaysLabel: UILabel = {
        let dDay = UILabel()
        dDay.text = "1일째"
        dDay.font = .systemFont(ofSize: 40)
        dDay.textColor = .systemGreen
        return dDay
    }()
    
    let myNicknameStack = NicknameStackView(
        nickname: "실버웨스트", textColor: .white,
        font: .systemFont(ofSize: 16), arrowColor: .white
    )
    let myAvatarImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "KappyAlone")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let mateNicknameStack = NicknameStackView(
        nickname: "프린세스훈", textColor: .lightGray,
        font: .systemFont(ofSize: 14), arrowColor: .darkGray
    )
    let mateAvatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "mateKappy")
        return imageView
    }()
    
    let exerciseButton: UIButton = {
        let exercise = UIButton()
        exercise.setTitle("운동 선택", for: .normal)
        exercise.setTitleColor(.white, for: .normal)
        exercise.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        exercise.backgroundColor = .systemPurple
        exercise.layer.cornerRadius = 4
        exercise.clipsToBounds = true
        return exercise
    }()
    
    let temporaryBar: UILabel = {
        let tabBar = UILabel()
        tabBar.backgroundColor = .white
        return tabBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .black
        [coinLabel, coinIcon, bellButton, explainLabel, dDaysLabel,
         myNicknameStack, myAvatarImage, mateNicknameStack, mateAvatarImage,
         exerciseButton, temporaryBar].forEach{ addSubview($0) }
    }
    
    private func setLayoutUI() {
        coinIcon.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(-10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        coinLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(-10)
            make.leading.equalTo(coinIcon.snp.trailing).offset(8)
        }
        
        bellButton.snp.makeConstraints{ make in
            make.top.equalTo(safeAreaLayoutGuide).inset(-10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        explainLabel.snp.makeConstraints { make in
            make.top.equalTo(coinLabel.snp.bottom).offset(23)
            make.leading.equalToSuperview().inset(28)
        }
        
        dDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(explainLabel.snp.bottom)
            make.leading.equalToSuperview().inset(28)
        }
        
        exerciseButton.snp.makeConstraints { make in
            make.bottom.equalTo(temporaryBar.snp.top).inset(-32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)
        }
        
        temporaryBar.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(83)
            make.width.equalTo(375)
        }
    }
    
    /// 메이트 유무에 따라 레이아웃을 다르게
    /// hasMate를 기준으로 비교 연산자를 활용해서
    /// true일때 크기 및 위치 / false일 때 크기 및 위치 잡고
    /// 메이트는 isHidden으로 hasMate: true일때 true로
    func changeAvatarLayout(hasMate: Bool) {
        // 내 아바타 위치 및 크기 설정
        myAvatarImage.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(hasMate ? 44: 68)
            make.trailing.equalToSuperview().inset(hasMate ? 123 : 67)
            make.bottom.equalTo(exerciseButton.snp.top).offset(-40)
            make.width.equalTo(hasMate ? 208 : 240)
            make.height.equalTo(hasMate ? 267 : 309)
        }
        // 내 아바타 상단 닉네임 라벨 위치 설정
        myNicknameStack.snp.remakeConstraints { make in
            make.centerX.equalTo(myAvatarImage)
            make.bottom.equalTo(myAvatarImage.snp.top).inset(hasMate ? 0 : -11)
        }
        // 메이트가 있으면 좌우반전
        myAvatarImage.transform = hasMate ? CGAffineTransform(
            scaleX: -1, y: 1) : .identity
        
        // 상대방 아바타 위치 및 크기 설정
        mateAvatarImage.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).inset(25)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(40)
            make.height.equalTo(142)
            make.width.equalTo(112)
        }
        // 상대방 아바타 상단 닉네임 라벨 위치 설정
        mateNicknameStack.snp.remakeConstraints { make in
            make.centerX.equalTo(mateAvatarImage)
            make.bottom.equalTo(mateAvatarImage.snp.top)
        }
        // 메이트 없을 때는 안보이게 처리
        mateAvatarImage.isHidden = !hasMate // = hasMate가 false면 안보이도록
        mateNicknameStack.isHidden = !hasMate
    }
}
