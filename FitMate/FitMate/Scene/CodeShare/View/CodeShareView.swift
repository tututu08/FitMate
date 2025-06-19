//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class CodeShareView: BaseView {
    
    let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    let xButton: UIButton = {
        let xButton = UIButton()
        xButton.setImage(UIImage(named: "cancel"), for: .normal)
        xButton.contentHorizontalAlignment = .trailing
        return xButton
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "코드 공유"
        title.textColor = .white
        title.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        return title
    }()
    
    let guideMent: UILabel = {
        let guide = UILabel()
        guide.text = "파트너 연결 후 시작해보세요"
        guide.textColor = .background100
        guide.font = UIFont(name: "Pretendard-Regular", size: 16)
        return guide
    }()
    
    let defaultAvatarImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mumu")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let copyRandomCodeButton = MyRandomCodeButton()
    
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .primary200
        return view
    }()
    
    let mateCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("메이트 코드 입력", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        button.backgroundColor = .primary500
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background800
        configureUI()
        setLayoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        [customNavBar,titleLabel, guideMent, defaultAvatarImage,
         copyRandomCodeButton, line, mateCodeButton].forEach { addSubview($0) }
        
        customNavBar.addSubview(xButton)
        customNavBar.addSubview(titleLabel)
    }
    
    override func setLayoutUI() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        xButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        guideMent.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom).offset(43)
            make.leading.trailing.equalToSuperview().inset(94)
        }
        
        defaultAvatarImage.snp.makeConstraints { make in
            make.top.equalTo(guideMent.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(110)
            make.height.equalTo(defaultAvatarImage.snp.width)
        }
        
        copyRandomCodeButton.snp.makeConstraints { make in
            make.top.equalTo(defaultAvatarImage.snp.bottom).offset(113)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(copyRandomCodeButton.snp.bottom).offset(20)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        mateCodeButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }
}
