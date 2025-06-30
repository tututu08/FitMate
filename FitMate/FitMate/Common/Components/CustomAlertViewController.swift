//
//  AcceptViewController.swift
//  FitMate
//
//  Created by soophie on 6/23/25.
//

import UIKit
import SnapKit

final class CustomAlertViewController: UIViewController {
    
    /// 외부 클로저
    /// alert 내부에서 외부 동작을 트리거하기 위함
    /// CustomAlertViewController의 내부 로직이 아니라 외부에서 어떤 동작을 정의해서 넣고
    /// Alert이 확인 버튼을 누를 때 호출해주는 방식이기 때문에 외부 클로저 필요
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    private let alertType: CustomAlertType
    private lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        cancel.setTitleColor(.background500, for: .normal)
        cancel.backgroundColor = .background50
        cancel.layer.cornerRadius = 4
        cancel.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return cancel
    }()
    private lazy var confirmButton: UIButton = {
        let confirm = UIButton()
        confirm.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        confirm.setTitleColor(.white, for: .normal)
        confirm.backgroundColor = .primary500
        confirm.layer.cornerRadius = 4
        confirm.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        return confirm
    }()
    
    init(alertType: CustomAlertType) {
        self.alertType = alertType
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupButtons()
        setupAlertView()
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setupButtons() {
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        switch alertType.buttonStyle {
        case .single(let confirmText):
            confirmButton.setTitle(confirmText, for: .normal)
        case .double(let cancelText, let confirmText):
            cancelButton.setTitle(cancelText, for: .normal)
            confirmButton.setTitle(confirmText, for: .normal)
        }
    }
    
    private func setupAlertView() {
        let builder = CustomAlertView.AlertBuilder()
            .setTitle(alertType.title)
            .setMessage(alertType.message)
        
        switch alertType.buttonStyle {
        case .single: // 버튼 한개만 필요할때
            builder.setStopButton(confirmButton)
        case .double:
            builder // 버튼 두개 필요할때
                .setResumeButton(cancelButton)
                .setStopButton(confirmButton)
        }
        
        let alertView = builder.buildAlert()
        view.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            //$0.leading.trailing.equalToSuperview().inset(23)
            $0.width.equalTo(326)
        }
    }
    
    @objc private func didTapCancel() {
        //print("🔵 [취소 버튼 탭]")
        
        dismiss(animated: true) { [weak self] in
            //print("🔵 [Alert 닫힘 - 취소]")
            self?.onCancel?()
        }
    }
    
    @objc private func didTapConfirm() {
        //print("🟢 [확인 버튼 탭] alertType: \(alertType)")
        switch alertType {
        case .mateRequest(let uid):
            //print("🟢 [mateRequest alert] -> CodeShareViewController 이동")
            dismiss(animated: true) { [weak self] in
                //print("🟢 [Alert 닫힘 - mateRequest]")
                self?.onConfirm?()
                guard let presentingVC = self?.presentingViewController else { return }
                let codeShareVC = CodeShareViewController(uid: uid, hasMate: false)
                let nav = UINavigationController(rootViewController: codeShareVC)
                nav.modalPresentationStyle = .fullScreen
                presentingVC.present(nav, animated: true)
            }
            
        case .inviteSent, .requestFailed, .rejectRequest, .sportsMateRequest, .alreadyCancel, .matchingFail:
            // 확인만 누르면 dismiss
            //print("🟢 [일반 확인 alert] → dismiss 진행")
            dismiss(animated: true) { [weak self] in
                //print("🟢 [Alert 닫힘 - 일반 확인]")
                self?.onConfirm?()
            }
            
        }
    }
}
