//
//  AvatarManager.swift
//  FitMate
//
//  Created by soophie on 7/2/25.
//

import Foundation
import RxSwift
import RxRelay

final class AvatarManager {
    /// AvatarManager 생성 이유
    /// 전역 상태 공유 (어디서든 바꾸면 모든 뷰컨에 반영됨)
    /// RxRelay 기반으로 UI 반영도 깔끔하게 가능
    /// 뷰모델끼리 서로 참조 안 해도 됨 → 의존성 낮추기
    static let shared = AvatarManager()

    /// 현재 선택된 아바타 (Firestore 저장 포함된 모델이면 AvatarModel도 가능)
    let selectedAvatarRelay = BehaviorRelay<AvatarType?>(value: nil)
    var mateAvatarRelay = BehaviorRelay<AvatarType?>(value: nil)
    private var previousMateAvatarType: AvatarType?

    
    private var disposeBag = DisposeBag()
    private init() { }

    /// Firestore에서 현재 유저의 아바타 불러오기
    func fetchInitialAvatar(uid: String) {
        FirestoreService.shared.loadSelectedAvatar(uid: uid)
            .subscribe(onSuccess: { [weak self] avatarType in
                self?.selectedAvatarRelay.accept(avatarType)
            })
            .disposed(by: disposeBag)
    }

    /// 새로 선택한 아바타 저장과 반영
    func updateAvatar(uid: String, avatarType: AvatarType) {
        FirestoreService.shared.saveSelectedAvatar(uid: uid, type: avatarType)
        selectedAvatarRelay.accept(avatarType)
    }
    
    /// 메이트 아바타 Firestore에서 fetch해서 반영
    func fetchMateAvatar(uid: String) {
        FirestoreService.shared.loadSelectedAvatar(uid: uid)
            .subscribe(onSuccess: { [weak self] avatarType in
                guard let self else { return }

                // 이전 값과 비교해서 다를 때만 relay 갱신
                if avatarType != self.previousMateAvatarType {
                    self.previousMateAvatarType = avatarType
                    self.mateAvatarRelay.accept(avatarType)
                }
            })
            .disposed(by: disposeBag)
    }
}
