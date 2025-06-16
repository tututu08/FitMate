//
//  MyRandomCodeView.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import SnapKit

class MyRandomCodeButton: UIButton {
    
    /// 재사용이 필요하지 않고 하나의 화면에서 사용하는 카드형식의 뷰
    ///  뷰컨의 책임을 덜기 위해 파일을 별도 분리하여 작업
    private let title: UILabel = {
        let title = UILabel()
        title.text = "내 초대코드"
        title.textColor = .background400
        title.font = UIFont(name: "Pretendard-Medium", size: 14)
        title.textAlignment = .center
        return title
    }()
    
    let copyIcon = UIImageView()
    let randomCode = UILabel()
    
    private lazy var randomCodeStack: UIStackView = setrandomCodeStack()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setrandomCodeStack() -> UIStackView {
        copyIcon.image = UIImage(named: "copy")
        copyIcon.contentMode = .scaleAspectFit
        copyIcon.snp.makeConstraints { $0.size.equalTo(28) }
    
        randomCode.text = ""
        randomCode.font = UIFont(name: "Pretendard-SemiBold", size: 22)
        randomCode.textColor = .background900
        
        let stack = UIStackView(
            arrangedSubviews: [randomCode, copyIcon])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        return stack
    }
    
    private func setLayoutUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        
        addSubview(title)
        addSubview(randomCodeStack)
        
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        randomCodeStack.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
        
        
    }
    
}
