//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation

struct AvatarModel {
    
    let type: AvatarType // 어떤 아바타인지
    let isUnlocked: Bool // 해금 여부
    let conCost: Int? // 해금 필요 코인 -> 해금 안되었을 때 중요
    let ratioOverride: CGFloat? // 서버에서 직접 비율 내려줄 수도
    let imageUrl: String
    
    var finalRatio: CGFloat {
        return ratioOverride ?? type.defaultRatio
    }
    
    var avatarName: String {
        return type.avatarName // ← enum AvatarType에 정의
    }
    
    // UI 랜더링을 위해 파베 이미지 접근용 네이밍
    var imageName: String {
        return type.imageName // ← rawValue (Storage 파일명)
    }
}
