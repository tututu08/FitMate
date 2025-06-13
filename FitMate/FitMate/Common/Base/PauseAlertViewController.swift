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
        resume.setTitleColor(.white, for: .normal)
        resume.backgroundColor = .primary500
        return resume
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setAlert()
    }
   
    func setUpUI() {
        /// 사용할때
        /// vc.modalPresentationStyle = .overFullScreen
        /// → 배경이 반투명하게 보이도록 기존 화면 위에 겹쳐 띄우기 위해 설정 필요
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 필터 역할
        
        resumeButton.snp.makeConstraints {make in
            make.height.equalTo(48)
        }
    }
    
    func setAlert() {
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
