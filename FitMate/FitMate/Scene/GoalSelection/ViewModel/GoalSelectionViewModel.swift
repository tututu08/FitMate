import RxCocoa
import RxSwift

class GoalSelectionViewModel {
    // 내부 저장용 Relay
    private let selectedGoalTitleRelay = BehaviorRelay<String>(value: "")
    
    // Driver로 외부에 노출
    var pickerDataDriver: Driver<[String]> {
        selectedGoalTitleRelay
            .map { title in
                switch title {
                case "걷기", "달리기", "자전거":
                    return Array(1...20).map { "\($0) km" }
                case "플랭크":
                    return Array(1...20).map { "\($0) 라운드" }
                case "줄넘기":
                    return Array(stride(from: 50, through: 1000, by: 50)).map { "\($0)회" }
                default:
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    // 타이틀 업데이트용 함수
    func updateSelectedTitle(_ title: String) {
        selectedGoalTitleRelay.accept(title)
    }
}

