import RxCocoa
import RxSwift

// ViewModelType 프로토콜을 따르는 GoalSelectionViewModel 정의
class GoalSelectionViewModel: ViewModelType {
    
    // ViewModel의 Input 정의: 외부에서 주입되는 selectedTitle 스트림
    struct Input {
        let selectedTitle: Observable<String>
        let selectedMode: Observable<SportsModeViewController.ExerciseMode>
    }
    
    // ViewModel의 Output 정의: 피커에 표시할 항목 목록을 Driver로 제공
    struct Output {
        let pickerItems: Driver<[String]>
    }
    
    // 선택된 운동 제목을 저장하는 BehaviorRelay (초기값은 빈 문자열)
    private let selectedGoalTitleRelay = BehaviorRelay<String>(value: "")
    // 선택된 운동 모드를 저장
    private let selectedModeRelay = BehaviorRelay<SportsModeViewController.ExerciseMode>(value: .cooperation)
    
    // 메모리 관리를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    // transform 함수는 Input을 받아서 Output을 리턴 (ViewModelType 요구 사항)
    func transform(input: Input) -> Output {
        input.selectedTitle
            .bind(to: selectedGoalTitleRelay)
            .disposed(by: disposeBag)
        
        input.selectedMode
            .bind(to: selectedModeRelay)
            .disposed(by: disposeBag)
        
        return Output(pickerItems: pickerDataDriver)
    }
    
    
    // 선택된 운동 제목에 따라 피커에 표시할 데이터를 반환하는 Driver
    private var pickerDataDriver: Driver<[String]> {
        Observable
            .combineLatest(selectedGoalTitleRelay, selectedModeRelay)
            .map { title, mode in
                switch (title, mode) {
                case ("걷기", .cooperation):
                    return Array(2...20).map { "\($0) km" }
                case ("걷기", .battle):
                    return Array(1...10).map { "\($0) km" }
                case ("달리기", .cooperation):
                    return Array(2...40).map { "\($0) km" }
                case ("달리기", .battle):
                    return Array(1...20).map { "\($0) km" }
                case ("자전거", .cooperation):
                    return Array(4...60).map { "\($0) km" }
                case ("자전거", .battle):
                    return Array(2...30).map { "\($0) km" }
                case ("플랭크", _):
                    return Array(2...10).map { "\($0) 분" }
                case ("줄넘기", .cooperation):
                    return Array(stride(from: 200, through: 2000, by: 100)).map { "\($0)회" }
                case ("줄넘기", .battle):
                    return Array(stride(from: 100, through: 1500, by: 100)).map { "\($0)회" }
                    
                default:
                    return []
                }
            }
            .asDriver(onErrorJustReturn: [])
    }
    func saveTitle(_ title: String) {
        
    }
    func saveGoal() {
        
    }
}
