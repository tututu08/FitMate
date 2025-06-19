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
        //let rewardText: Driver<String>   // Coin feature excluded in MVP
        //let hideCoin: Driver<Bool>
        let resultText: Driver<String>
        let resultImageName: Driver<String>
        let characterImageName: Driver<String>
    }
    
    private let mode: Mode
    private let sport: String
    private let goal: Int
    private let goalUnit: String
    private let character: String
    private let success: Bool

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
        //let reward = Observable.just("\(rewardCoin)")
        //let hideCoin = Observable.just(!success)
        let result = Observable.just(resultMessage)
        let resultImage = Observable.just(success ? "win" : "lose")
        let characterImage = Observable.just(success ? character : "\(character)Lose")

        return Output(
            modeText: modeText.asDriver(onErrorJustReturn: ""),
            goalText: goalText.asDriver(onErrorJustReturn: ""),
            //rewardText: reward.asDriver(onErrorJustReturn: ""),
            //hideCoin: hideCoin.asDriver(onErrorJustReturn: true),
            resultText: result.asDriver(onErrorJustReturn: ""),
            resultImageName: resultImage.asDriver(onErrorJustReturn: ""),
            characterImageName: characterImage.asDriver(onErrorJustReturn: "")
        )
    }

    // 간단한 보상 계산 로직
    //private var rewardCoin: Int {
    //    guard success else { return 0 }
    //    switch mode {
    //    case .battle: return goal * 2
    //    case .cooperation: return goal
    //    }
    //}

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
