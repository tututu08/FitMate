//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CodeShareViewController: BaseViewController {

    private let codeShareView = CodeShareView()
    private let viewModel: CodeShareViewModel
    private let uid: String

    init(uid: String) {
        self.uid = uid
        self.viewModel = CodeShareViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = codeShareView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        let input = CodeShareViewModel.Input(
            copyTap: codeShareView.copyRandomCodeButton.rx.tap.asObservable(),
            mateCodeTap: codeShareView.mateCodeButton.rx.tap.asObservable(),
            closeTap: codeShareView.xButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.copiedMessage
            .drive(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)

        output.navigateToMateCode
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let mateVC = MateCodeViewController(uid: self.uid)
                self.navigationController?.pushViewController(mateVC, animated: true)
            })
            .disposed(by: disposeBag)

        output.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        output.inviteCode
            .drive(codeShareView.copyRandomCodeButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        output.showInviteAlert
            .emit(onNext: { [weak self] nickname in
                self?.showInviteAlert(from: nickname)
            })
            .disposed(by: disposeBag)
    }

    private func showInviteAlert(from nickname: String) {
        let alert = UIAlertController(
            title: "메이트 요청 도착",
            message: "\(nickname)님이 메이트 요청을 보냈습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.acceptInvite(fromUid: self.uid)
                .subscribe(onCompleted: {
                    self.showToast(message: "메이트가 연결되었습니다 🎉")
                }, onError: { error in
                    self.showToast(message: "수락 실패: \(error.localizedDescription)")
                })
                .disposed(by: self.disposeBag)
        }))

        alert.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { [weak self] _ in
            self?.viewModel.rejectInvite()
                .subscribe(onCompleted: {
                    self?.showToast(message: "메이트 요청을 거절했습니다")
                }, onError: { error in
                    self?.showToast(message: "거절 실패: \(error.localizedDescription)")
                })
                .disposed(by: self!.disposeBag)
        }))

        present(alert, animated: true)
    }

    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true

        toastLabel.frame = CGRect(x: 50, y: view.frame.size.height - 100, width: view.frame.size.width - 100, height: 35)
        view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }

    deinit {
        viewModel.stopListening()
    }
}

// MARK: - 수정전
//import UIKit
//import RxSwift
//import RxCocoa
//
//class CodeShareViewController: BaseViewController {
//    
//    private let codeShareView = CodeShareView()
//    private let viewModel: CodeShareViewModel
//    
//    private let uid: String // 로그인 사용자 uid
//    private let nickname: String
//    
//    init(uid: String, nickname: String) {
//        self.uid = uid // 의존성 주입
//        print("uid : \(uid)")
//        self.nickname = nickname
//        viewModel = CodeShareViewModel(uid: uid)
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    @MainActor required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func loadView() {
//        self.view = codeShareView
//    }
//    
//    // 네이게이션 숨기기
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
//    override func bindViewModel() {
//        // 메이트 코드 입력 버튼
//        codeShareView.mateCodeButton.rx.tap
//            .asDriver(onErrorDriveWith: .empty())
//            .drive(onNext: { [weak self] in
//                guard let self else { return }
//                let next = MateCodeViewController(uid: self.uid)
//                self.navigationController?.pushViewController(next, animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        // 상단 X 버튼
//        codeShareView.xButton.rx.tap
//            .asDriver(onErrorDriveWith: .empty())
//            .drive(onNext: { [weak self] in
//                //         let moveIn = MainViewController()
//                self?.navigationController?.popViewController(animated: true)
//            }).disposed(by: disposeBag)
//        let input = CodeShareViewModel.Input(
//            copyTab: codeShareView.copyRandomCodeButton.rx.tap.asObservable()
//        )
//        let output = viewModel.transform(input: input)
//        
//        output.showAlert
//            .drive(onNext: { [weak self] alertType in
//                let alert = UIAlertController(
//                    title: alertType.title,
//                    message: alertType.message,
//                    preferredStyle: .alert
//                )
//                alertType.actions.forEach { alert.addAction($0) }
//                self?.present(alert, animated: true)
//            })
//            .disposed(by: disposeBag)
//        
//        output.copiedText
//            .bind(to: codeShareView.copyRandomCodeButton.randomCode.rx.text)
//            .disposed(by: disposeBag)
//    }
//}
