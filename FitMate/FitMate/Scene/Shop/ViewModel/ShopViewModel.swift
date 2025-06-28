//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import RxSwift
import RxCocoa
import Foundation

final class ShopViewModel {
    
    let selectedCategoryRelay = BehaviorRelay<RankCategory>(value: .all)
    private let allAvatarsRelay = BehaviorRelay<[AvatarModel]>(value: [])
    private let currentFilteredAvatarsRelay = BehaviorRelay<[AvatarModel]>(value: [])
    
    var disposeBag = DisposeBag()

    
    struct Input {
        let selectedCategory: Observable<RankCategory>
    }

    struct Output {
        let selectedAvatar: Driver<[AvatarModel]>
    }

    func transform(input: Input) -> Output {
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)

        let filtered = Observable
                .combineLatest(selectedCategoryRelay, allAvatarsRelay)
                .map { selected, avatars in
                    (selected == .all) ? avatars : avatars.filter { $0.type.category == selected }
                }
                .do(onNext: { [weak self] avatars in
                    self?.currentFilteredAvatarsRelay.accept(avatars)
                })
                .asDriver(onErrorJustReturn: [])

            return Output(selectedAvatar: filtered)
    }
}
