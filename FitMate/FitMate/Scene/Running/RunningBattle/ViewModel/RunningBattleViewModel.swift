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
    // 내 누적 거리 (m)
    let myDistanceRelay = BehaviorRelay<Double>(value: 0)
    // 메이트 누적 거리 (m)
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    
    // UI 출력용 텍스트
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
        let startTracking: Observable<Void>     // 위치 추적 시작 트리거
        let mateDistance: Observable<Double>       // 메이트 거리 실시간
        let quit: Observable<Void>
        let mateQuit: Observable<Void>
    }
    
    struct Output {
        let myDistanceText: Driver<String>
        let mateDistanceText: Driver<String>
        let myProgress: Driver<CGFloat>
        let mateProgress: Driver<CGFloat>
        let didFinish: Signal<(Bool, Double)>        // 종료 알림(성공/실패)
        let mateQuitEvent: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        input.startTracking
            .subscribe(onNext: { [weak self] in
                self?.startLocationUpdates()
                
                // 메이트 종료 감지
                self?.bindMateQuitListener()
            })
            .disposed(by: disposeBag)
        
        input.quit
            .subscribe(onNext: { [weak self] in
                self?.confirmQuit(isMine: true)
            })
            .disposed(by: disposeBag)
        
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
            .disposed(by: disposeBag)
        
        
        input.mateDistance
            .subscribe(onNext: { [weak self] distance in
                guard let self else { return }
                self.mateDistanceRelay.accept(Double(distance))
//                let transKm = self.goalDistance * 1000
//                if Int(self.mateDistanceRelay.value) >= transKm {
//                    self.finish(success: false)
//                }
                if distance >= Double(self.goalDistance) {
                    self.finish(success: false) // ✅ 메이트가 목표 도달 시, 나는 패배 처리
                }
            })
            .disposed(by: disposeBag)
        
//        let mateDistanceText = mateDistanceRelay
//            .map { "\($0) m" }
//            .asDriver(onErrorJustReturn: "0.0 m")
//        
//        let myDistanceText = myDistanceRelay
//            .map { "\($0) m" }
//            .asDriver(onErrorJustReturn: "0.0 m")
        
        let myDistanceText = myDistanceRelay
            .map { [weak self] meter -> String in
                let km = meter / 1000.0
                return self?.formatDistance(km) ?? "\(km) km"
            }
            .asDriver(onErrorJustReturn: "0.0 km")

        let mateDistanceText = mateDistanceRelay
            .map { "\($0) km" } // ✅ 이미 km 단위니까 그대로 표시
            .asDriver(onErrorJustReturn: "0.0 km")
        
        // Firestore에 값을 push
        myDistanceRelay
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { [weak self] distance -> Completable in
                guard let self = self else { return .empty() }
                //let kmDistance = distance / 1000.0 // ✅ km 단위로 변환
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
        
        // 내 점프 수와 메이트 점프 수를 더해서, 목표 대비 진행률 계산
        let myProgress = myDistanceRelay
            .map { [weak self] my -> CGFloat in
                guard let self else { return 0 }
                //return CGFloat(min(1, (Float(my) ?? 0) / Float(self.goalDistance)))
                let goalDistanceMeter = goalDistance * 1000
                let ratio = CGFloat((my) / Double(goalDistanceMeter))
                return min(1, max(0, ratio))
            }
            .asDriver(onErrorJustReturn: 0)
        
        let mateProgress = mateDistanceRelay
            .map { [weak self] mate -> CGFloat in
                guard let self else { return 0 }
                //return CGFloat(min(1, (Float(mate) ?? 0) / Float(self.goalDistance)))
                //let goalDistanceMeter = goalDistance * 1000
                //let ratio = CGFloat((mate) / Double(goalDistanceMeter))
                let ratio = mate / Double(goalDistance) // 단위 통일
                //return min(1, max(0, ratio))
                return CGFloat(min(1.0, max(0.0, ratio)))
            }
            .asDriver(onErrorJustReturn: 0)
        
//        let didFinish = didFinishRelay
//            .asSignal(onErrorJustReturn: false)
        
        return Output(
            myDistanceText: myDistanceText,
            mateDistanceText: mateDistanceText,
            myProgress: myProgress,
            mateProgress: mateProgress,
            didFinish: didFinishRelay.asSignal(onErrorJustReturn: (false, 0.0)),
            mateQuitEvent: mateQuitRelay.asSignal(onErrorJustReturn: ())
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
                    let transKm = self.goalDistance * 1000
                    if Int(self.myDistanceRelay.value) >= transKm {
                        self.finish(success: true)
                    }
                }
                self.previousLocation = loc
            })
            .disposed(by: disposeBag)
    }
    
    private func confirmQuit(isMine: Bool) {
        locationManager.stopUpdatingLocation()
        //finish(success: false)
        // 실제로 완전히 끝내려면 finish(success: false) 호출 필요
        
        // 그만하기 버튼 탭 시, QuitStatus 업데이트
        if isMine {
            FirestoreService.shared.updateMyQuitStatus(matchCode: matchCode, uid: myUid)
                .subscribe(onCompleted: {
                    print("✅ quitStatus 저장 성공")
                }, onError: { error in
                    print("❌ quitStatus 저장 실패: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
        finish(success: false)
    }
    
    func finish(success: Bool) {
        locationManager.stopUpdatingLocation()
        didFinishRelay.accept((success, Double(myDistance)))
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

