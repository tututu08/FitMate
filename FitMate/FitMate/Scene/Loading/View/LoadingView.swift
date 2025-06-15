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
        
        animation.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(305)
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
        
        loadingMent.snp.makeConstraints { make in
            make.top.equalTo(animation.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    
    func setLottie() {
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.play()
    }
}
