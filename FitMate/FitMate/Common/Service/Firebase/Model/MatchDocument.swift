//
//  MatchDocument.swift
//  FitMate
//
//  Created by NH on 8/12/25.
//

import FirebaseFirestore
import FirebaseCore   // Timestamp

struct PlayerState: Codable {
    var isOnline: Bool
    var isWinner: Bool? // 대결 종료 후에만 사용
    var progress: Double
    var status: String // "waiting", "ready", "playing"...
    var avatar: String?
}

struct MatchDocument: Codable {
    @DocumentID var id: String? // = matchCode
    let exerciseType: String
    let goalValue: Int
    let goalUnit: String
    let mode: String // 예: "battle", "coop"
    var matchStatus: String // "waiting", "started"
    let inviterUid: String
    let inviteeUid: String
    var players: [String: PlayerState] // key = uid

    @ServerTimestamp var createAt: Timestamp?
    @ServerTimestamp var startedAt: Timestamp?
    @ServerTimestamp var finishedAt: Timestamp?
}
