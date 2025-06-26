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
                
                print("🔵 [1] 탈퇴 프로세스 시작 - UID: \(self.uid)")
                
                let disconnectObservable = FirestoreService.shared.findMateUid(uid: self.uid)
                    .do(onSuccess: { mateUid in
                        print("🟢 [1-1] findMateUid 완료 → mateUid: \(mateUid)")
                    }, onError: { error in
                        print("🔴 [1-1] findMateUid 실패: \(error.localizedDescription)")
                    })
                    .flatMap { mateUid -> Single<Void> in
                        if mateUid.isEmpty {
                            print("🟡 [1-2] 메이트 없음 → 연결 끊기 생략")
                            return .just(())
                        } else {
                            print("🟢 [1-2] 메이트 있음 → 연결 끊기 시도 for \(mateUid)")
                            return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid, reason: .byWithdrawal)
                                .do(onSuccess: {
                                    print("🟢 [1-3] disconnectMate 성공")
                                }, onError: { error in
                                    print("🔴 [1-3] disconnectMate 실패: \(error.localizedDescription)")
                                })
                        }
                    }
                    .asObservable()
                
                let deleteAccountObservable = AuthService.shared.deleteAccount()
                    .do(onSuccess: {
                        print("🟢 [2] Firebase 계정 삭제 성공")
                    }, onError: { error in
                        print("🔴 [2] Firebase 계정 삭제 실패: \(error.localizedDescription)")
                    })
                    .asObservable()
                
                let deleteUserDocObservable = FirestoreService.shared.deleteDocument(collectionName: "users", documentName: self.uid)
                    .do(onSuccess: {
                        print("🟢 [3] Firestore 문서 삭제 성공")
                    }, onError: { error in
                        print("🔴 [3] Firestore 문서 삭제 실패: \(error.localizedDescription)")
                    })
                    .asObservable()
                
                return disconnectObservable
                    .flatMap { deleteAccountObservable }
                    .flatMap { deleteUserDocObservable }
            }
            .subscribe(onNext: { [weak self] in
                guard let self, let presentingVC = self.presentingViewController else { return }
                
                print("✅ [4] 탈퇴 프로세스 전체 완료 → 로그인 화면 이동")
                
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

    // 회원 탈퇴 전체 처리 로직 (구글 재인증 포함)
    private func performWithdrawProcess() -> Observable<Void> {
        // 0. 로그인한 사용자 확인
        guard let user = Auth.auth().currentUser,
              let providerID = user.providerData.first?.providerID else {
            return Observable.error(NSError(domain: "WithdrawError", code: -1, userInfo: [NSLocalizedDescriptionKey: "로그인 정보 없음"]))
        }
        
        // 1. 로그인 방식에 따라 재인증 선택
        let reauthObservable: Observable<Void>
        
        switch providerID {
        case "google.com":
            // 구글 재인증 로직
            reauthObservable = AuthService.shared.reauthenticateGoogleUser()
                .asObservable()
                .do(
                    onNext: {
                        print("🟢 [1] 구글 재인증 성공")
                    },
                    onError: { error in
                        print("🔴 [1] 구글 재인증 실패: \(error.localizedDescription)")
                    }
                )
                .asObservable()
            
        case "apple.com":
            // 애플 로그인 사용자의 경우 재인증 로직
            reauthObservable = AuthService.shared.reauthenticateAppleUser()
                .asObservable()
                .do(
                    onNext: {
                        print("🟢 [1] 애플 재인증 성공")
                    },
                    onError: { error in
                        print("🔴 [1] 애플 재인증 실패: \(error.localizedDescription)")
                    }
                )
                .asObservable()
            
        case "password":
            // 카카오 로그인 (이메일/비밀번호 방식으로 저장) 사용자의 경우
            reauthObservable = AuthService.shared.fetchKakaoUser()
                .flatMap { kakaoUser in
                    AuthService.shared.reauthenticateKakaoUser(kakaoUser: kakaoUser)
                }
                .asObservable()
                .do(onNext: {
                    print("🟢 [1] 카카오 재인증 성공")
                }, onError: { error in
                    print("🔴 [1] 카카오 재인증 실패: \(error.localizedDescription)")
                })
            
        default:
            // 지원되지 않는 로그인 방식인 경우 에러 처리
            return Observable.error(NSError(domain: "WithdrawError", code: -2, userInfo: [NSLocalizedDescriptionKey: "지원하지 않는 로그인 방식입니다: \(providerID)"]))
        }

        // 2. 메이트 연결 끊기
        let disconnectObservable = FirestoreService.shared.findMateUid(uid: self.uid)
            .flatMap { mateUid -> Single<Void> in
                if mateUid.isEmpty {
                    // 메이트가 없으면 생략
                    print("🟡 [2] 메이트 없음 - 연결 끊기 생략")
                    return .just(())
                } else {
                    print("🟢 [2] 메이트 있음 - 연결 끊기 시도")
                    return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid, reason: .byWithdrawal)
                }
            }
            .do(onSuccess: {
                print("🟢 [2-2] 연결 끊기 완료")
            })
            .asObservable()
        
        // 3. Firebase 계정 삭제
        let deleteAccountObservable = AuthService.shared.deleteAccount()
            .do(onSuccess: {
                print("🟢 [3] Firebase 계정 삭제 성공")
            })
            .asObservable()
        
        // 4. Firestore 유저 문서 삭제
        let deleteUserDocObservable = FirestoreService.shared.deleteDocument(
            collectionName: "users",
            documentName: self.uid
        )
            .do(onSuccess: {
                print("🟢 [4] Firestore 문서 삭제 성공")
            })
            .asObservable()
        
        // 순차 실행: 재인증 → 연결 끊기 → 계정 삭제 → 문서 삭제
        return reauthObservable
            .flatMap { disconnectObservable }
            .flatMap { deleteAccountObservable }
            .flatMap { deleteUserDocObservable }
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
                    
                    // 팝업 제거
                    self.mateEndPopupView?.removeFromSuperview()
                    //self.settingView.isHidden = false // 다시 보이도록
                    
                    let alert = PartnerLeftAlertView()
                    alert.configure(title: "메이트 끊기 실패", description: "현재 연결된 메이트가 없습니다.")
                    alert.frame = self.view.bounds
                    self.view.addSubview(alert)
                    
                    // 확인 버튼 누르면 알림 제거
                    alert.confirmButton.rx.tap
                        .bind { [weak alert] in
                            alert?.removeFromSuperview()
                            self.settingView.isHidden = false
                        }
                        .disposed(by: disposeBag)
                    
                    return .empty() // ★ 더 이상 진행하지 않음
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
