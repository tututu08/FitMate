//
//  BattleSportsView.swift
//  FitMate
//
//  Created by 강성훈 on 6/9/25.
//

import UIKit
import SnapKit

class BattleSportsView: UIView {
    
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
    
    private lazy var myVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myStackView, myProgressBackgroundView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var mateVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mateStackView, mateProgressBackgroundView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private let myProgressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemPurple.cgColor
        return view
    }()
    
    private let myProgressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private let mateProgressBackgroundView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemPurple.cgColor
        return view
    }()
    
    private let mateProgressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private lazy var totalVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [myVerticalStack, mateVerticalStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    private let coopImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let pauseButton: UIButton = {
        let Button = UIButton()
        Button.setImage(UIImage(named: "pause"), for: .normal)
        return Button
    }()
    
    private let stopButton: UIButton = {
        let Button = UIButton()
        Button.setImage(UIImage(named: "stop"), for: .normal)
        return Button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
    }
    
    func setupUI() {
        self.backgroundColor = .black
        goalImage.addSubview(goalLabel)
        myProgressBackgroundView.addSubview(myProgressForegroundView)
        mateProgressBackgroundView.addSubview(mateProgressForegroundView)
        [ modeLabel,
          goalImage,
          totalVerticalStack,
          coopImage,
          pauseButton,
          stopButton
        ].forEach{self.addSubview($0)}
        
    }
    
    func setupLayout() {
        modeLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(0)
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
            $0.edges.equalToSuperview().inset(6) // 패딩을 줘서 테두리 공간 유지
        }
        mateProgressBackgroundView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        mateProgressForegroundView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6) // 패딩을 줘서 테두리 공간 유지
        }
        coopImage.snp.makeConstraints {
            $0.bottom.equalTo(stopButton.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(400)
        }
        
        pauseButton.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(60)
        }
        
        stopButton.snp.makeConstraints{
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalTo(pauseButton.snp.trailing).offset(12)
            $0.height.equalTo(60)
            $0.width.equalTo(260)
        }
    }
    
}
