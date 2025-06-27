import RxSwift
import RxCocoa
import CoreLocation
import RxCoreLocation

final class RunningCoopViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    
    private var totalDistance: CLLocationDistance = 0
    private var previousLocation: CLLocation?
    
//    private let didFinishRelay = PublishRelay<Bool>()
    private let didFinishRelay = PublishRelay<(Bool, Double)>()
    // 내 누적 거리 (m)
    private let myDistanceRelay = BehaviorRelay<Double>(value: 0)
    // 메이트 누적 거리 (m)
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    
    // UI 출력용 텍스트
    private let myDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    private let mateDistanceTextRelay = BehaviorRelay<String>(value: "0.0 m")
    
    let myDistanceDisplayRelay = BehaviorRelay<Double>(value: 0)   // Firestore에서 받은 km
    let mateDistanceDisplayRelay = BehaviorRelay<Double>(value: 0) // Firestore에서 받은 km
    let locationAuthDeniedRelay = PublishRelay<Void>()
    
    let goalDistance: Int
    let myCharacter: String
    let mateCharacter: String
    let matchCode: String
    let myUid: String
    let mateUid: String
    
    var myDistance: Int { Int(myDistanceRelay.value) }
    var mateDistance: Int { Int(mateDistanceRelay.value) }
    
    let mateQuitRelay = PublishRelay<Void>()
    
    init(goalDistance: Int, myCharacter: String, mateCharacter: String, matchCode: String, myUid: String, mateUid: String) {
        self.goalDistance = goalDistance
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.matchCode = matchCode
        self.myUid = myUid
        self.mateUid = mateUid
    }
    
    struct Input {
        let startTracking: Observable<Void>     // 위치 추적 시작 트리거
        let mateDistance: Observable<Double>       // 메이트 거리 실시간
        let quit: Observable<Void>
        let mateQuit: Observable<Void>
        let locationAuthStatus: Observable<CLAuthorizationStatus>
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let progress: Driver<CGFloat>
        //let didFinish: Signal<Bool>         // 종료 알림(성공/실패)
        let mateQuitEvent: Signal<Void>
        let didFinish: Signal<(Bool, Double)>
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
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: true) })
            .disposed(by: disposeBag)
        
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
            .disposed(by: disposeBag)
        
        input.mateDistance
            .subscribe(onNext: { [weak self] km in
                let meter = km * 1000.0                          // 🔸 내부 계산용 (progress 등)
                self?.mateDistanceRelay.accept(meter)
                
                // 🔹 텍스트 표시용: 그대로 km를 사용 (String만 포맷)
                let formatted = String(format: "%.2f km", km)
                self?.mateDistanceTextRelay.accept(formatted)
            })
            .disposed(by: disposeBag)
        
        // ✅ Firestore에서 받아온 거리로 표시 (KM 단위 그대로)
        let myText = myDistanceDisplayRelay
            .map { [weak self] km in self?.formatDistance(km) ?? "\(km) km" }
            .asDriver(onErrorJustReturn: "0.0 km")

        let mateText = mateDistanceDisplayRelay
            .map { [weak self] km in self?.formatDistance(km) ?? "\(km) km" }
            .asDriver(onErrorJustReturn: "0.0 km")
        
        let progress = Observable
            .combineLatest(myDistanceDisplayRelay, mateDistanceDisplayRelay)
            .map { [weak self] my, mate -> CGFloat in
                guard let self else { return 0 }
                let ratio = (my + mate) / Double(self.goalDistance)
                return CGFloat(min(1.0, ratio))
            }
            .asDriver(onErrorJustReturn: 0)
        
        // Firestore에 값을 push
        myDistanceRelay
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { [weak self] distance -> Completable in
                guard let self = self else { return .empty() }
                let kmDistance = (distance / 1000.0 * 100).rounded() / 100
                return FirestoreService.shared.updateMyProgressToFirestore(
                    matchCode: self.matchCode,
                    uid: self.myUid,
                    //progress: distance
                    progress: kmDistance
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        //let didFinish = didFinishRelay
            //.asSignal(onErrorJustReturn: false)
        
        return Output(
            myDistanceText: myText,
            mateDistanceText: mateText,
            progress: progress,
            //didFinish: didFinish
            mateQuitEvent: mateQuitRelay.asSignal(onErrorJustReturn: ()),
            didFinish: didFinishRelay.asSignal(onErrorJustReturn: (false, 0.0)),
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
            .filter { $0.horizontalAccuracy >= 0 && $0.horizontalAccuracy < 20 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loc in
                guard let self = self else { return }
                if let prev = self.previousLocation {
                    let delta = loc.distance(from: prev)
                    guard delta >= 5 else { return } 
                    self.totalDistance += delta
                    let intMeter = Int(self.totalDistance.rounded())
                    self.myDistanceRelay.accept(Double(intMeter))
                    self.myDistanceTextRelay.accept("\(String(format: "%.1f", self.totalDistance)) m")
                    let transKm = self.goalDistance * 1000
                    if Int(self.myDistanceRelay.value + self.mateDistanceRelay.value) >= transKm
                    {
                        self.finish(success: true)
                    }
                }
                self.previousLocation = loc
            })
            .disposed(by: disposeBag)
    }
    
    private func confirmQuit(isMine: Bool) {
        locationManager.stopUpdatingLocation()
        // finish(success: false)
        // 실제로 완전히 끝내려면 finish(success: false) 호출 필요
        
        // 그만하기 버튼 탭 시, QuitStatus 업데이트
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
        didFinishRelay.accept((success,  Double(myDistance)))
    }
    
    func updateMateDistance(_ meter: Int) {
        mateDistanceRelay.accept(Double(meter))
        
        let total = myDistanceRelay.value + mateDistanceRelay.value
        if Int(total) >= goalDistance * 1000 {
            finish(success: true)
        }
    }
    
    func bindDistanceFromFirestore() {
        Observable
            .combineLatest(
                FirestoreService.shared.observeMyProgress(matchCode: matchCode, myUid: myUid),
                FirestoreService.shared.observeMateProgress(matchCode: matchCode, mateUid: mateUid)
            )
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] myKm, mateKm in
                guard let self else { return }
                
                self.myDistanceDisplayRelay.accept(myKm)
                self.mateDistanceDisplayRelay.accept(mateKm)
                
                let total = myKm + mateKm
                if total >= Double(self.goalDistance) {
                    self.finish(success: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 상대방 종료 감지
    private func bindMateQuitListener() {
        FirestoreService.shared.listenMateQuitStatus(matchCode: matchCode, myUid: myUid)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] didQuit in
                print("👀 상대방 종료 감지됨: \(didQuit)")
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
