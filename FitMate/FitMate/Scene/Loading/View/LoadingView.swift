//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import Lottie
import SnapKit

class LoadingView: UIView {
   
    private lazy var animation: LottieAnimationView = {
       let lottie = LottieAnimationView(name: "battery")
        return lottie
    }()
    private let loadingMent: UILabel = {
       let ment = UILabel()
        ment.text = "잠시만 기다려주세요"
        ment.font = UIFont(name: "DungGeunMo", size: 20)
        ment.textColor = .primary100
        ment.textAlignment = .center
        return ment
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "취소"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "DungGeunMo", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.background200,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = .clear
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont(name: "DungGeunMo", size: 17)
        button.setTitleColor(.primary100, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setLottie()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        backgroundColor = .background800
        addSubview(animation)
        addSubview(loadingMent)
        addSubview(cancelButton) // 취소 버튼 추가
        
        animation.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(305)
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
        
        loadingMent.snp.makeConstraints { make in
            make.top.equalTo(animation.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
               make.top.equalTo(loadingMent.snp.bottom).offset(32)
               make.centerX.equalToSuperview()
               make.width.equalTo(84)
               make.height.equalTo(40)
        }
    }
    
    func setLottie() {
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.play()
    }
}
