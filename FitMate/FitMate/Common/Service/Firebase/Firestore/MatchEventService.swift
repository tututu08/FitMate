//
//  MatchEventService.swift
//  FitMate
//
//  Created by NH on 6/16/25.
//

import FirebaseFirestore
import RxSwift
import RxRelay

/// Firestore 글로벌 실시간 감지 리스너
final class MatchEventService {
    static let shared = MatchEventService()
    
    // 글로벌 실시간 감지 리스너 생성
    private var matchListener: ListenerRegistration? // 운동 초대 감지 리스너
    private var listener: ListenerRegistration? // 운동 초대 응답 감지 리스너
    
    // 매칭 이벤트 Relay
    let matchEventRelay = PublishRelay<String>() // matchCode 데이터
    
    // matchCode 별 status 이벤트 스트림
    let matchStatusRelay = PublishRelay<(matchCode: String, status: String)>()
    
    private init() { }
    
    // MARK: - 운동 초대 감지
    func startListening(for uid: String) {
        stopMatchListening()
        
        let db = Firestore.firestore()
        
        matchListener = db.collection("matches")
            .whereField("inviteeUid", isEqualTo: uid) // 초대 받는 유저의 uid가 내 uid 일때
            .whereField("matchStatus", isEqualTo: "waiting") // 운동 경기 상태가 waiting 일때
            .addSnapshotListener { [weak self] snapshot, error in // 실시간으로 감지해서 쿼리 결과 혹은 에러를 방출
                guard let self = self,
                      // 쿼리 결과를 배열로 받아오지만, 쿼리 결과는 유일하므로 첫번째 값을 꺼냄
                      let doc = snapshot?.documents.first,
                      error == nil else { return }
                
                // 쿼리 결과의 matchCode를 방출
                let matchCode = doc.documentID
                self.matchEventRelay.accept(matchCode)
            }
    }
    
    /// 전역 리스너 해제 메서드
    func stopMatchListening() {
        matchListener?.remove()
        matchListener = nil
    }
    
    // 특정 matchCode 의 상태 변화를 구독
    // MARK: - 운동 초대 수락 감지
    func listenMatchStatus(matchCode: String) {
        stopListening()
        let db = Firestore.firestore()
        
        print("listenMatchStatus 등록, matchId: \(matchCode)")
        
        listener = db.collection("matches").document(matchCode) // 특정 운동 경기 실시간 감지
            .addSnapshotListener { [weak self] snapshot, error in
                print("addSnapshotListener 콜백 호출")
                
                guard let self = self,
                      // 결과를 딕셔너리 형태로 변형
                      let data = snapshot?.data(),
                      // matchStatus 의 값을 추출
                      let status = data["matchStatus"] as? String else {
                    print("콜백에서 데이터 없음, error: \(String(describing: error))")
                    return
                }
                print("Firestore에서 matchStatus 변화 감지: \(status)")
                
                // 운동 경기 코드와, 해당 운동 경기의 상태를 방출!
                self.matchStatusRelay.accept((matchCode, status))
            }
    }
    
    /// 전역 리스너 해제 메서드
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
