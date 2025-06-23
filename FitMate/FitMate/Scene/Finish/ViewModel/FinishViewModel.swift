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
    private let character: String
    let success: Bool

    init(mode: Mode, sport: String, goal: Int, goalUnit: String, character: String, success: Bool) {
        self.mode = mode
        self.sport = sport
        self.goal = goal
        self.goalUnit = goalUnit
        self.character = character
        self.success = success
    }

    func transform(input: Input) -> Output {
        let modeText = Observable.just(mode == .battle ? "대결 모드" : "협력 모드")
        let goalText = Observable.just("\(sport) \(goal)\(goalUnit)")
//        let reward = Observable.just("\(rewardCoin)")
//        let hideCoin = Observable.just(!success)
        let result = Observable.just(resultMessage)
        let resultImage = Observable.just(success ? "win" : "lose")
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
            짝짝짝
            메이트보다 한발 앞섰어요!
            """
        case (.battle, false):
            return """
            승부는 졌지만
            당신의 노력은 최고였어요!
            """
        case (.cooperation, true):
            return """
            메이트와의 도전,
            완벽하게 성공!!
            """
        case (.cooperation, false):
            return """
            이번엔 실패...
            다음번엔 꼭 성공하자!
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
                  let myProgress = myData["progress"] as? Int,
                  let mateProgress = mateData["progress"] as? Int else {
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

            let record = ExerciseRecord(
                type: exerciseType,
                date: self.formatDate(timestamp.dateValue()),
                result: result,
                detail1: "\(goalValue)",
                detail2: "\(myProgress)",
                detail3: "\(mateProgress)"
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
