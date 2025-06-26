
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
            if let data = snapshot?.data(),
               let isPushOn = data["pushEnabled"] as? Bool,
               let isSoundOn = data["soundEnabled"] as? Bool {
                self.settingView.noticeToggle.setOn(isPushOn, animated: false)
                self.settingView.effectToggle.setOn(isSoundOn, animated: false)
                self.viewModel.updatePushEnabled(isPushOn)
                self.viewModel.updateSoundEnabled(isSoundOn)
            }
        }
        
        bindViewModel()
        bindCloseButton()
        bindCustomSwitch()
    }
    
    private func bindCustomSwitch() {
        settingView.noticeToggle.valueChanged = { [weak self] isOn in
            self?.handlePushSwitchChange(isOn: isOn)
        }

        settingView.effectToggle.valueChanged = { [weak self] isOn in
            self?.handleSoundSwitchChange(isOn: isOn)
        }
    }

    private func handlePushSwitchChange(isOn: Bool) {
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
            print("푸시 상태 저장 완료: \(isOn)")
        }, onFailure: { error in
            print("푸시 상태 저장 실패: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }

    private func handleSoundSwitchChange(isOn: Bool) {
        FirestoreService.shared.updateDocument(
            collectionName: "users",
            documentName: uid,
            fields: ["soundEnabled": isOn]
        )
        .subscribe(onSuccess: {
            print("효과음 상태 저장 완료: \(isOn)")
        }, onFailure: { error in
            print("효과음 상태 저장 실패: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = SettingViewModel.Input(
            pushToggleTapped: .empty(),
            soundToggleTapped: .empty(),
            partnerTapped: settingView.partnerButton.rx.tap.asObservable(),
            logoutTapped: settingView.logoutButton.rx.tap.asObservable(),
            withdrawTapped: settingView.withdrawButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
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
    
    // 회원 탈퇴
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
                return self.performWithdrawProcess()
            }
            .subscribe(onNext: { [weak self] in
                self?.navigateToLogin()
            }, onError: { error in
                print("회원 탈퇴 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func performWithdrawProcess() -> Observable<Void> {
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
    
    private func navigateToLogin() {
        guard let presentingVC = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            presentingVC.present(nav, animated: true)
        }
    }
    
    // 메이트 끊기
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
                    
                    // ✅ 1. 팝업 제거
                    self.mateEndPopupView?.removeFromSuperview()
                    //self.settingView.isHidden = false // 다시 보이도록
                    
                    let alert = PartnerLeftAlertView()
                    alert.configure(title: "메이트 끊기 실패", description: "현재 연결된 메이트가 없습니다.")
                    alert.frame = self.view.bounds
                    self.view.addSubview(alert)
                    
                    // 3. 확인 버튼 누르면 알림 제거
                    alert.confirmButton.rx.tap
                        .bind { [weak alert] in
                            alert?.removeFromSuperview()
                            self.settingView.isHidden = false
                        }
                        .disposed(by: disposeBag)
                    
                    // ✅ 2. 알림은 조금 뒤에 띄우기 (팝업 제거가 UI적으로 확실히 끝난 뒤)
//                    //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        let alert = CustomAlertViewController(alertType: .youHaveNoMate(message: "현재 메이트가 없습니다."))
//                        alert.onConfirm = { //[weak self] in
//                            // 확인 누르면 아무 처리 없이 설정 화면 유지
//                            //self?.settingView.isHidden = false
//                        }
//                        self.present(alert, animated: true)
//                    //}
                    
                    return .empty() // ★ 더 이상 진행하지 않음
                }
                return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid).asObservable()
            }
            .subscribe(onNext: { [weak self] in
                self?.navigateToMain()
            }, onError: { error in
                print("메이트 끊기 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func navigateToMain() {
        guard let presentingVC = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            let tabBarVC = TabBarController(uid: self.uid)
            tabBarVC.modalPresentationStyle = .fullScreen
            presentingVC.present(tabBarVC, animated: true)
        }
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
