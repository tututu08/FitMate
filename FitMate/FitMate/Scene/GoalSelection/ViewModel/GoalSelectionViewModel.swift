import RxCocoa
import RxSwift

class GoalSelectionViewModel: ViewModelType {
    struct Input {
        let selectedTitle: Observable<String>
    }

    struct Output {
        let pickerItems: Driver<[String]>
    }

    private let selectedGoalTitleRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        // input.selectedTitle 스트림을 selectedGoalTitleRelay로 바인딩
        input.selectedTitle
            .bind(to: selectedGoalTitleRelay)
            .disposed(by: disposeBag)

        return Output(
            pickerItems: pickerDataDriver
        )
    }

    private var pickerDataDriver: Driver<[String]> {
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
}
