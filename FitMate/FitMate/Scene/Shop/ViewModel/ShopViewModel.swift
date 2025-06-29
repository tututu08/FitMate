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
    let selectedAvatarRelay = BehaviorRelay<AvatarModel?>(value: nil)
    var disposeBag = DisposeBag()

    
    struct Input {
        let selectedCategory: Observable<RankCategory>
        let selectedAvatar: Observable<AvatarModel>
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
    /// 등급 별 카테고리 대로 셀들 나열
    /// 위 조건을 기본으로 해금 여부를 우선사항으로 설정
    private func sortAvatars(_ avatars: [AvatarModel]) -> [AvatarModel] {
        avatars.sorted {
            // 해금 여부 우선
            if $0.isUnlocked != $1.isUnlocked {
                return $0.isUnlocked && !$1.isUnlocked
            }
            // 카테고리 우선
            if $0.type.category != $1.type.category {
                return RankCategory.allCases.firstIndex(of: $0.type.category)! <
                    RankCategory.allCases.firstIndex(of: $1.type.category)!
            }
            // vatarType 순서
            return AvatarType.allCases.firstIndex(of: $0.type)! <
                AvatarType.allCases.firstIndex(of: $1.type)!
        }
    }
    
    func fetchAvatars() {
        FirestoreService.shared.fetchAllAvatars()
            .subscribe(onSuccess: { [weak self] avatars in
                // 카테고리 순서대로 아바타 정렬하고 그 값을 allAvatarsRelay 담기
                let sorted = self?.sortAvatars(avatars) ?? []
                self?.allAvatarsRelay.accept(sorted)
            }, onFailure: { error in
                print("아바타 데이터 로드 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
