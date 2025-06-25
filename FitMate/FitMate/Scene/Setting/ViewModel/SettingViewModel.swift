
import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel {

    struct Input {
        let pushToggleTapped: Observable<Bool>
        let soundToggleTapped: Observable<Bool>
        let partnerTapped: Observable<Void>
        let logoutTapped: Observable<Void>
        let withdrawTapped: Observable<Void>
    }
    struct Output {
        let pushEnabled: Driver<Bool>
        let soundEnabled: Driver<Bool>
        let partnerEvent: Signal<Void>
        let logoutEvent: Signal<Void>
        let withdrawEvent: Signal<Void>
    }

    let pushEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let soundEnabledRelay = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        input.pushToggleTapped
            .bind(to: pushEnabledRelay)
            .disposed(by: disposeBag)

        input.soundToggleTapped
            .bind(to: soundEnabledRelay)
            .disposed(by: disposeBag)

        return Output(
            pushEnabled: pushEnabledRelay.asDriver(),
            soundEnabled: soundEnabledRelay.asDriver(),
            partnerEvent: input.partnerTapped.asSignal(onErrorJustReturn: ()),
            logoutEvent: input.logoutTapped.asSignal(onErrorJustReturn: ()),
            withdrawEvent: input.withdrawTapped.asSignal(onErrorJustReturn: ())
        )
    }
}
