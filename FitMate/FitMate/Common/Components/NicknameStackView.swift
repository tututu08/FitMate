//
//  NicknameStackView.swift
//  FitMate
//
//  Created by soophie on 6/12/25.
//

import UIKit
import SnapKit

class NicknameStackView: UIStackView {
/// 메인 화면에서 캐릭터 위에 뜨는 arrow와 닉네임을 묶어 스택뷰로 컴포넌트화 함
/// 사유: 뷰에서의 코드 가독성을 높이기 위함 / 스택으로 묶어 레이아웃 잡기 용이
    private var arrowImage: UIImageView = {
       let arrow = UIImageView()
        arrow.contentMode = .scaleAspectFit
        arrow.image = UIImage( // 메이트와 유저 본인 구분 위해 tintColor로 화살표 색상 변경 가능하도록 설정 
            named: "arrow")?.withRenderingMode(.alwaysTemplate)
        return arrow
    }()
    
    private var nicknameLabel: UILabel = {
       let nickname = UILabel()
        nickname.font = UIFont.systemFont(ofSize: 16)
        nickname.textAlignment = .center
        return nickname
    }()
    
    /// 외부에서 닉네임을 넘겨 받아
    ///  그 닉네임으로 UI 구성하는 초기화 로직
    init(nickname: String, textColor: UIColor, font: UIFont, arrowColor: UIColor) {
        super.init(frame: .zero)
        setStack(nickname: nickname)
        nicknameLabel.textColor = textColor
        nicknameLabel.font = font
        arrowImage.tintColor = arrowColor
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setStack(nickname: String) {
        axis = .horizontal // 가로로 나란히 배치
        spacing = 4
        alignment = .center
        
        nicknameLabel.text = nickname // 전달 받은 닉네임을 nicknameLabel에 적용
        
        addArrangedSubview(arrowImage)
        addArrangedSubview(nicknameLabel)
        
        arrowImage.snp.makeConstraints { make in
            make.size.equalTo(9)
        }
       
    }
}
