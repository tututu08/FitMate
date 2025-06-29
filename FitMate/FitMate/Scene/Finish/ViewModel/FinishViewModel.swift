import Foundation
import RxSwift
import RxCocoa

final class FinishViewModel: ViewModelType {
    // 운동 모드 구분
    enum Mode {
        case battle
        case cooperation
    }

    struct Input { }

    struct Output {
        let modeText: Driver<String>
        let goalText: Driver<String>
//        let rewardText: Driver<String>
//        let hideCoin: Driver<Bool>
        let resultText: Driver<String>
        let resultImageName: Driver<String>
        let characterImageName: Driver<String>
    }
    
    let mode: Mode
    let sport: String
    let goal: Int
    private let goalUnit: String
    let myDistance: Double
    private let character: String
    let success: Bool

    init(mode: Mode, sport: String, goal: Int, goalUnit: String, myDistance: Double = 0.0, character: String, success: Bool) {
        self.mode = mode
        self.sport = sport
        self.goal = goal
        self.goalUnit = goalUnit
        self.myDistance = myDistance      // 실제 달성 거리 (ex. 2.4)
        self.character = character
        self.success = success
    }

    func transform(input: Input) -> Output {
        let modeText = Observable.just(mode == .battle ? "대결 모드" : "협력 모드")
        let goalText = Observable.just("\(sport) \(goal)\(goalUnit)")
//        let reward = Observable.just("\(rewardCoin)")
//        let hideCoin = Observable.just(!success)
        let myDistance: Double // 실제 달성 거리 (ex. 2.4Km)
        let result = Observable.just(resultMessage)
        let resultImage = Observable.just(success ? "win" : "Lose")
        let characterImage = Observable.just(success ? character : "\(character)Lose")

        return Output(
            modeText: modeText.asDriver(onErrorJustReturn: ""),
            goalText: goalText.asDriver(onErrorJustReturn: ""),
//            rewardText: reward.asDriver(onErrorJustReturn: ""),
//            hideCoin: hideCoin.asDriver(onErrorJustReturn: true),
            resultText: result.asDriver(onErrorJustReturn: ""),
            resultImageName: resultImage.asDriver(onErrorJustReturn: ""),
            characterImageName: characterImage.asDriver(onErrorJustReturn: "")
        )
    }

    // 간단한 보상 계산 로직
//    private var rewardCoin: Int {
//        guard success else { return 0 }
//        switch mode {
//        case .battle: return goal * 2
//        case .cooperation: return goal
//        }
//    }

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
//                  let myProgress = myData["progress"] as? Int,
//                  let mateProgress = mateData["progress"] as? Int else {
                    let myProgress = myData["progress"] as? Double,
                    let mateProgress = mateData["progress"] as? Double else {
                return .error(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "필드 누락 또는 변환 실패"]))
            }

            let isWinner = data["isWinner"] as? Bool ?? false
            let result: ExerciseResult = {
                switch self.mode {
                case .battle:
                    return (isWinner && uid == data["inviterUid"] as? String) ||
                           (!isWinner && uid == data["inviteeUid"] as? String)
                        ? .versusWin : .versusLose
                case .cooperation:
                    return self.success ? .teamSuccess : .teamFail
                }
            }()

//            let record = ExerciseRecord(
//                type: exerciseType,
//                date: self.formatDate(timestamp.dateValue()),
//                result: result,
//                detail1: "\(goalValue)",
//                detail2: "\(myProgress)",
//                detail3: "\(mateProgress)"
//            )
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
