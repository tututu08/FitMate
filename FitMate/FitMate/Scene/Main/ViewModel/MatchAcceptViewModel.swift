//
//  MatchAcceptViewModel.swift
//  FitMate
//
//  Created by NH on 6/17/25.
//

import Foundation
import FirebaseFirestore

class MatchAcceptViewModel {
    func respondToMatch(matchId: String, myUid: String, accept: Bool) {
        let db = Firestore.firestore()
        let newStatus = accept ? "accepted" : "rejected"
        db.collection("matches").document(matchId).updateData([
            "matchStatus": newStatus,
            "players.\(myUid).status": newStatus
        ])
    }
}
