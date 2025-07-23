//
//  AcceptViewController.swift
//  FitMate
//
//  Created by soophie on 6/23/25.
//

import UIKit
import SnapKit

class CustomAlertViewController: UIViewController {
    
    /// 외부 클로저
    /// alert 내부에서 외부 동작을 트리거하기 위함
    /// CustomAlertViewController의 내부 로직이 아니라 외부에서 어떤 동작을 정의해서 넣고
    /// Alert이 확인 버튼을 누를 때 호출해주는 방식이기 때문에 외부 클로저 필요
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    var alertView: CustomAlertView?
    
    private let alertType: CustomAlertType
    lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.titleLabel?.font = UIFont(name: "Pretendard-Regular", size: 18)
        cancel.setTitleColor(.background500, for: .normal)
        cancel.backgroundColor = .background50
        cancel.layer.cornerRadius = 4
        cancel.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return cancel
    }()
    lazy var confirmButton: UIButton = {
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
    // Alert 뒷배경을 반투명하게 설정 (화면 어둡게)
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    // 버튼 스타일, 높이, 텍스트 설정
    private func setupButtons() {
        // 버튼 높이 고정 -> SnapKit으로 오토레이아웃 설정
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        // alertType에 따라 버튼 텍스트 설정
        switch alertType.buttonStyle {
        case .single(let confirmText): // 버튼이 하나일 때
            confirmButton.setTitle(confirmText, for: .normal)
        case .double(let cancelText, let confirmText): // 버튼이 두 개일 때
            cancelButton.setTitle(cancelText, for: .normal)
            confirmButton.setTitle(confirmText, for: .normal)
        }
    }
    // 실제 AlertView 구성 및 화면에 배치
    private func setupAlertView() {
        // Builder 패턴으로 alertView 생성 준비
        let builder = CustomAlertView.AlertBuilder()
            .setTitle(alertType.title)  // 제목 설정
            .setMessage(alertType.message)  // 메시지 설정
        // 버튼 스타일에 따라 버튼 구성 넘김
        switch alertType.buttonStyle {
        case .single: // 버튼 한개만 필요할때
            builder.setStopButton(confirmButton)
        case .double:
            builder // 버튼 두개 필요할때
                .setResumeButton(cancelButton)
                .setStopButton(confirmButton)
        }
        // 최종적으로 alertView 완성
        let alertView = builder.buildAlert()
        
        self.alertView = alertView
        // alertView를 현재 화면-> view에 추가
        view.addSubview(alertView)
        
        // Hugging, Compression 우선순위 설정
        alertView.setContentHuggingPriority(.required, for: .vertical)
        alertView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // alertView의 위치 및 크기 설정
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview() // 화면 정중앙에 위치
            $0.width.equalTo(326) // 고정 너비
        }
    }
    // 취소 버튼 탭 시 실행되는 함수
    @objc private func didTapCancel() {
        
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }
    
    // 확인 버튼 탭 시 실행되는 함수
    @objc private func didTapConfirm() {
        // alertType에 따라 동작 분기
        switch alertType {
        case .mateRequest(let uid):
            // 메이트 요청 → 닫고 CodeShareViewController로 이동
            dismiss(animated: true) { [weak self] in
                
                self?.onConfirm?()// 외부에서 정의한 추가 동작 실행
                // 현재 Alert을 띄운 ViewController 기준으로 이동
                guard let presentingVC = self?.presentingViewController else { return }
                // 새로운 화면 구성 후 present
                let codeShareVC = CodeShareViewController(uid: uid, hasMate: false)
                let nav = UINavigationController(rootViewController: codeShareVC)
                nav.modalPresentationStyle = .fullScreen
                presentingVC.present(nav, animated: true)
            }
            
        case .inviteSent, .requestFailed, .rejectRequest, .sportsMateRequest, .alreadyCancel, .matchingFail:
            // 확인만 누르면 dismiss
            dismiss(animated: true) { [weak self] in
                self?.onConfirm?()
            }
        case .avatarPurchase(let name, let cost):
            dismiss(animated: true) { [weak self] in
                self?.onConfirm?() //  여기서 구매 처리 로직 실행하도록 트리거
            }
            
        case .avatarPurchase:
            dismiss(animated: true) { [weak self] in
                self?.onConfirm?()
            }
        }
    }
}
