//
//  MatchAcceptViewModel.swift
//  FitMate
//
//  Created by NH on 6/17/25.
//

import Foundation
import FirebaseFirestore

final class MatchAcceptViewModel {
    
    /// 초대 응답 결과에 따른 Firestore의 운동 경기 상태 값 업데이트
    func respondToMatch(matchCode: String, myUid: String, accept: Bool) {
        let db = Firestore.firestore()
        
        // 매개변수 accept 참, 거짓 여부에 따라 matchStatus 값 결정
        let newStatus = accept ? "accepted" : "rejected"
        db.collection("matches").document(matchCode).updateData([
            "matchStatus": newStatus,
            "players.\(myUid).status": newStatus
        ])
    }
}
