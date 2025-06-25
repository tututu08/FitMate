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
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    let myRecordLabel: UILabel = {
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
        label.font = .boldSystemFont(ofSize: 24)
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
        let stackView = UIStackView(arrangedSubviews: [myLabel, myRecordLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()

    private lazy var mateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mateLabel, mateRecordLabel])
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
        view.layer.borderColor = UIColor.primary200.cgColor
        view.layer.cornerRadius = 5
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
        view.layer.cornerRadius = 5
        return view
    }()

    private let mateProgressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    private var myProgressWidthConstraint: Constraint?
    private var mateProgressWidthConstraint: Constraint?

    
    private lazy var totalVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myProgressStackView, mateProgressStackView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()

    private let battleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "battleBackground")
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
        imageView.image = UIImage(named: "kaepy")
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
        goalImage.addSubview(goalLabel)
        myProgressBackgroundView.addSubview(myProgressForegroundView)
        mateProgressBackgroundView.addSubview(mateProgressForegroundView)
        battleImage.addSubview(myCharacterImage)
        battleImage.addSubview(mateCharacterImage)
        [
            modeLabel,
            goalImage,
            totalVerticalStack,
            battleImage,
            middleContainer,
            stopButton
        ].forEach { self.addSubview($0) }
        
        middleContainer.addSubview(battleImage)
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
        goalLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        totalVerticalStack.snp.makeConstraints {
            $0.top.equalTo(goalImage.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(contentWidth)
        }
        
        myProgressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(34)
        }
        myProgressForegroundView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(6)
            myProgressWidthConstraint = $0.width.equalTo(0).priority(.high).constraint
        }
        mateProgressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(34)
        }
        mateProgressForegroundView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(6)
            mateProgressWidthConstraint = $0.width.equalTo(0).priority(.high).constraint
        }

        middleContainer.snp.makeConstraints {
            $0.top.equalTo(totalVerticalStack.snp.bottom).offset(0)
            $0.bottom.equalTo(stopButton.snp.top).offset(0)
            $0.leading.trailing.equalToSuperview()
        }
        
        battleImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(contentWidth)
            $0.height.equalTo(contentWidth * 0.72)
        }
        
        myCharacterImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalToSuperview().multipliedBy(0.32)
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        
        mateCharacterImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(8)
            $0.width.equalToSuperview().multipliedBy(0.32)
            $0.height.equalToSuperview().multipliedBy(0.55)
        }
        
        stopButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(battleImage.snp.bottom).offset(16)
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

    func myUpdateProgress(ratio: CGFloat) {
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            let width = self.myProgressBackgroundView.bounds.width - 12
            self.myProgressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    func mateUpdateProgress(ratio: CGFloat) {
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            let width = self.mateProgressBackgroundView.bounds.width - 12
            self.mateProgressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}
