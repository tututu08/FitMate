//
//  StopAlertViewController.swift
//  FitMate
//
//  Created by Sophie on 6/8/25.
//
import SnapKit
import UIKit

class StopAlertViewController: UIViewController {

    private let resumeButton = {
        let resume = UIButton()
        resume.setTitle("일시정지", for: .normal)
        resume.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        resume.setTitleColor(.background500, for: .normal)
        resume.backgroundColor = .background50
        return resume
    }()
    
    private let stopButton = {
        let stop = UIButton()
        stop.setTitle("그만하기", for: .normal)
        stop.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        stop.setTitleColor(.white, for: .normal)
        stop.backgroundColor = .primary500
        return stop
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
        
        stopButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    func setAlert() {
        let alert = CustomAlertView.AlertBuilder()
            .setIcon(UIImageView(image: UIImage(named: "stop")))
            .setTitle("정말 그만하시겠어요?")
            .setMessage("기록은 안전하게 저장됩니다. \n단, 이 선택은 상대방의 운동도 함께 중단시킵니다. \n상대방도 준비가 되었는지 확인해 주세요.")
            .setResumeButton(resumeButton)
            .setStopButton(stopButton)
            .buildAlert()
       
        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
