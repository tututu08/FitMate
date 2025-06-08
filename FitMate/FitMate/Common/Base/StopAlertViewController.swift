//
//  StopAlertViewController.swift
//  FitMate
//
//  Created by Sophie on 6/8/25.
//

import UIKit

class StopAlertViewController: UIViewController {

    private let resumeButton = {
        let resume = UIButton()
        resume.setTitle("일시정지", for: .normal)
        resume.setTitleColor(.darkGray, for: .normal)
        resume.backgroundColor = .lightGray
        return resume
    }()
    
    private let stopButton = {
        let resume = UIButton()
        resume.setTitle("그만하기", for: .normal)
        resume.setTitleColor(.darkGray, for: .normal)
        resume.backgroundColor = .lightGray
        return resume
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let alert = CustomAlertView.AlertBuilder()
            .setIcon(UIImageView(image: UIImage(named: "stop")))
            .setTitle("정말 그만하시겠어요?")
            .setMessage("기록은 안전하게 저장됩니다. 단, 이 선택은 상대방의 운동도 함께 중단시킵니다. 상대방도 준비가 되었는지 확인해 주세요.")
            .setResumeButton(resumeButton)
            .setStopButton(stopButton)
            .buildAlert()
       
        view.addSubview(alert)
        alert.center = view.center
    }
    
}
