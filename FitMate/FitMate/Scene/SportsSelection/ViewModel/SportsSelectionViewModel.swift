//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import RxSwift
import RxCocoa

class CarouselViewModel: ViewModelType {
    let disposeBag = DisposeBag()
    struct Input {
        // 현재 예제는 input이 따로 없으므로 빈 구조체
    }
    struct Output {
        let items: Driver<[ExerciseItem]>  // UI 바인딩은 Driver
        let originalCount: Int             // 중간 인덱스 위치 제공
    }
    struct ExerciseItem {
        let image: UIImage
        let title: String
        let calorie: String
        let description: String
        let effect: String
    }
    
    private let repeatCount = 100
    
    private let originalItemsSource: [ExerciseItem] = [
        ExerciseItem(
            image: UIImage(named: "plank") ?? UIImage(),
            title: "플랭크",
            calorie: "150kcal / 10분",
            description: "정적인 코어 운동",
            effect: "복부 근육 강화, 자세 안정"
        ),
        ExerciseItem(
            image: UIImage(named: "cycling") ?? UIImage(),
            title: "자전거",
            calorie: "250kcal / 30분",
            description: "하체 중심의 유산소 운동",
            effect: "하체 근력 향상, 체지방 감소"
        ),
        ExerciseItem(
            image: UIImage(named: "jumpRope") ?? UIImage(),
            title: "줄넘기",
            calorie: "350kcal / 30분",
            description: "전신을 사용하는 \n고강도 유산소 운동",
            effect: "체지방 감소, 순발력 향상"
        ),
        ExerciseItem(
            image: UIImage(named: "walking") ?? UIImage(),
            title: "걷기",
            calorie: "150kcal / 30분",
            description: "가장 기본적인 유산소 운동",
            effect: "심폐 기능 강화, 스트레스 해소"
        ),
        ExerciseItem(
            image: UIImage(named: "running") ?? UIImage(),
            title: "달리기",
            calorie: "300kcal / 30분",
            description: "강도 높은 유산소 운동",
            effect: "지구력 향상, 체지방 감소"
        )
    ]
    
    // BehaviorRelay로 관리하는 반복된 아이템 배열
    private let itemsRelay = BehaviorRelay<[ExerciseItem]>(value: [])
    
    
    // 중간 인덱스 (초기 스크롤 위치 계산용)
    var originalCount: Int {
        originalItemsSource.count * repeatCount / 2
    }
    
    init() {
        let repeatedItems = Array(repeating: originalItemsSource, count: repeatCount).flatMap { $0 }
        itemsRelay.accept(repeatedItems)
    }
    
    func transform(input: Input) -> Output {
        // input이 없으니 itemsRelay의 값을 Driver로 변환해서 내보내고
        // originalCount도 같이 전달
        return Output(
            items: itemsRelay.asDriver(),
            originalCount: originalCount
        )
    }
}

