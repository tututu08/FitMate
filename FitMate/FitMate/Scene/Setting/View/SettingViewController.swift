
import UIKit
import RxSwift
import RxCocoa

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

        let output = viewModel.transform(input: input)

        output.pushEnabled
            .drive(settingView.noticeToggle.rx.isOn)
            .disposed(by: disposeBag)

        output.soundEnabled
            .drive(settingView.effectToggle.rx.isOn)
            .disposed(by: disposeBag)

        output.partnerEvent
            .emit(onNext: { [weak self] in
                guard let self else { return }
                
                self.showMateEndPopup()
                
            }).disposed(by: disposeBag)

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

                // 1. 메이트 UID 확인 후 있을 경우만 disconnect
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

                // 2. 계정 삭제
                let deleteAccountObservable = AuthService.shared.deleteAccount()
                    .do(onSuccess: {
                        print("🟢 [2] Firebase 계정 삭제 성공")
                    }, onError: { error in
                        print("🔴 [2] Firebase 계정 삭제 실패: \(error.localizedDescription)")
                    })
                    .asObservable()

                // 3. Firestore 문서 삭제
                let deleteUserDocObservable = FirestoreService.shared
                    .deleteDocument(collectionName: "users", documentName: self.uid)
                    .do(onSuccess: {
                        print("🟢 [3] Firestore 문서 삭제 성공")
                    }, onError: { error in
                        print("🔴 [3] Firestore 문서 삭제 실패: \(error.localizedDescription)")
                    })
                    .asObservable()

                // 순차 실행
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
                print("❌ [에러] 회원 탈퇴 전체 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private func showMateEndPopup() {
        settingView.isHidden = true

        let popup = MateEndPopupView()
        self.mateEndPopupView = popup
        popup.frame = self.view.bounds
        self.view.addSubview(popup)

        popup.cancelButton.rx.tap
            .bind { [weak self] in
                self?.mateEndPopupView?.removeFromSuperview()
                self?.settingView.isHidden = false
            }
            .disposed(by: disposeBag)

        popup.confirmButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self = self else { return .empty() }
                return FirestoreService.shared.findMateUid(uid: self.uid).asObservable()
            }
            .flatMapLatest { [weak self] mateUid -> Observable<Void> in
                guard let self = self else { return .empty() }
                
                // 메이트 UID가 없을 경우: 아무것도 하지 않고 화면만 초기화
                if mateUid.isEmpty {
                    print("메이트 UID 없음: 연결 끊기 생략")
                    return Observable.just(())
                }
                
                return FirestoreService.shared.disconnectMate(forUid: self.uid, mateUid: mateUid).asObservable()
            }
            .subscribe(
                onNext: { [weak self] in
                    print("메이트 연결 끊기 완료")
                    guard let self else { return }
                    guard let presentingVC = self.presentingViewController else { return }
                    self.dismiss(animated: true) {
                        let tabBarVC = TabBarController(uid: self.uid)
                        tabBarVC.modalPresentationStyle = .fullScreen
                        presentingVC.present(tabBarVC, animated: true)
                    }
                    
                },
                onError: { error in
                    print("끊기 실패: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }

    private func bindCloseButton() {
        settingView.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: false, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func logoutFunc() {
        /// navigationController를 통한 push는 불가능
        /// 해당 모달 띄운 뷰컨 -> presentingViewController을 안전하게 저장 후
        /// dismiss 후 그 뷰컨이 화면 전환을 맡도록 처리해야 함
        /// 뷰컨 간 이동 로직 썼는데 죽어라 안됐으
        guard let presentingVC = self.presentingViewController else { return }

        AuthService.shared.logout()
            .subscribe(onSuccess: { [weak self] in
                guard let self else { return }
                
                self.dismiss(animated: true) {
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.modalPresentationStyle = .fullScreen
                    presentingVC.present(nav, animated: true)
                }
            }, onFailure: { error in
                print("로그아웃 실패: \(error)")
            })
            .disposed(by: disposeBag)
    }


}
