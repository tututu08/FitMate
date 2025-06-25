import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

final class SettingViewController: UIViewController {
    
    private let container = UIView()
    private let settingView = SettingView()
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()
    
    private var withdrawPopupView: WithdrawPopupView?
    private var mateEndPopupView: MateEndPopupView?
    
    private let uid: String
    
    init(uid: String) {
        self.uid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = container
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(settingView)
        settingView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self else { return }
            if let data = snapshot?.data(), let isPushOn = data["pushEnabled"] as? Bool {
                self.viewModel.updatePushEnabled(isPushOn)
            }
        }

        settingView.noticeToggle.isOn = viewModel.initialPushEnabled
        settingView.effectToggle.isOn = viewModel.initialSoundEnabled

        bindViewModel()
        bindCloseButton()
    }
    
    private func bindViewModel() {
        let input = SettingViewModel.Input(
            pushToggleTapped: settingView.noticeToggle.rx.isOn.skip(1).asObservable(),
            soundToggleTapped: settingView.effectToggle.rx.isOn.skip(1).asObservable(),
            partnerTapped: settingView.partnerButton.rx.tap.asObservable(),
            logoutTapped: settingView.logoutButton.rx.tap.asObservable(),
            withdrawTapped: settingView.withdrawButton.rx.tap.asObservable()
        )
        
        input.pushToggleTapped
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }

                if isOn {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                } else {
                    UIApplication.shared.unregisterForRemoteNotifications()
                }

                FirestoreService.shared.updateDocument(
                    collectionName: "users",
                    documentName: uid,
                    fields: ["pushEnabled": isOn]
                )
                .subscribe(onSuccess: {
                    print("상태 저장 완료: \(isOn)")
                }, onFailure: { error in
                    print("상태 저장 실패: \(error.localizedDescription)")
                })
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        let output = viewModel.transform(input: input)
        
        output.pushEnabled
            .drive(settingView.noticeToggle.rx.isOn)
            .disposed(by: disposeBag)
        
        output.soundEnabled
            .drive(settingView.effectToggle.rx.isOn)
            .disposed(by: disposeBag)
        
        output.partnerEvent
            .emit(onNext: { [weak self] in
                self?.showMateEndPopup()
            })
            .disposed(by: disposeBag)
        
        output.logoutEvent
            .emit(onNext: { [weak self] in
                self?.logoutFunc()
            })
            .disposed(by: disposeBag)
        
        output.withdrawEvent
            .emit(onNext: { [weak self] in
                self?.showWithdrawPopup()
            })
            .disposed(by: disposeBag)
    }
    
    private func showWithdrawPopup() {
        settingView.isHidden = true
        
        let popup = WithdrawPopupView()
        self.withdrawPopupView = popup
        popup.frame = view.bounds
        view.addSubview(popup)
        
        popup.cancelButton.rx.tap
            .bind { [weak self] in
                self?.withdrawPopupView?.removeFromSuperview()
                self?.settingView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        popup.confirmButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                
                let disconnectObservable = FirestoreService.shared.findMateUid(uid: self.uid)
                    .flatMap { mateUid -> Single<Void> in
                        if mateUid.isEmpty {
                            return .just(())
                        } else {
                            return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid, reason: .byWithdrawal)
                        }
                    }
                    .asObservable()
                
                let deleteAccountObservable = AuthService.shared.deleteAccount().asObservable()
                let deleteUserDocObservable = FirestoreService.shared.deleteDocument(collectionName: "users", documentName: self.uid).asObservable()
                
                return disconnectObservable
                    .flatMap { deleteAccountObservable }
                    .flatMap { deleteUserDocObservable }
            }
            .subscribe(onNext: { [weak self] in
                guard let self, let presentingVC = self.presentingViewController else { return }
                self.dismiss(animated: true) {
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.modalPresentationStyle = .fullScreen
                    presentingVC.present(nav, animated: true)
                }
            }, onError: { error in
                print("회원 탈퇴 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func showMateEndPopup() {
        settingView.isHidden = true
        
        let popup = MateEndPopupView()
        self.mateEndPopupView = popup
        popup.frame = view.bounds
        view.addSubview(popup)
        
        popup.cancelButton.rx.tap
            .bind { [weak self] in
                self?.mateEndPopupView?.removeFromSuperview()
                self?.settingView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        popup.confirmButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self else { return .empty() }
                return FirestoreService.shared.findMateUid(uid: self.uid).asObservable()
            }
            .flatMapLatest { [weak self] mateUid -> Observable<Void> in
                guard let self else { return .empty() }
                if mateUid.isEmpty {
                    return .just(())
                }
                return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid).asObservable()
            }
            .subscribe(onNext: { [weak self] in
                guard let self, let presentingVC = self.presentingViewController else { return }
                self.dismiss(animated: true) {
                    let tabBarVC = TabBarController(uid: self.uid)
                    tabBarVC.modalPresentationStyle = .fullScreen
                    presentingVC.present(tabBarVC, animated: true)
                }
            }, onError: { error in
                print("메이트 끊기 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    private func bindCloseButton() {
        settingView.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    private func logoutFunc() {
        guard let presentingVC = self.presentingViewController else { return }
        
        AuthService.shared.logout()
            .subscribe(onSuccess: { [weak self] in
                self?.dismiss(animated: true) {
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.modalPresentationStyle = .fullScreen
                    presentingVC.present(nav, animated: true)
                }
            }, onFailure: { error in
                print("로그아웃 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
