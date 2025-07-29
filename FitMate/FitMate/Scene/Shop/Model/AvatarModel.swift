//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation
import FirebaseFirestore

struct AvatarModel: Codable, Hashable {
    
    @DocumentID var id: String? // ← Firestore 문서 ID 자동 매핑
    
    // Firestore에서 직접 내려주는 값들 -> 디코딩 대상
    let name: String
    let category: String
    let imageUrl: String
    let price: Int?
    var isLocked: Bool
    let ratio: Double?
    
    // AvatarType을 enum에 다시 매핑
    var type: AvatarType? {
        guard let id = id else { return nil }
        return AvatarType(rawValue: id)
    }
    
    // 기존 필드 대체 또는 계산용 -> Codable에 포함되지 x
    var isUnlocked: Bool {
        return !isLocked
    }
    
    var conCost: Int? {
        return isLocked ? price : nil
    }
    
    var finalRatio: CGFloat {
        return ratio ?? 1.0
    }
    
    // UI에서 에셋 접근용 -> imageName = 문서 ID
    var imageName: String? {
        return id
    }
    
    var avatarName: String {
        return name
    }
}
