//
//  UserDocument.swift
//  FitMate
//
//  Created by NH on 8/12/25.
//

import FirebaseFirestore
import FirebaseCore   // Timestamp

/// Firestore 사용자 문서 모델 정의
struct UserDocument: Codable {
    @DocumentID var id: String? // 자동으로 문서 번호 매칭
    let uid: String
    var coin: Int
    let inviteCode: String
    var hasMate: Bool
    var totalStats: TotalStats
    var winCount: Int
    var loseCount: Int
    @ServerTimestamp var createAt: Timestamp? // 서버 시간 자동으로 넣어줌
}

struct TotalStats: Codable {
    var walkingKm: Double
    var runningKm: Double
    var cyclingKm: Double
    var plankRounds: Int
    var jumpRopeCount: Int
}
