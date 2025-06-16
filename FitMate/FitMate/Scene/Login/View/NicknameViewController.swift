//
//  NicknameViewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import RxSwift
import RxCocoa

class NicknameViewController: BaseViewController {
    private let viewModel = NicknameViewModel() // 뷰모델
    
    private let nicknameView = NicknameView()
    
    private let uid: String // 로그인 사용자 uid
    
    init(uid: String) {
        self.uid = uid // 의존성 주입
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = nicknameView
    }
    
    // 네비게이션 영역 숨김
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func bindViewModel() {
//        nicknameView.registerButton.rx.tap
//            .asDriver(onErrorDriveWith: .empty())
//            .drive(onNext: { [weak self] _ in
//                guard let self else { return }
//                let codeShareView = CodeShareVIewController(uid: self.uid)
//                self.navigationController?.pushViewController(
//                    codeShareView, animated: true)
//            })
//            .disposed(by: disposeBag)
        
        // MARK: input output
        let input = NicknameViewModel.Input(
            nicknameText: nicknameView.nicknameField.rx.text.asObservable(),
            nextButtonTap: nicknameView.registerButton.rx.tap.asObservable(),
            uid: self.uid
        )
        
        let output = viewModel.transform(input: input)
        
        // 유효성 메시지 라벨 바인딩 (Driver → .drive)
        output.validationMessage
            .drive(nicknameView.validationMessageLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 닉네임 유효성 여부에 따라 다음 버튼 활성/비활성
        output.isValidNickname
            .drive(nicknameView.registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 화면 이동
        output.step
            .drive(onNext: { [weak self] step in
                guard let self else { return }
                switch step {
                case .goNext:
                    let nextVC = CodeShareVIewController(uid: self.uid)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                case .error(let message):
                    self.showErrorToast(message: message)
                case .none:
                    break
                }
            }).disposed(by: disposeBag)
    }

    func showErrorToast(message: String) {
        let alert = UIAlertController(title: "닉네임 등록 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

}
