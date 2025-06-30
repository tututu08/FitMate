//
//  FirebaseStorage.swift
//  FitMate
//
//  Created by soophie on 6/30/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import RxSwift

class FirebaseStorage {
    
    static let shared = FirebaseStorage()
    private init() {}
    
    /// avatars  컬렉션의 모든 문서 가져오기
    func fetchAllAvatars() -> Single<[AvatarModel]> {
        return Single.create { single in
            // 파이어 스토어에서 avatars 컬렉션 참조
            let ref = Firestore.firestore().collection("avatars")
            // 컬렉션의 모든 문서 전체 가져오기
            ref.getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                } else if let documents = snapshot?.documents {
                    // 각 문서를 AvatarModel로 매핑
                    let avatars: [AvatarModel] = documents.compactMap { doc in
                        let data = doc.data()
                        // 필수 필드 가져오기
                        guard let name = data["name"] as? String,
                              let category = data["category"] as? String,
                              let imageUrl = data["imageUrl"] as? String,
                              let price = data["price"] as? Int,
                              let isLocked = data["isLocked"] as? Bool else { return nil }
                        
                        // optional ratio 필드 가져오기
                        let ratio = data["ratio"] as? Double
                        
                        // Firestore document ID가 AvatarType -> rawValue와 일치해야 함
                        guard let avatarType = AvatarType(rawValue: doc.documentID) else { return nil }
                        
                        // AvatarModel 인스턴스 생성
                        return AvatarModel(
                            type: avatarType,
                            isUnlocked: !isLocked, // 반대로 처리됨에 주의
                            conCost: isLocked ? price : nil,
                            ratioOverride: ratio.map { CGFloat($0) },
                            imageUrl: imageUrl
                        )
                    }
                    // 성공적으로 아바타 배열 반환
                    single(.success(avatars))
                } else {
                    // snapshot도 없고 에러도 없는 이상 상황 → 커스텀 에러 반환
                    let noDataError = NSError(domain: "", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "아바타 데이터를 불러오지 못했습니다."
                    ])
                    single(.failure(noDataError))
                }
            }
            
            return Disposables.create()
        }
    }
}
