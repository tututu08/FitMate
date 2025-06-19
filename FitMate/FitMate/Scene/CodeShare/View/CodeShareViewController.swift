//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

/// 메이트 초대 코드 공유 화면을 담당하는 ViewController
/// - 역할: 초대 코드 복사, 메이트 코드 입력 화면 이동, 초대 수락/거절 처리, 매칭 완료 시 홈화면 전환
final class CodeShareViewController: BaseViewController {

    // MARK: - Properties

    private let codeShareView = CodeShareView()
    private let viewModel: CodeShareViewModel
    private let uid: String // 로그인한 사용자 UID

    // MARK: - Initializer

    /// 사용자 UID를 주입 받아 ViewModel을 초기화
    init(uid: String) {
        self.uid = uid
        self.viewModel = CodeShareViewModel(uid: uid)
        super.init(nibName: nil, bundle: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = codeShareView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    // MARK: - Binding

    /// ViewModel의 Input/Output을 구성하고 UI 이벤트에 바인딩
    private func bind() {
        let input = CodeShareViewModel.Input(
            copyTap: codeShareView.copyRandomCodeButton.copyIcon.rx.tap.asObservable(),
            mateCodeTap: codeShareView.mateCodeButton.rx.tap.asObservable(),
            closeTap: codeShareView.xButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        // 초대 코드 복사 후 Toast 출력
        output.copiedMessage
            .drive(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)

        // 메이트 코드 입력 화면으로 이동
        output.navigateToMateCode
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                let mateVC = MateCodeViewController(uid: self.uid)
                self.navigationController?.pushViewController(mateVC, animated: true)
            })
            .disposed(by: disposeBag)

        // 닫기 버튼 눌렀을 때 현재 화면 dismiss
        output.dismiss
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        // 사용자 초대 코드 텍스트 바인딩
        output.inviteCode
            .drive(codeShareView.copyRandomCodeButton.randomCode.rx.text)
            .disposed(by: disposeBag)

        // 상대방이 나에게 초대 보냈을 때 Alert 표시
        output.showInviteAlert
            .emit(onNext: { [weak self] nickname in
                self?.showInviteAlert(from: nickname)
            })
            .disposed(by: disposeBag)

        // 메이트 수락되었을 때 홈(TabBar) 화면으로 이동
        output.transitionToMain
            .emit(onNext: { [weak self] in
                self?.transitionToMain(uid: self?.uid ?? "")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Alert

    /// 상대방으로부터 초대 요청이 왔을 때 수락/거절 Alert 처리
    private func showInviteAlert(from nickname: String) {
        // Firestore에서 fromUid를 조회
        FirestoreService.shared.fetchDocument(collectionName: "users", documentName: uid)
            .subscribe(onSuccess: { [weak self] data in
                guard let self = self else { return }
                guard let fromUid = data["fromUid"] as? String else { return }

                let alert = UIAlertController(
                    title: "메이트 요청 도착",
                    message: "\(nickname)님이 메이트 요청을 보냈습니다.",
                    preferredStyle: .alert
                )

                // 수락 버튼 눌렀을 때 매칭 수락 처리 및 화면 전환
                alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { _ in
                    self.viewModel.acceptInvite(fromUid: fromUid)
                        .subscribe(onCompleted: {
                            self.transitionToMain(uid: self.uid)
                        }, onError: { error in
                            self.showToast(message: "수락 실패: \(error.localizedDescription)")
                        })
                        .disposed(by: self.disposeBag)
                }))

                // 거절 버튼 눌렀을 때 Firestore 상태 초기화
                alert.addAction(UIAlertAction(title: "거절", style: .cancel, handler: { _ in
                    self.viewModel.rejectInvite()
                        .subscribe(onCompleted: {
                            self.showToast(message: "메이트 요청을 거절했습니다")
                        }, onError: { error in
                            self.showToast(message: "거절 실패: \(error.localizedDescription)")
                        })
                        .disposed(by: self.disposeBag)
                }))

                self.present(alert, animated: true)

            }, onFailure: { error in
                print("fromUid 조회 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 화면 전환

    /// 매칭 수락 완료 후 TabBarController로 전환하여 메인 화면 진입
    private func transitionToMain(uid: String) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate else { return }

        let tabBarController = TabBarController(uid: uid)

        guard let window = sceneDelegate.window else { return }

        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
            window.rootViewController = tabBarController
        })
    }

    // MARK: - Toast

    /// 사용자에게 간단한 메시지를 Toast 형태로 출력
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

    // MARK: - 메모리 해제

    /// Firestore 실시간 리스너 해제
    deinit {
        viewModel.stopListening()
    }
}
