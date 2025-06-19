import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

final class RunningCoopViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private var totalDistance: CLLocationDistance = 0
    private var previousLocation: CLLocation?
    
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
    
    init(goalDistance: Int, myCharacter: String, mateCharacter: String) {
        self.goalDistance = goalDistance
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
    }
    
    struct Input {
        let startTracking: Observable<Void>     // 위치 추적 시작 트리거
        let mateDistance: Observable<Double>       // 메이트 거리 실시간
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let progress: Driver<CGFloat>
    }
    
    func transform(input: Input) -> Output {
        input.startTracking
            .subscribe(onNext: { [weak self] in
                self?.startLocationUpdates()
            })
            .disposed(by: disposeBag)
        
        input.mateDistance
            .subscribe(onNext: { [weak self] distance in
                self?.mateDistanceRelay.accept(Double(distance))
            })
            .disposed(by: disposeBag)
        
        mateDistanceRelay
            .map { "\($0) m" }
            .bind(to: mateDistanceTextRelay)
            .disposed(by: disposeBag)
        
        let progressDriver = Observable
            .combineLatest(myDistanceRelay, mateDistanceRelay)
            .map { [weak self] my, mate -> CGFloat in
                guard let self, self.goalDistance > 0 else { return 0 }
                return CGFloat(min(1, Float(my + mate) / Float(self.goalDistance)))
            }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            myDistanceText: myDistanceTextRelay.asDriver(),
            mateDistanceText: mateDistanceTextRelay.asDriver(),
            progress: progressDriver
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
                }
                self.previousLocation = loc
            })
            .disposed(by: disposeBag)
    }
    
    func updateMateDistance(_ meter: Int) {
        mateDistanceRelay.accept(Double(meter))
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}
