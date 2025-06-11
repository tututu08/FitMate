//
//  CustomHeader.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//
import UIKit

// 테스트 필드 위 헤더명
class CustomHeader: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.textColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
