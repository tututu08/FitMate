//
//  FirestoreManager.swift
//  FitMate
//
//  Created by NH on 6/6/25.
//

import Foundation
import FirebaseFirestore
import RxSwift

class FirestoreManager {
    static let shared = FirestoreManager() // 싱글턴 패턴 사용
    
    let db = Firestore.firestore()
    
    /// 초대코드 생성 메서드
    func generateInviteCode(length: Int = 6) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // MARK: - Create
    
    /// user 생성 메소드
    /// 사용자의 정보를 저장하는 문서를 생성합니다.
    func createUserDocument(uid: String) -> Single<Void> {
        // rx로 래핑
        return Single.create { single in
            
            let inviteCode = self.generateInviteCode() // 랜덤 코드 생성
            let newRef = self.db.collection("users").document(uid)
            let data: [String: Any] = [
                "uid": uid,
                "inviteCode": inviteCode
            ]
            
            // users 컬렉션의 uid 문서 생성
            // 데이터 생성
            newRef.setData(data) { error in
                if let error = error {
                    single(.failure(error))
                    print("User 데이터 생성 실패: \(error.localizedDescription)") // 에러 처리
                } else {
                    single(.success(()))
                    print("User 데이터 생성 완료: \(uid)")
                }
            }
            return Disposables.create()
        }
    }
    
    /* createUserDocument 사용 예시
    FirestoreService.shared.createUserDocumentRx(uid: "abc123")
        .subscribe(
            onSuccess: { print("생성 성공") },
            onFailure: { error in print("실패: \(error)") }
        )
     */
}
