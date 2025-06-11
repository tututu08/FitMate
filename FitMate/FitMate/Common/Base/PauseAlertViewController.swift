//
//  PauseAlertViewController.swift
//  FitMate
//
//  Created by Sophie on 6/8/25.
//

import UIKit
import SnapKit

class PauseAlertViewController: UIViewController {
    
    private let resumeButton = {
        let resume = UIButton()
        resume.setTitle("계속하기", for: .normal)
        resume.setTitleColor(.darkGray, for: .normal)
        resume.backgroundColor = .systemPurple
        resume.snp.makeConstraints {make in
            make.height.equalTo(48)
        }
        return resume
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let alert = CustomAlertView.AlertBuilder()
            .setIcon(UIImageView(image: UIImage(named: "pause")))
            .setTitle("운동이 잠시 멈췄어요")
            .setMessage("운동이 일시정지 되었습니다. \n준비되면 이어서 계속해 보세요!")
            .setResumeButton(resumeButton)
            .buildAlert()
        
        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
