//
//  AvatarPopUpViewController.swift
//  FitMate
//
//  Created by soophie on 7/1/25.
//

import UIKit
import SnapKit

class AvatarPopUpViewController: CustomAlertViewController {
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let coinLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "DungGeunMo", size: 16)
        label.textColor = .background800
        return label
    }()
    
    private let coinImage = UIImageView(image: UIImage(named: "blackcoin"))
    
    private lazy var coinStack: UIStackView = {
        coinImage.contentMode = .scaleAspectFit
        let stack = UIStackView(arrangedSubviews: [coinImage, coinLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let coinBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondary300
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let alertView else { return }
        
        // 공통 우선순위 설정
        coinLabel.setContentHuggingPriority(.required, for: .vertical)
        coinLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        coinImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        // coinStack → coinBackgroundView → alertView 에 추가
        coinBackgroundView.addSubview(coinStack)
        alertView.addSubview(coinBackgroundView)
        alertView.addSubview(avatarImage)
        
        // coinStack이 coinBackgroundView 내부에 꽉 차게
        coinStack.snp.makeConstraints { // 피그마대로 양 방향에 다 여백 주기
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }
        
        // 타이틀 아래에 coinBackgroundView 배치
        coinBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(alertView.alertTitle.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        avatarImage.snp.makeConstraints { make in
            make.top.equalTo(coinBackgroundView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(alertView.snp.width).offset(-100)
            make.height.equalTo(avatarImage.snp.width).multipliedBy(0.91)
        }
        
        guard let buttonStack = confirmButton.superview else { return }
        
        avatarImage.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(buttonStack.snp.top).offset(-22)
        }
    }
    
    // 팝업 뷰 안에 보여줄 이미지와 코인 금액을 직접 셋팅하는 역할
    func configure(avatarImageName: String, coinCost: Int) {
        // 코인 라벨에 가격 숫자 표시
        coinLabel.text = "\(coinCost)"
        // 아바타 이미지 이름으로 UIImage 생성
        if let image = UIImage(named: avatarImageName),
           let cgImage = image.cgImage {
            // 뷰컨에서 메인 이미지 반전시키는 방식과 마찬가지로 이미지 반전
            let fixedImage = UIImage(
                cgImage: cgImage,
                scale: image.scale,
                orientation: .up) // 이미지 방향을 고정시켜서 반전 처리를 위한 기준 이미지 생성
            let flippedImage = UIImage(
                cgImage: fixedImage.cgImage!,
                scale: fixedImage.scale,
                orientation: .upMirrored) // 메인 뷰와 동일하게 좌우 반전된 이미지 생성 -> .upMirrored 방향 사용
            avatarImage.image = flippedImage
        } else {
            avatarImage.image = UIImage(named: avatarImageName)
        }
    }
}

