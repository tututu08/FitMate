//
//  BattleSportsView.swift
//  FitMate
//
//  Created by 강성훈 on 6/9/25.
//

import UIKit
import SnapKit

class BattleSportsView: BaseView {
    
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.text = "대결 모드"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()
    
    private let goalImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "goalImage")
        imageView.contentMode = .scaleAspectFit
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
        label.font = .boldSystemFont(ofSize: 25)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let myRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "나의기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private let mateLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let mateRecordLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트기록"
        label.textColor = .gray
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var myStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [myLabel,myRecordLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var mateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mateLabel,mateRecordLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var myProgressStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myStackView, myProgressBackgroundView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var mateProgressStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mateStackView, mateProgressBackgroundView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private let myProgressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.primary500.cgColor
        return view
    }()
    
    private let myProgressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary500
        return view
    }()
    
    private let mateProgressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private let mateProgressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var totalVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myProgressStackView, mateProgressStackView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private var progressWidthConstraint: Constraint?

    private let battleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "battleBackground")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let myCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "KaepyR")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let mateCharacterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MeoranoL")
        imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let stopButton: UIButton = {
        let button = UIButton()
        button.setTitle("그만하기", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "350button"), for: .normal)
        return button
    }()
    
    override func configureUI() {
        self.backgroundColor = .black
        goalImage.addSubview(goalLabel)
        myProgressBackgroundView.addSubview(myProgressForegroundView)
        mateProgressBackgroundView.addSubview(mateProgressForegroundView)
        battleImage.addSubview(myCharacterImage)
        battleImage.addSubview(mateCharacterImage)
        
        [ modeLabel,
          goalImage,
          totalVerticalStack,
          battleImage,
          stopButton
        ].forEach{self.addSubview($0)}
        
    }
    
    override func setLayoutUI() {
        modeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.centerX.equalToSuperview()
        }
        
        goalImage.snp.makeConstraints {
            $0.top.equalTo(modeLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(350)
            $0.height.equalTo(55)
        }
        
        goalLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        totalVerticalStack.snp.makeConstraints{
            $0.top.equalTo(goalImage.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            
        }
        myProgressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        myProgressForegroundView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(6)
            progressWidthConstraint = $0.width.equalTo(0).constraint // 채워지는 바 width 제약
        }
        
        mateProgressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        mateProgressForegroundView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(6)
            progressWidthConstraint = $0.width.equalTo(0).constraint // 채워지는 바 width 제약
        }
        
        battleImage.snp.makeConstraints {
            $0.bottom.equalTo(stopButton.snp.top).inset(-50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(350)
            $0.height.equalTo(310)
        }
        
        myCharacterImage.snp.makeConstraints{
            $0.leading.equalTo(battleImage.snp.leading).inset(13)
            $0.bottom.equalTo(battleImage.snp.bottom).inset(10)
            $0.height.equalTo(150)
            $0.width.equalTo(120)
        }
        
        mateCharacterImage.snp.makeConstraints{
            $0.trailing.equalTo(battleImage.snp.trailing).inset(13)
            $0.bottom.equalTo(battleImage.snp.bottom).inset(150)
            $0.height.equalTo(150)
            $0.width.equalTo(120)
        }
        
        stopButton.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(60)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(60)
            $0.width.equalTo(350)
        }
    }
    // 내 기록 라벨 갱신
    func updateMyRecord(_ text: String) {
         myRecordLabel.text = text
    }
    // 메이트 기록 라벨 갱신
    func updateMateRecord(_ text: String) {
         mateRecordLabel.text = text
    }
    // 목표치 라벨 갱신
    func updateGoal(_ text: String) {
         goalLabel.text = text
    }
    func updateMyCharacter(_ name: String) {
        myCharacterImage.image = UIImage(named: name)
    }
    func updateMateCharacter(_ name: String) {
        mateCharacterImage.image = UIImage(named: name)
    }
    // 진행률 바 갱신(0~1 비율)
    func myUpdateProgress(ratio: CGFloat) {
         layoutIfNeeded()
         let width = myProgressBackgroundView.bounds.width - 12 // inset 보정
         progressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
         layoutIfNeeded()
    }
    func mateUpdateProgress(ratio: CGFloat) {
         layoutIfNeeded()
         let width = mateProgressBackgroundView.bounds.width - 12 // inset 보정
         progressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
         layoutIfNeeded()
    }
}
