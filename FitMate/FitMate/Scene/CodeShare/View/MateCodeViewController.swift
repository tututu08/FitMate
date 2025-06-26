//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 메이트 코드 입력 화면을 담당하는 뷰컨트롤러
final class MateCodeViewController: BaseViewController {
    
    // MARK: - UI & ViewModel 구성
        
    /// 커스텀 뷰: 코드 입력 필드, 버튼, 타이틀 등 UI를 포함
    private let mateCodeView = MateCodeView()
    
    /// 메이트 코드 입력 비즈니스 로직 처리 ViewModel
    private let viewModel: MateCodeViewModel
    
    /// 현재 로그인한 사용자 UID (의존성 주입)
    private let uid: String
    
    /// 초기화 - uid를 기반으로 ViewModel 생성
    init(uid: String) {
        self.uid = uid
        viewModel = MateCodeViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 스토리보드 사용하지 않기 때문에 구현하지 않음
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 뷰 설정 - mateCodeView를 루트 뷰로 설정
    override func loadView() {
        self.view = mateCodeView
    }
    
    // 시스템 네비게이션바 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - ViewModel 바인딩
    override func bindViewModel() {
        // ViewModel로 전달할 사용자 입력
        let input = MateCodeViewModel.Input(
            enteredCode: mateCodeView.fillInMateCode.rx.text.orEmpty.asObservable(),
            completeTap: mateCodeView.completeButton.rx.tap.asObservable()
        )
        
        // ViewModel의 transform을 통해 Output 생성
        let output = viewModel.transform(input: input)
        
        // ViewModel이 방출하는 알림(Alert) 및 화면 이동(Navigation) 처리
        output.result
                    .drive(onNext: { [weak self] alert, navigation in
                        if let alert = alert {
                            self?.presentAlert(for: alert)
                        }
                        if let navigation = navigation {
                            self?.handleNavigation(navigation)
                        }
                    })
                    .disposed(by: disposeBag)
        
        // 버튼 활성화 여부에 따라 버튼 색상 및 상태 변경
        output.buttonActivated
            .drive(onNext: { [weak self] activated in
                guard let self = self else { return }
                let button = self.mateCodeView.completeButton
                button.isEnabled = activated
                button.backgroundColor = activated ? UIColor.primary500 : UIColor.background50
                button.setTitleColor(activated ? .white : .background500, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    /// 뒤로가기 버튼 탭 시 네비게이션 pop
    private func setupActions() {
        mateCodeView.backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    /// ViewModel이 방출한 Navigation 이벤트에 따라 화면 이동 처리
    private func handleNavigation(_ navigation: Navigation) {
        switch navigation {
        case .backTo:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Alert
    /// ViewModel이 방출한 AlertType 에 따라 알림창 구성 및 출력
    private func presentAlert(for alert: CustomAlertType) {
        let customType: CustomAlertType

        switch alert {
        case .inviteSent(let nickname):
            customType = .inviteSent(nickname: nickname)
        case .requestFailed(let message):
            customType = .requestFailed(message: message)
        case .mateRequest(let nickname):
            customType = .mateRequest(nickname: nickname)
        case .rejectRequest(message: let message):
            customType = .rejectRequest(message: message)
        }

        let alertVC = CustomAlertViewController(alertType: customType)
        self.present(alertVC, animated: true)
    }

    
}
