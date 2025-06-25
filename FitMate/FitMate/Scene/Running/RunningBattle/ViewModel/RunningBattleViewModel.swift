import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

final class RunningBattleViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private var totalDistance: CLLocationDistance = 0
    private var previousLocation: CLLocation?
    private let didFinishRelay = PublishRelay<(Bool, Double)>()
    
    let myDistanceRelay = BehaviorRelay<Double>(value: 0)
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    
    let locationAuthDeniedRelay = PublishRelay<Void>()
    
    private let myDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    private let mateDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    
    var myDistance: Int { Int(myDistanceRelay.value) }
    var mateDistance: Int { Int(mateDistanceRelay.value) }
    let goalDistance: Int
    let myCharacter: String
    let mateCharacter: String
    let matchCode: String
    let myUid: String
    
    let mateQuitRelay = PublishRelay<Void>()
    
    init(goalDistance: Int, myCharacter: String, mateCharacter: String, matchCode: String, myUid: String) {
        self.goalDistance = goalDistance
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.matchCode = matchCode
        self.myUid = myUid
    }
    
    struct Input {
        let startTracking: Observable<Void>
        let mateDistance: Observable<Double>
        let quit: Observable<Void>
        let mateQuit: Observable<Void>
        let locationAuthStatus: Observable<CLAuthorizationStatus>
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let myProgress: Driver<CGFloat>
        let mateProgress: Driver<CGFloat>
        let didFinish: Signal<(Bool, Double)>
        let mateQuitEvent: Signal<Void>
        let locationAuthDenied: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        input.locationAuthStatus
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .denied, .restricted:
                    self.locationAuthDeniedRelay.accept(())
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.startTracking
            .subscribe(onNext: { [weak self] in
                self?.startLocationUpdates()
                self?.bindMateQuitListener()
            })
            .disposed(by: disposeBag)
        
        input.quit
            .subscribe(onNext: { [weak self] in
                self?.confirmQuit(isMine: true)
            })
            .disposed(by: disposeBag)
        
        input.mateQuit
            .subscribe(onNext: { [weak self] in
                self?.confirmQuit(isMine: false)
            })
            .disposed(by: disposeBag)
        
        input.mateDistance
            .subscribe(onNext: { [weak self] distance in
                guard let self else { return }
                self.mateDistanceRelay.accept(distance)
                if distance >= Double(self.goalDistance) {
                    self.finish(success: false)
                }
            })
            .disposed(by: disposeBag)
        
        let myDistanceText = myDistanceRelay
            .map { [weak self] meter -> String in
                let km = meter / 1000.0
                return self?.formatDistance(km) ?? "\(km) km"
            }
            .asDriver(onErrorJustReturn: "0.0 km")
        
        let mateDistanceText = mateDistanceRelay
            .map { "\($0) km" }
            .asDriver(onErrorJustReturn: "0.0 km")
        
        myDistanceRelay
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { [weak self] distance -> Completable in
                guard let self else { return .empty() }
                let kmDistance = (distance / 1000.0 * 100).rounded() / 100
                return FirestoreService.shared.updateMyProgressToFirestore(
                    matchCode: self.matchCode,
                    uid: self.myUid,
                    progress: kmDistance
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        let myProgress = myDistanceRelay
            .map { [weak self] my -> CGFloat in
                guard let self else { return 0 }
                let goalDistanceMeter = goalDistance * 1000
                let ratio = CGFloat(my / Double(goalDistanceMeter))
                return min(1, max(0, ratio))
            }
            .asDriver(onErrorJustReturn: 0)
        
        let mateProgress = mateDistanceRelay
            .map { [weak self] mate -> CGFloat in
                guard let self else { return 0 }
                let ratio = mate / Double(goalDistance)
                return CGFloat(min(1.0, max(0.0, ratio)))
            }
            .asDriver(onErrorJustReturn: 0)
        
        return Output(
            myDistanceText: myDistanceText,
            mateDistanceText: mateDistanceText,
            myProgress: myProgress,
            mateProgress: mateProgress,
            didFinish: didFinishRelay.asSignal(onErrorJustReturn: (false, 0.0)),
            mateQuitEvent: mateQuitRelay.asSignal(onErrorJustReturn: ()),
            locationAuthDenied: locationAuthDeniedRelay.asSignal(onErrorJustReturn: ())
        )
    }
    
    private func startLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
        
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loc in
                guard let self = self else { return }
                if let prev = self.previousLocation {
                    let delta = loc.distance(from: prev)
                    self.totalDistance += delta
                    let intMeter = Int(self.totalDistance.rounded())
                    self.myDistanceRelay.accept(Double(intMeter))
                    self.myDistanceTextRelay.accept("\(String(format: "%.1f", self.totalDistance)) m")
                    
                    if intMeter >= self.goalDistance * 1000 {
                        self.finish(success: true)
                    }
                }
                self.previousLocation = loc
            })
            .disposed(by: disposeBag)
    }
    
    private func confirmQuit(isMine: Bool) {
        locationManager.stopUpdatingLocation()
        
        if isMine {
            FirestoreService.shared.updateMyQuitStatus(matchCode: matchCode, uid: myUid)
                .subscribe(onCompleted: {
                    //print("✅ quitStatus 저장 성공")
                }, onError: { error in
                    //print("❌ quitStatus 저장 실패: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
        finish(success: false)
    }
    
    func finish(success: Bool) {
        locationManager.stopUpdatingLocation()
        didFinishRelay.accept((success, Double(myDistance)))
    }
    
    private func bindMateQuitListener() {
        FirestoreService.shared.listenMateQuitStatus(matchCode: matchCode, myUid: myUid)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] didQuit in
                guard didQuit else { return }
                self?.mateQuitRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    private func formatDistance(_ km: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return (formatter.string(from: NSNumber(value: km)) ?? "\(km)") + " km"
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
}
