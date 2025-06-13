import Foundation
import CoreMotion
import RxSwift
import RxCocoa

// 점프 줄넘기 협동 뷰모델(Rx, CoreMotion 활용)
final class JumpRopeCoopViewModel: ViewModelType {

    // Input: 외부에서 받아올 신호 정의
    struct Input {
        let start: Observable<Void>           // 측정 시작 트리거
        let mateCount: Observable<Int>        // 메이트의 점프 수(네트워크 등에서 들어올 수 있음)
    }

    // Output: View/VC에서 구독할 신호 정의
    struct Output {
        let myCountText: Driver<String>       // 내 점프 수(문자열)
        let mateCountText: Driver<String>     // 메이트 점프 수(문자열)
        let progress: Driver<CGFloat>         // 전체 진행률(비율)
    }

    private let motionManager = CMMotionManager() // CoreMotion 관리
    private let disposeBag = DisposeBag()         // Rx 메모리 관리

    // 내/메이트 점프 수 Relay
    private let myCountRelay = BehaviorRelay<Int>(value: 0)
    private let mateCountRelay = BehaviorRelay<Int>(value: 0)
    
    // 목표 카운트(외부에서 입력, 예: 100)
    let goalCount: Int

    // 생성자 목표 카운트 필수
    init(goalCount: Int) {
        self.goalCount = goalCount
    }

    // ViewModel의 Input을 받아 Output을 반환
    func transform(input: Input) -> Output {
        // 시작 트리거가 오면 CoreMotion 시작하고
        input.start
            .subscribe(onNext: { [weak self] in
                self?.startAccelerometer()
            })
            .disposed(by: disposeBag)

        // 메이트 점프 수가 들어오면 Relay에 바인딩
        input.mateCount
            .bind(to: mateCountRelay)
            .disposed(by: disposeBag)

        // 내 점프 수를 문자열로 변환(Driver로 변환)
        let myText = myCountRelay
            .map { "\($0)개" }
            .asDriver(onErrorJustReturn: "0")

        // 메이트 점프 수를 문자열로 변환(Driver로 변환)
        let mateText = mateCountRelay
            .map { "\($0)개" }
            .asDriver(onErrorJustReturn: "0")

        // 내 점프 수와 메이트 점프 수를 더해서, 목표 대비 진행률 계산
        let progress = Observable.combineLatest(myCountRelay, mateCountRelay) { [weak self] my, mate -> CGFloat in
            guard let self else { return 0 }
            return CGFloat(min(1, Float(my + mate) / Float(self.goalCount)))
        }
        .asDriver(onErrorJustReturn: 0)

        return Output(myCountText: myText, mateCountText: mateText, progress: progress)
    }

    // 점프 카운트 계산용 변수, 민감도랑 쿨다운 시간은 나중에 테스트하면서 수정할 예정.
    private var count = 0
    private var canCount = true
    private let accelerationLimit = 1.85   // 점프 감지 민감도
    private let cooldown = 0.45            // 연속 감지 방지(0.45초 쿨타임)

    // CoreMotion 시작(가속도 센서 활용)
    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data = data else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let speed = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) // 속도 계산 공식.

            // 점프 감지
            if speed > self.accelerationLimit && self.canCount {
                self.count += 1
                self.myCountRelay.accept(self.count)    // 내 점프 수 갱신
                self.canCount = false                  // 쿨타임 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + self.cooldown) { [weak self] in
                    self?.canCount = true              // 쿨타임 끝나면 다시 감지 가능
                }
            }
        }
    }

    // 뷰모델 소멸시 센서 종료
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
