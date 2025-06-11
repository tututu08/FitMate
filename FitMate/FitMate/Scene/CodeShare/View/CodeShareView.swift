//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit

class CodeShareView: UIView {
    
    let codeShareViewTitle: UILabel = {
        let title = UILabel()
        title.text = "코드 공유"
        title.textColor = .white
        title.font = .systemFont(ofSize: 20)
        return title
    }()
    
    let guideMent: UILabel = {
        let guide = UILabel()
        guide.text = "파트너 연결 후 시작해보세요"
        guide.textColor = .lightGray
        guide.font = .systemFont(ofSize: 16)
        return guide
    }()
    
    let defaultAvatarImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "mumu")
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let copyRandomCodeView = MyRandomCodeView()
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    let mateCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("메이트 코드 입력", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.backgroundColor = .purple
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [codeShareViewTitle, guideMent, defaultAvatarImage,
         copyRandomCodeView, line, mateCodeButton].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        codeShareViewTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
        }
        
        guideMent.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(113)
            make.leading.trailing.equalToSuperview().inset(94)
        }
        
        defaultAvatarImage.snp.makeConstraints { make in
            make.top.equalTo(guideMent.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(110)
            make.height.equalTo(defaultAvatarImage.snp.width)
        }
        
        copyRandomCodeView.snp.makeConstraints { make in
            make.top.equalTo(defaultAvatarImage.snp.bottom).offset(113)
            make.centerX.equalToSuperview()
            make.width.equalTo(335)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(copyRandomCodeView.snp.bottom).offset(20)
            make.height.equalTo(1)
            make.width.equalTo(335)
            make.centerX.equalToSuperview()
        }
        
        mateCodeButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }
}
