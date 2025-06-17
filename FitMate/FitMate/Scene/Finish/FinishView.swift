//
//  FinishView.swift
//  FitMate
//
//  Created by 강성훈 on 6/15/25.
//

import UIKit

class FinishViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "축하합니다!\n목표 달성!"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 28)
        label.numberOfLines = 0
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
