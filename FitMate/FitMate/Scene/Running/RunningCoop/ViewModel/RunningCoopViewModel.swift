import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

final class RunningCoopViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private var totalDistance: CLLocationDistance = 0
    private var previousLocation: CLLocation?
    
    private let didFinishRelay = PublishRelay<Bool>()
    // 내 누적 거리 (m)
    private let myDistanceRelay = BehaviorRelay<Double>(value: 0)
    // 메이트 누적 거리 (m)
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    
    // UI 출력용 텍스트
    private let myDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    private let mateDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    
    let goalDistance: Int
    let myCharacter: String
    let mateCharacter: String

    var myDistance: Int { Int(myDistanceRelay.value) }
    var mateDistance: Int { Int(mateDistanceRelay.value) }
    
    init(goalDistance: Int, myCharacter: String, mateCharacter: String) {
        self.goalDistance = goalDistance
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
    }
    
    struct Input {
        let startTracking: Observable<Void>     // 위치 추적 시작 트리거
        let mateDistance: Observable<Double>       // 메이트 거리 실시간
        let quit: Observable<Void>
        let mateQuit: Observable<Void>
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let progress: Driver<CGFloat>
        let didFinish: Signal<Bool>         // 종료 알림(성공/실패)
    }
    
    func transform(input: Input) -> Output {
        input.startTracking
            .subscribe(onNext: { [weak self] in
                self?.startLocationUpdates()
            })
            .disposed(by: disposeBag)
        
        input.quit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: true) })
            .disposed(by: disposeBag)
        
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
            .disposed(by: disposeBag)
        
        input.mateDistance
            .subscribe(onNext: { [weak self] distance in
                self?.mateDistanceRelay.accept(Double(distance))
            })
            .disposed(by: disposeBag)
        
        // 내 점프 수를 문자열로 변환(Driver로 변환)
        let myText = myDistanceRelay
            .map { "\($0)개" }
            .asDriver(onErrorJustReturn: "0")
        
        // 메이트 점프 수를 문자열로 변환(Driver로 변환)
        let mateText = mateDistanceRelay
            .map { "\($0)개" }
            .asDriver(onErrorJustReturn: "0")
        
        let progress = Observable
            .combineLatest(myDistanceRelay, mateDistanceRelay)
            .map { [weak self] my, mate -> CGFloat in
                guard let self, self.goalDistance > 0 else { return 0 }
                return CGFloat(min(1, Float(my + mate) / Float(self.goalDistance)))
            }
            .asDriver(onErrorJustReturn: 0)
        
        let didFinish = didFinishRelay
            .asSignal(onErrorJustReturn: false)
        
        return Output(
            myDistanceText: myText,
            mateDistanceText: mateText,
            progress: progress,
            didFinish: didFinish
        )
    }
    
    private func startLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
        
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last }
            .filter { $0.horizontalAccuracy < 20 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loc in
                guard let self = self else { return }
                if let prev = self.previousLocation {
                    let delta = loc.distance(from: prev)
                    self.totalDistance += delta
                    let intMeter = Int(self.totalDistance.rounded())
                    self.myDistanceRelay.accept(Double(intMeter))
                    self.myDistanceTextRelay.accept("\(String(format: "%.1f", self.totalDistance)) m")
                    if Int(self.myDistanceRelay.value + self.mateDistanceRelay.value) >= self.goalDistance {
                        self.finish(success: true)
                    }
                }
                self.previousLocation = loc
            })
            .disposed(by: disposeBag)
    }
    private func confirmQuit(isMine: Bool) {
        locationManager.stopUpdatingLocation()
        finish(success: false)
        // 실제로 완전히 끝내려면 finish(success: false) 호출 필요
    }
    func finish(success: Bool) {
        locationManager.stopUpdatingLocation()
        didFinishRelay.accept(success)
    }
    
    func updateMateDistance(_ meter: Int) {
        mateDistanceRelay.accept(Double(meter))
        if Int(myDistanceRelay.value + mateDistanceRelay.value) >= goalDistance {
            finish(success: true)
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}
