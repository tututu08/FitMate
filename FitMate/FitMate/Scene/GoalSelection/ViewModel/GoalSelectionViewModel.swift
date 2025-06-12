import RxCocoa
import RxSwift

// ViewModelType 프로토콜을 따르는 GoalSelectionViewModel 정의
class GoalSelectionViewModel: ViewModelType {
    
    // ViewModel의 Input 정의: 외부에서 주입되는 selectedTitle 스트림
    struct Input {
        let selectedTitle: Observable<String>
    }

    // ViewModel의 Output 정의: 피커에 표시할 항목 목록을 Driver로 제공
    struct Output {
        let pickerItems: Driver<[String]>
    }

    // 선택된 운동 제목을 저장하는 BehaviorRelay (초기값은 빈 문자열)
    private let selectedGoalTitleRelay = BehaviorRelay<String>(value: "")
    
    // 메모리 관리를 위한 DisposeBag
    private let disposeBag = DisposeBag()

    // transform 함수는 Input을 받아서 Output을 리턴 (ViewModelType 요구 사항)
    func transform(input: Input) -> Output {
        // input의 selectedTitle Observable을 selectedGoalTitleRelay에 바인딩
        input.selectedTitle
            .bind(to: selectedGoalTitleRelay)
            .disposed(by: disposeBag)

        // Output 구조체를 반환하며, pickerItems는 computed property로 처리
        return Output(
            pickerItems: pickerDataDriver
        )
    }

    // 선택된 운동 제목에 따라 피커에 표시할 데이터를 반환하는 Driver
    private var pickerDataDriver: Driver<[String]> {
        selectedGoalTitleRelay
            .map { title in
                // 운동 제목에 따라 피커 항목을 분기 처리
                switch title {
                case "걷기", "달리기", "자전거":
                    // 1km ~ 20km 표시
                    return Array(1...20).map { "\($0) km" }
                case "플랭크":
                    // 1~20 라운드 표시
                    return Array(1...20).map { "\($0) 라운드" }
                case "줄넘기":
                    // 50회부터 1000회까지 50단위로 표시
                    return Array(stride(from: 50, through: 1000, by: 50)).map { "\($0)회" }
                default:
                    // 그 외에는 빈 배열
                    return []
                }
            }
            // Error가 발생해도 빈 배열로 대체
            .asDriver(onErrorJustReturn: [])
    }
}
