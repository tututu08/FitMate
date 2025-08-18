import Foundation
import RxSwift
import RxCocoa

final class FinishViewModel: ViewModelType {
    // 운동 모드 구분
    enum Mode {
        case battle
        case cooperation
    }
    
    struct Input {
        let rewardTap: Signal<Void> // 보상 버튼 탭
    }
    
    struct Output {
        let modeText: Driver<String>
        let goalText: Driver<String>
        let rewardText: Driver<String>
        let hideCoin: Driver<Bool>
        let resultText: Driver<String>
        let resultImageName: Driver<String>
        let characterImageName: Driver<String>
        let saveCompleted: Signal<Void> // 저장 완료 트리거 (VC에서 화면전환)
        let saveFailed: Signal<String> // 저장 에러
    }
    
    // MARK: - Inputs (생성자 주입)
    let mode: Mode
    let sport: String
    let goal: Int
    private let goalUnit: String
    let myDistance: Double
    let success: Bool
    let avatarType: AvatarType
    
    // 외부 필요 파라미터 (보상/저장에 쓰이는 식별자)
    let uid: String
    let mateUid: String
    let matchCode: String
    
    private let disposeBag = DisposeBag()
    private let saveCompletedRelay = PublishRelay<Void>()
    private let saveFailedRelay = PublishRelay<String>()
    
    // 간단한 보상 계산 로직
    private var rewardCoin: Int {
        guard success else { return 0 }
        switch mode {
        case .battle: return goal * 2
        case .cooperation: return goal
        }
    }
    
    // 성공/실패에 따른 문구 반환
    private var resultMessage: String {
        switch (mode, success) {
        case (.battle, true):
            return """
            VICTORY~!
            너무 시시한걸요~??
            """
        case (.battle, false):
            return """
            LOSE...
            우씨 다음엔 안봐줄거야 !!
            """
        case (.cooperation, true):
            return """
            WoW~ 이걸 성공하다니..
            열쩡열쩡열쩡 ! 
            """
        case (.cooperation, false):
            return """
            아쉽지만 실패...
            다음번엔 꼭 성공하리...
            """
        }
    }
    
    init(uid: String,
         mateUid: String,
         matchCode: String,
         mode: Mode,
         sport: String,
         goal: Int,
         goalUnit: String,
         myDistance: Double = 0.0,
         avatarType: AvatarType,
         success: Bool) {
        self.uid = uid
        self.mateUid = mateUid
        self.matchCode = matchCode
        self.mode = mode
        self.sport = sport
        self.goal = goal
        self.goalUnit = goalUnit
        self.myDistance = myDistance      // 실제 달성 거리 (ex. 2.4)
        self.avatarType = avatarType
        self.success = success
    }
    
    func transform(input: Input) -> Output {
        let modeText = Observable.just(mode == .battle ? "대결 모드" : "협력 모드")
        let goalText = Observable.just("\(sport) \(goal)\(goalUnit)")
        // VC에 있던 상세 보상 계산을 그대로 ViewModel로 옮김
        let rewardValue = calculateReward(exerciseType: sport,
                                          goalValue: goal,
                                          mode: mode,
                                          isWin: success)
        let reward = Observable.just("\(rewardCoin)")
        let hideCoin = Observable.just(!success)
        let myDistance: Double // 실제 달성 거리 (ex. 2.4Km)
        let result = Observable.just(resultMessage)
        let resultImage = Observable.just(success ? "win" : "Lose")
        let characterImage = Observable.just(success ? avatarType.rawValue : "\(avatarType.rawValue)Lose")
        
        // 버튼 탭 → 코인 지급 + 경기 결과저장 + 기록 저장
        input.rewardTap.emit(onNext: { [weak self] in
            guard let self else { return }
            if self.success {
                SoundManage.shared.coinSound()
            }
            
            let reward = rewardValue
            
            // 1) 코인 가산
            self.rewardCoins(coinAmount: reward)
            // 2) 경기 결과 업데이트
                .andThen(
                    FirestoreService.shared.updateMatchResult(
                        matchCode: self.matchCode,
                        myUid: self.uid,
                        mateUid: self.mateUid,
                        mode: self.mode,
                        isWinner: self.success,
                        goal: self.goal,
                        myDistance: self.myDistance,
                        exerciseType: self.sport
                    )
                )
            // 3) 운동 기록 저장
                .andThen(self.saveRecord(uid: self.uid, mateUid: self.mateUid, matchCode: self.matchCode))
                .subscribe(
                    onCompleted: { [weak self] in
                        self?.saveCompletedRelay.accept(())
                    },
                    onError: { [weak self] error in
                        self?.saveFailedRelay.accept(error.localizedDescription)
                    }
                )
                .disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        
        return Output(
            modeText: modeText.asDriver(onErrorJustReturn: ""),
            goalText: goalText.asDriver(onErrorJustReturn: ""),
            rewardText: reward.asDriver(onErrorJustReturn: ""),
            hideCoin: hideCoin.asDriver(onErrorJustReturn: true),
            resultText: result.asDriver(onErrorJustReturn: ""),
            resultImageName: resultImage.asDriver(onErrorJustReturn: ""),
            characterImageName: characterImage.asDriver(onErrorJustReturn: ""),
            saveCompleted: saveCompletedRelay.asSignal(),
            saveFailed: saveFailedRelay.asSignal()
        )
    }
}

// MARK: - 코인 보상
extension FinishViewModel {
    /// 코인 보상 계산
    private func calculateReward(
        exerciseType: String,
        goalValue: Int,    // km, 분, 개수(줄넘기)
        mode: FinishViewModel.Mode,
        isWin: Bool = false
    ) -> Int {
        
        // 운동 계수
        let exerciseFactor: Double = {
            switch exerciseType {
            case "걷기", "달리기": return 1.5
            case "자전거": return 1.0
            case "플랭크": return 1.6
            case "줄넘기": return 1.4
            default: return 1.0
            }
        }()
        
        // 모드 계수
        let modeFactor: Double = {
            switch mode {
            case .cooperation: return isWin ? 0.5 : 0.0
            case .battle: return isWin ? 1.0 : 0.0
            }
        }()
        
        // 지속 보너스 계수
        let durationBonus: Double = {
            switch exerciseType {
            case "걷기":
                if goalValue < 5 { return 0.5 }
                else if goalValue < 11 { return 1.0 }
                else if goalValue < 16 { return 1.5 }
                else if goalValue < 20 { return 1.8 }
                else { return 2.0 }
            case "달리기":
                if goalValue < 5 { return 0.5 }
                else if goalValue < 11 { return 1.0 }
                else if goalValue < 16 { return 1.5 }
                else if goalValue < 20 { return 1.8 }
                else if goalValue < 26 { return 2.0 }
                else if goalValue < 30 { return 2.5 }
                else if goalValue < 36 { return 3.0 }
                else { return 4.0 }
            case "자전거":
                if goalValue < 11 { return 0.5 }
                else if goalValue < 15 { return 0.8 }
                else if goalValue < 30 { return 1.0 }
                else if goalValue < 36 { return 1.5 }
                else if goalValue < 40 { return 1.8 }
                else if goalValue < 46 { return 2.0 }
                else if goalValue < 50 { return 2.5 }
                else if goalValue < 56 { return 3.0 }
                else { return 4.0 }
            case "플랭크":
                if goalValue < 3 { return 0.5 }
                else if goalValue < 4 { return 0.7 }
                else if goalValue < 5 { return 0.9 }
                else if goalValue < 6 { return 1.2 }
                else if goalValue < 7 { return 1.5 }
                else if goalValue < 8 { return 1.8 }
                else if goalValue < 9 { return 2.0 }
                else if goalValue < 10 { return 2.3 }
                else { return 2.5 }
            case "줄넘기":
                if goalValue < 400 { return 0.5 }
                else if goalValue < 700 { return 0.8 }
                else if goalValue < 1000 { return 1.0 }
                else if goalValue < 1300 { return 1.3 }
                else if goalValue < 1600 { return 1.6 }
                else if goalValue < 1900 { return 2.0 }
                else { return 2.5 }
            default:
                return 1.0
            }
        }()
        
        let reward = (exerciseFactor * 100 * modeFactor * durationBonus).rounded(.toNearestOrEven)
        return Int((reward / 10.0).rounded() * 10)
    }
    
    func rewardCoins(coinAmount: Int) -> Completable {
        guard coinAmount > 0 else { return .empty() }
        return FirestoreService.shared.fetchDocument(collectionName: "users", documentName: self.uid)
            .flatMapCompletable { data in
                let current = data["coin"] as? Int ?? 0
                return FirestoreService.shared.updateDocument(
                    collectionName: "users",
                    documentName: self.uid,
                    fields: ["coin": current + coinAmount]
                )
                .asCompletable() // updateDocument 가 Single<Void>을 반환하여 Single<Void> → Completable 로 변환
            }
    }
}

import FirebaseFirestore

extension FinishViewModel {
    func saveRecord(uid: String, mateUid: String, matchCode: String) -> Completable {
        let db = Firestore.firestore()
        let matchRef = db.collection("matches").document(matchCode)
        
        return Single<[String: Any]>.create { single in
            matchRef.getDocument { snapshot, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = snapshot?.data() else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "경기 데이터를 찾을 수 없습니다."])
                    single(.failure(error))
                    return
                }
                
                single(.success(data))
            }
            return Disposables.create()
        }
        .flatMapCompletable { data in
            guard let exerciseTypeStr = data["exerciseType"] as? String,
                  let exerciseType = ExerciseType(rawValue: exerciseTypeStr),
                  let goalValue = data["goalValue"] as? Int,
                  let timestamp = data["createAt"] as? Timestamp,
                  let players = data["players"] as? [String: Any],
                  let myData = players[uid] as? [String: Any],
                  let mateData = players[mateUid] as? [String: Any],
                  let myProgress = myData["progress"] as? Double,
                  let mateProgress = mateData["progress"] as? Double else {
                return .error(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "필드 누락 또는 변환 실패"]))
            }
            
            let myIsWinner = myData["isWinner"] as? Bool ?? false
            
            let result: ExerciseResult = {
                switch self.mode {
                case .battle:
                    return myIsWinner ? .versusWin : .versusLose
                case .cooperation:
                    return self.success ? .teamSuccess : .teamFail
                }
            }()
            
            let detail2: String
            let detail3: String
            
            switch exerciseType {
            case .jumpRope, .plank:
                detail2 = "\(Int(myProgress))"
                detail3 = "\(Int(mateProgress))"
            default:
                detail2 = String(format: "%.2f", myProgress)
                detail3 = String(format: "%.2f", mateProgress)
            }
            
            let record = ExerciseRecord(
                type: exerciseType,
                date: self.formatDate(timestamp.dateValue()),
                result: result,
                detail1: "\(goalValue)",
                detail2: detail2,
                detail3: detail3
            )
            
            return FirestoreService.shared.saveExerciseRecord(uid: uid, record: record)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: date)
    }
}
