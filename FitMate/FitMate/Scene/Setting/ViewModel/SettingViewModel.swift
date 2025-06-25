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

    private let pushEnabledRelay: BehaviorRelay<Bool>
    private let soundEnabledRelay: BehaviorRelay<Bool>
    private let disposeBag = DisposeBag()

    init() {
        let pushInitial = UserDefaults.standard.object(forKey: "pushEnabled") as? Bool ?? true
        let soundInitial = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true

        pushEnabledRelay = BehaviorRelay<Bool>(value: pushInitial)
        soundEnabledRelay = BehaviorRelay<Bool>(value: soundInitial)
    }

    func transform(input: Input) -> Output {
        input.pushToggleTapped
            .do(onNext: { isOn in
                UserDefaults.standard.set(isOn, forKey: "pushEnabled")
            })
            .bind(to: pushEnabledRelay)
            .disposed(by: disposeBag)

        input.soundToggleTapped
            .do(onNext: { isOn in
                UserDefaults.standard.set(isOn, forKey: "soundEnabled")
            })
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

    var initialPushEnabled: Bool {
        return pushEnabledRelay.value
    }

    var initialSoundEnabled: Bool {
        return soundEnabledRelay.value
    }

    func updatePushEnabled(_ value: Bool) {
        pushEnabledRelay.accept(value)
    }

    func updateSoundEnabled(_ value: Bool) {
        soundEnabledRelay.accept(value)
    }
}
