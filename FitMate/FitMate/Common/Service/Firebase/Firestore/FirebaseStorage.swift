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
                        try? doc.data(as: AvatarModel.self)
                    }
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
