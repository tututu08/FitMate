//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import RxSwift
import RxCocoa

class CarouselViewModel: ViewModelType {
    
    let disposeBag = DisposeBag()  // Rx 구독 해제를 위한 DisposeBag

    // Input & Output 정의

    // 외부에서 전달받을 Input (현재는 사용하지 않음)
    struct Input {}

    // View로 전달할 Output
    struct Output {
        let items: Driver<[ExerciseItem]>  // 컬렉션 뷰에 바인딩할 아이템 목록
        let originalCount: Int             // 가운데 위치로 초기 스크롤할 인덱스
    }

    // 운동 아이템의 데이터 모델
    struct ExerciseItem {
        let image: UIImage      // 운동 이미지
        let title: String       // 운동 이름
        let calorie: String     // 칼로리 정보
        let description: String // 운동 설명
        let effect: String      // 운동 효과
    }

    private let repeatCount = 100  // 무한 스크롤처럼 보이기 위한 반복 횟수

    // 실제 운동 아이템 원본 배열
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

    // 반복된 운동 데이터를 담는 Relay
    private let itemsRelay = BehaviorRelay<[ExerciseItem]>(value: [])

    // 컬렉션 뷰 초기 위치 설정용 (가운데 인덱스)
    var originalCount: Int {
        originalItemsSource.count * repeatCount / 2
    }

    // 초기화

    init() {
        // 원본 아이템을 repeatCount만큼 반복하여 무한 스크롤처럼 보이게 만듦
        let repeatedItems = Array(repeating: originalItemsSource, count: repeatCount).flatMap { $0 }
        itemsRelay.accept(repeatedItems)
    }

    // Transform
    func transform(input: Input) -> Output {
        // 반복된 데이터를 Driver로 변환하여 Output으로 내보냄
        return Output(
            items: itemsRelay.asDriver(),  // UI에서 안전하게 구독할 수 있도록 Driver로 전달
            originalCount: originalCount  // 시작 인덱스 전달
        )
    }
}
