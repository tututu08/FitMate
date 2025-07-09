import Foundation
import CoreMotion
import RxSwift
import RxCocoa
import FirebaseFirestore

// 점프 줄넘기 협동 뷰모델(Rx, CoreMotion 활용)
final class JumpRopeCoopViewModel: ViewModelType {
    
    // Input: 외부에서 받아올 신호 정의
    struct Input {
        let start: Observable<Void>           // 측정 시작 트리거
        //let mateCount: Observable<Int>        // 메이트의 점프 수(네트워크 등에서 들어올 수 있음)
        let quit: Observable<Void>
        let mateQuit: Observable<Void>
    }
    
    // Output: View/VC에서 구독할 신호 정의
    struct Output {
        let myCountText: Driver<String>       // 내 점프 수(문자열)
        let mateCountText: Driver<String>     // 메이트 점프 수(문자열)
        let progress: Driver<CGFloat>         // 전체 진행률(비율)
        let didFinish: Signal<Bool>         // 종료 알림(성공/실패)
        let mateQuitEvent: Signal<Void>
        
    }
    
    private let disposeBag = DisposeBag()
    private let motionManager = CMMotionManager() // CoreMotion 관리
    private let db = Firestore.firestore()
    // 내/메이트 점프 수 Relay
    private let myCountRelay = BehaviorRelay<Int>(value: 0)
    private let mateCountRelay = BehaviorRelay<Int>(value: 0)
    private let didFinishRelay = PublishRelay<Bool>()
    private let mateQuitRelay = PublishRelay<Void>() // 그만하기 감지용
    
    // 목표 카운트(외부에서 입력, 예: 100)
    let goalCount: Int
    let myCharacter: String
    let mateCharacter: String
    var myCount: Int { myCountRelay.value }
    var mateCount: Int { mateCountRelay.value }
    // Firestore 동기화를 위한 변수 (유저 구분/방 구분 등)
    private let matchCode: String
    private let myUID: String
    private let mateUID: String
    
    // 점프 카운트 계산용 변수, 민감도랑 쿨다운 시간은 나중에 테스트하면서 수정할 예정.
    private var count = 0
    private var canCount = true
    private let accelerationLimit = 1.85   // 점프 감지 민감도
    private let cooldown = 0.45            // 연속 감지 방지(0.45초 쿨타임)
    
    // 생성자 목표 카운트 필수
    init(goalCount: Int, myCharacter: String, mateCharacter: String, matchCode: String, myUID: String, mateUID: String) {
        self.goalCount = goalCount
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.matchCode = matchCode
        self.myUID = myUID
        self.mateUID = mateUID
    }
    
    // ViewModel의 Input을 받아 Output을 반환
    func transform(input: Input) -> Output {
        // 시작 트리거가 오면 CoreMotion 시작하고
        input.start
            .subscribe(onNext: { [weak self] in
                self?.startAccelerometer()
                self?.bindMateQuitListener()
                self?.observeMateCount()
            })
            .disposed(by: disposeBag)

        input.quit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: true) })
            .disposed(by: disposeBag)
        
        input.mateQuit
            .subscribe(onNext: { [weak self] in self?.confirmQuit(isMine: false) })
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
        
        let didFinish = didFinishRelay
            .asSignal(onErrorJustReturn: false)
        
        return Output(
            myCountText: myText,
            mateCountText: mateText,
            progress: progress,
            didFinish: didFinish,
            mateQuitEvent: mateQuitRelay.asSignal(onErrorJustReturn: ())

        )
    }
    
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
                updateMyCountToFirestore(self.count) // firestore에 저장
                self.canCount = false                  // 쿨타임 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + self.cooldown) { [weak self] in
                    self?.canCount = true              // 쿨타임 끝나면 다시 감지 가능
                }
                if Double(self.myCountRelay.value) + Double(self.mateCountRelay.value) >= Double(self.goalCount) {
                    self.finish(success: true)
                }
            }
        }
    }
    private func confirmQuit(isMine: Bool) {
        motionManager.stopAccelerometerUpdates()
        // 그만하기 버튼 탭 시, QuitStatus 업데이트
        if isMine {
            FirestoreService.shared.updateMyQuitStatus(matchCode: matchCode, uid: myUID)
                .subscribe(onCompleted: {
                }, onError: { error in
                })
                .disposed(by: disposeBag)
        }
        finish(success: false)
    }
    
    func finish(success: Bool) {
        motionManager.stopAccelerometerUpdates()
        didFinishRelay.accept(success)
    }
    
    // 내 점프수 Firestore에 저장 (실시간)
    private func updateMyCountToFirestore(_ count: Int) {
        db.collection("matches")
            .document(matchCode)
            .updateData([
                "players.\(myUID).progress": count
            ]) { error in
                if let error = error {
                    print("점프 수 저장 실패: \(error.localizedDescription)")
                } else {
                    print("점프 수 저장 완료: \(count)")
                }
            }
    }
    
    // 메이트 점프 수를 Firestore에서 실시간 감지
    private func observeMateCount() {
        db.collection("matches")
            .document(matchCode)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let data = snapshot?.data(),
                      let players = data["players"] as? [String: Any],
                      let mate = players[self.mateUID] as? [String: Any],
                      let progress = mate["progress"] as? Int else {
                    return
                }
                
                print("메이트 점프 수 업데이트: \(progress)")
                self.mateCountRelay.accept(progress)
                
                if progress >= self.goalCount {
                    self.finish(success: true)
                }
            }
    }

    // 상대방 종료 감지
    private func bindMateQuitListener() {
        FirestoreService.shared.listenMateQuitStatus(matchCode: matchCode, myUid: myUID)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] didQuit in
                print("👀 상대방 종료 감지됨: \(didQuit)")
                guard didQuit else { return }
                self?.mateQuitRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    func stopLocationUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
