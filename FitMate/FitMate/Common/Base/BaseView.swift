//
//  BaseView.swift
//  FitMate
//
//  Created by 강성훈 on 6/11/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UI 속성(컬러, 폰트 등) 기본 설정
    func configureUI() {
        // override해서 각 뷰에서 세부 설정 (backgroundColor 등)
    }
    
    // SnapKit 등으로 서브뷰 제약 설정
    func setupLayout() {
        // override해서 각 뷰에서 세부 설정
    }
}
