import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

final class RunningBattleViewModel: ViewModelType {
    
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
    let matchCode: String
    let myUid: String
    
    init(goalDistance: Int, myCharacter: String, mateCharacter: String, matchCode: String, myUid: String) {
        self.goalDistance = goalDistance
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.matchCode = matchCode
        self.myUid = myUid
    }
    
    struct Input {
        let startTracking: Observable<Void>     // 위치 추적 시작 트리거
        let mateDistance: Observable<Double>       // 메이트 거리 실시간
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let myProgress: Driver<CGFloat>
        let mateProgress: Driver<CGFloat>
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
        
        let mateDistanceText = mateDistanceRelay
            .map { "\($0) m" }
            .asDriver(onErrorJustReturn: "0.0 m")
        
        let myDistanceText = myDistanceRelay
            .map { "\($0) m" }
            .asDriver(onErrorJustReturn: "0.0 m")
        
        // Firestore에 값을 push
        myDistanceRelay
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { [weak self] distance -> Completable in
                guard let self = self else { return .empty() }
                return FirestoreService.shared.updateMyProgressToFirestore(
                    matchCode: self.matchCode,
                    uid: self.myUid,
                    progress: distance
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        // 내 점프 수와 메이트 점프 수를 더해서, 목표 대비 진행률 계산
        let myProgress = myDistanceTextRelay
            .map { [weak self] my -> CGFloat in
                guard let self else { return 0 }
                return CGFloat(min(1, (Float(my) ?? 0) / Float(self.goalDistance)))
            }
            .asDriver(onErrorJustReturn: 0)
        
        let mateProgress = mateDistanceTextRelay
            .map { [weak self] mate -> CGFloat in
                guard let self else { return 0 }
                return CGFloat(min(1, (Float(mate) ?? 0) / Float(self.goalDistance)))
            }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            myDistanceText: myDistanceText,
            mateDistanceText: mateDistanceText,
            myProgress: myProgress,
            mateProgress: mateProgress
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
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}

