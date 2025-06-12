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
     // 사용자 정보 저장
     FirestoreService.shared.createUserDocumentRx(uid: "abc123")
        .subscribe(
            onSuccess: { print("생성 성공") },
            onFailure: { error in print("실패: \(error)") }
        )
     */
    
    // MARK: - Read
    
    /// 도큐멘트 데이터 가져오기
    func fetchDocument(collectionName: String, documentName: String) -> Single<[String: Any]> {
            return Single.create { single in
                let ref = self.db.collection(collectionName).document(documentName)
                ref.getDocument { document, error in
                    if let error = error {
                        single(.failure(error))
                    } else if let data = document?.data() {
                        single(.success(data))
                    } else {
                        // NSError : 직접 에러를 만들때 사용
                        // domain : 에러의 범주/이름, 모통 모듈 이름이나 기능을 넣음
                        // code :  에러를 구분하기 위한 숫자 코드, 보통 -1 이 일반적인 실패 의미
                        // userInfo : 에러에 대한 추가 정보 (딕셔너리), NSLocalizedDescriptionKey 가 중요
                        // NSLocalizedDescriptionKey : .localizedDescription으로 출력될 때 사용되는 메시지를 담음.
                        let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "문서가 존재하지 않거나 데이터가 없습니다."])
                        single(.failure(noDataError))
                    }
                }
                return Disposables.create()
            }
        }
    
    /* fetchDocument 사용 예시
     // 사용자 정보 가져오기
     FirestoreService.shared.fetchDocument(collectionName: "users", documentName: "abc123")
        .subscribe(
            onSuccess: { print("User 데이터 : \(data)") },
            onFailure: { print("User 데이터 읽기 실패 : \(error.localizedDescription)") }
        )
     */
    
    // MARK: - Update
    
    func updateDocument(collectionName: String, documentName: String, fields: [String: Any]) -> Single<Void> {
        return Single.create { single in
            let ref = self.db.collection(collectionName).document(documentName)
            ref.updateData(fields) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    /* updateDocument 사용 예시
     // 사용자 닉네임 업데이트
     FirestoreService.shared
         .updateDocumentRx(collectionName: "user", documentName: "abc123", fields: ["nickname": "노훈"])
         .subscribe(
             onSuccess: {
                 print("업데이트 성공!")
             },
             onFailure: { error in
                 print("실패: \(error.localizedDescription)")
             }
         )
         .disposed(by: disposeBag)
     */
}
