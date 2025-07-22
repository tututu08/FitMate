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
    let allAvatarsRelay = BehaviorRelay<[AvatarModel]>(value: [])
    let currentFilteredAvatarsRelay = BehaviorRelay<[AvatarModel]>(value: [])
    let selectedAvatarRelay = BehaviorRelay<AvatarModel?>(value: nil)
    let currentAvatarTypeRelay = BehaviorRelay<AvatarType?>(value: nil)
    let selectedPreviewAvatarRelay = BehaviorRelay<AvatarModel?>(value: nil)
    var disposeBag = DisposeBag()
    
    var currentFilteredAvatars: Observable<[AvatarModel]> {
            return currentFilteredAvatarsRelay.asObservable()
        }

    
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
        let sorted = avatars.sorted {
            // 캐피는 무조건 맨 앞 맨 첫번째
            if $0.type == .kaepy { return true }
            if $1.type == .kaepy { return false }
            
            if $0.isUnlocked != $1.isUnlocked {
                return $0.isUnlocked && !$1.isUnlocked
            }
            if $0.type.category != $1.type.category {
                return RankCategory.allCases.firstIndex(of: $0.type.category)! <
                    RankCategory.allCases.firstIndex(of: $1.type.category)!
            }
            return AvatarType.allCases.firstIndex(of: $0.type)! <
                AvatarType.allCases.firstIndex(of: $1.type)!
        }
        return sorted
    }

    func fetchAvatars(uid: String) {
        Single.zip(
            FirebaseStorage.shared.fetchAllAvatars(), // [AvatarModel]
            FirestoreService.shared.loadUnlockedAvatarTypes(uid: uid)
        )
        .map { avatars, unlockedTypes in
            avatars.map { avatar in
                var updated = avatar

                // 캐피는 항상 해금 상태로
                if avatar.type == .kaepy {
                    updated.isUnlocked = true
                } else {
                    updated.isUnlocked = unlockedTypes.contains(avatar.type)
                }
                return updated
            }
        }
        .map { [weak self] updatedAvatars -> [AvatarModel] in
            self?.sortAvatars(updatedAvatars) ?? []
        }
        .subscribe(onSuccess: { [weak self] sortedAvatars in
            self?.allAvatarsRelay.accept(sortedAvatars)
            
            // selectedAvatarRelay 캐피로 기본값 설정
            if let kaepyModel = sortedAvatars.first(where: { $0.type == .kaepy }) {
                if self?.selectedAvatarRelay.value == nil {
                    self?.selectedAvatarRelay.accept(kaepyModel)
                }
            }
        }, onFailure: { error in
            print("아바타 불러오기 실패: \(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }
    
    func fetchSelectedAvatarType(uid: String) {
        FirestoreService.shared.loadSelectedAvatar(uid: uid)
            .subscribe(onSuccess: { [weak self] type in
                self?.currentAvatarTypeRelay.accept(type)
            })
            .disposed(by: disposeBag)
    }

}
