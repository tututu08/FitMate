//
//  CooperationSportsView.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

/// 여러 운동에서 공용으로 사용되는 협력 모드 화면
/// CoreLocation, CoreMotion, 타이머 등 다양한 값과 바인딩할 수 있도록 구성
class CooperationSportsView: UIView {
    
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.text = "협력 모드"
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
        return label
    }()
    
    private let mateLabel: UILabel = {
        let label = UILabel()
        label.text = "메이트"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25)
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
        view.layer.borderColor = UIColor.systemPurple.cgColor
        return view
    }()
    
    private let progressForegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()

    private var progressWidthConstraint: Constraint?
    
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
        progressBackgroundView.addSubview(progressForegroundView)
        
        [ modeLabel,
          goalImage,
          recordStackView,
          progressBackgroundView,
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
        
        recordStackView.snp.makeConstraints{
            $0.top.equalTo(goalImage.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(25)
        }
        
        progressBackgroundView.snp.makeConstraints {
            $0.top.equalTo(recordStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(30)
        }
        
        progressForegroundView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(6)
            progressWidthConstraint = $0.width.equalTo(0).constraint
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
    /// Updates the label showing the current record for the user.
    /// - Parameter text: New text to display.
    func updateMyRecord(_ text: String) {
        myRecordLabel.text = text
    }

    /// Updates the label showing the current record for the mate.
    /// - Parameter text: New text to display.
    func updateMateRecord(_ text: String) {
        mateRecordLabel.text = text
    }

    /// 저장된 목표치를 갱신할 때 사용합니다.
    /// - Parameter text: 목표를 나타내는 문자열
    func updateGoal(_ text: String) {
        goalLabel.text = text
    }

    /// 전달받은 비율에 따라 진행률 바를 갱신합니다. (0~1 범위)
    /// - Parameter ratio: 1이면 목표 달성
    func updateProgress(ratio: CGFloat) {
        layoutIfNeeded()
        let width = progressBackgroundView.bounds.width - 12 // inset from both sides
        progressWidthConstraint?.update(offset: width * min(1, max(0, ratio)))
        layoutIfNeeded()
    }
    
}
