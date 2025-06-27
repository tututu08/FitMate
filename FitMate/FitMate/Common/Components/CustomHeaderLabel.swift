//
//  CustomHeader.swift
//  FitMate
//
//  Created by soophie on 6/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CustomHeaderLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont(name: "Pretendard-Medium", size: 14)
        self.textColor = .background500
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
