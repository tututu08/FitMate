
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
                self?.showMateEndPopup()
            })
            .disposed(by: disposeBag)

        output.logoutEvent
            .emit(onNext: {
                // 로그아웃연결부분
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
            .bind {
                print("탈퇴") //탈퇴연결부분
            }
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
            .bind {
                print("메이트 종료") //메이트연결부분
            }
            .disposed(by: disposeBag)
    }

    private func bindCloseButton() {
        settingView.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: false, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
