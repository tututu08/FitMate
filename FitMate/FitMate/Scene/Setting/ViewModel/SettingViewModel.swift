import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel {
    
    struct Input {
        let pushToggleTapped: Observable<Bool> // 푸시알림 토글 변경 이벤트
        let soundToggleTapped: Observable<Bool> // 효와금 토글 변경 이벤트
        let partnerTapped: Observable<Void> //메이트 끊기 버튼
        let logoutTapped: Observable<Void> // 로그아웃
        let withdrawTapped: Observable<Void> // 회원가입
    }
    
    struct Output {
        let pushEnabled: Driver<Bool> //현재 푸시알림 설정 상태
        let soundEnabled: Driver<Bool> //현재 효과음 설정 상태
        let partnerEvent: Signal<Void> //메이트 끊기 트리거
        let logoutEvent: Signal<Void> // 로그아웃 트리거
        let withdrawEvent: Signal<Void> //회원탈퇴 트리거
    }
    
    // 내부 상태저장용 릴레이
    private let pushEnabledRelay: BehaviorRelay<Bool>
    private let soundEnabledRelay: BehaviorRelay<Bool>
    private let disposeBag = DisposeBag()
    
    init() { // userdefaults에 저장된 초기 설정값을 읽어옴 (없다면 기본값은 true)
        let pushInitial = UserDefaults.standard.object(forKey: "pushEnabled") as? Bool ?? true
        let soundInitial = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        
        pushEnabledRelay = BehaviorRelay<Bool>(value: pushInitial)
        soundEnabledRelay = BehaviorRelay<Bool>(value: soundInitial)
    }
    
    // 인풋에서 아웃풋으로 변환 (뷰모델 바인딩)
    func transform(input: Input) -> Output {
        // 푸시 알림 토글 입력 처리
        input.pushToggleTapped
            .do(onNext: { isOn in
                // 로컬 저장소에 반영
                UserDefaults.standard.set(isOn, forKey: "pushEnabled")
            })
            .bind(to: pushEnabledRelay)
            .disposed(by: disposeBag)
        
        // 효과음 토글 입력 처리
        input.soundToggleTapped
            .do(onNext: { isOn in
                UserDefaults.standard.set(isOn, forKey: "soundEnabled")
                SoundManage.shared.isSoundEnabled = isOn
            })
            .bind(to: soundEnabledRelay)
            .disposed(by: disposeBag)
        
        // 최종적인 아웃풋 구성
        return Output(
            pushEnabled: pushEnabledRelay.asDriver(),
            soundEnabled: soundEnabledRelay.asDriver(),
            partnerEvent: input.partnerTapped.asSignal(onErrorJustReturn: ()),
            logoutEvent: input.logoutTapped.asSignal(onErrorJustReturn: ()),
            withdrawEvent: input.withdrawTapped.asSignal(onErrorJustReturn: ())
        )
    }
    
    // 외부에서 상태 초기화 시 사용
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
