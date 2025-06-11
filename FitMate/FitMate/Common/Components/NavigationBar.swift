//
//  Components.swift
//  FitMate
//
//  Created by 김은서 on 6/9/25.
//

import UIKit

extension UINavigationBar {
    func applyCustomAppearance(backgroundColor: UIColor = .black, titleColor: UIColor = .white, font: UIFont = .boldSystemFont(ofSize: 20)) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: font
        ]
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
        self.compactAppearance = appearance
        
        self.tintColor = titleColor // 뒤로가기 버튼 등 색상 설정
    }
}
