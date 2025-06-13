
import UIKit
import RxSwift
import RxCocoa

final class SettingViewController: UIViewController {

    private let settingView = SettingView()
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()

    override func loadView() {
        self.view = settingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
            .emit(onNext: {
                // 파트너 끊기 로직 추가예정
            })
            .disposed(by: disposeBag)

        output.logoutEvent
            .emit(onNext: {
                // 로그아웃 로직 추가예정
            })
            .disposed(by: disposeBag)

        output.withdrawEvent
            .emit(onNext: {
                // 회원 탈퇴 로직 추가예정
            })
            .disposed(by: disposeBag)
    }

    private func bindCloseButton() {
        settingView.closeButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
