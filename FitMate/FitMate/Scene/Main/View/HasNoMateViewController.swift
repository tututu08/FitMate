//
//  HasNoMateViewController.swift
//  FitMate
//
//  Created by soophie on 6/17/25.
//

import UIKit

class HasNoMateViewController: UIViewController {
    
    private let uid: String
    
    private let laterButton = {
        let later = UIButton()
        later.setTitle("나중에", for: .normal)
        later.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        later.setTitleColor(.background500, for: .normal)
        later.backgroundColor = .background50
        return later
    }()
    
    private let addMateButton = {
        let addMate = UIButton()
        addMate.setTitle("추가하기", for: .normal)
        addMate.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        addMate.setTitleColor(.white, for: .normal)
        addMate.backgroundColor = .primary500
        return addMate
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setAlert()
    }
    
    init(uid: String) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        /// 사용할때
        /// vc.modalPresentationStyle = .overFullScreen
        /// → 배경이 반투명하게 보이도록 기존 화면 위에 겹쳐 띄우기 위해 설정 필요
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 필터 역할
        laterButton.snp.makeConstraints {make in
            make.height.equalTo(48)
        }
        
        addMateButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }
    
    func setAlert() {
        let alert = CustomAlertView.AlertBuilder()
            .setTitle("메이트가 등록되지 않았습니다")
            .setMessage("서비스 이용을 위해 \n메이트를 먼저 등록해주세요.")
            .setResumeButton(laterButton)
            .setStopButton(addMateButton)
            .buildAlert()
       
        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(23)
        }
        
        laterButton.addTarget(self, action: #selector(laterAction), for: .touchUpInside)
        addMateButton.addTarget(self, action: #selector(goToAddMate), for: .touchUpInside)
    }
    
    @objc private func laterAction() {
        dismiss(animated: true)
    }
    
    @objc private func goToAddMate() {
            let codeShareVC = CodeShareViewController(uid: self.uid, hasMate: false)

            // 네비게이션 컨트롤러 래핑해서 모달 전체화면으로 present
            let nav = UINavigationController(rootViewController: codeShareVC)
            nav.modalPresentationStyle = .fullScreen
            
            // 현재 모달 닫고 새로운 네비게이션 흐름 시작
            self.dismiss(animated: true) {
                // presentingViewController 기준으로 present
                self.presentingViewController?.present(nav, animated: true, completion: nil)
            }
    }

}
