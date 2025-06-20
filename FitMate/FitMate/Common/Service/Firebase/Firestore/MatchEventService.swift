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
    let matchStatusRelay = BehaviorRelay<[String: String]>(value: [:])
    
    private var lastSentMatchCode: String?
    private var lastSentStatus: [String: String] = [:] // 상태 중복 방지용 캐시 추가
    
    private init() { }
    
    // MARK: - 운동 초대 감지
    func startListening(for uid: String) {
        stopMatchListening()
        
        let db = Firestore.firestore()
        
        matchListener = db.collection("matches")
            .whereField("inviteeUid", isEqualTo: uid) // 초대 받는 유저의 uid가 내 uid 일때
            .whereField("matchStatus", isEqualTo: "waiting") // 운동 경기 상태가 waiting 일때
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot, error == nil else { return }

                for change in snapshot.documentChanges where change.type == .added {
                    let matchCode = change.document.documentID
                    if self.lastSentMatchCode != matchCode {
                        self.lastSentMatchCode = matchCode
                        self.matchEventRelay.accept(matchCode)
                    }
                }
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
        
        listener = db.collection("matches").document(matchCode)
            .addSnapshotListener { [weak self] snapshot, error in
                print("addSnapshotListener 콜백 호출")
                
                guard let self = self,
                      let data = snapshot?.data() else {
                    print("콜백에서 데이터 없음, error: \(String(describing: error))")
                    return
                }
                
                // 1. matchStatus 받아서 matchStatusRelay 업데이트
                if let status = data["matchStatus"] as? String {
                    print("Firestore에서 matchStatus 변화 감지: \(status)")

                    if self.lastSentStatus[matchCode] != status {
                        self.lastSentStatus[matchCode] = status
                        var current = self.matchStatusRelay.value
                        current[matchCode] = status
                        self.matchStatusRelay.accept(current)

                        if status == "started" {
                            print("matchStatus == started → 리스너 제거 예약")
                            DispatchQueue.main.async {
                                self.stopListening()
                            }
                        }
                    } else {
                        print("중복 상태(\(status)) 무시")
                    }
                }
                
                // 2. players 안에 모두 isReady == true 인지 확인
                if let players = data["players"] as? [String: [String: Any]],
                   let status = data["matchStatus"] as? String,
                   ["waiting", "accepted"].contains(status)  // ✅ 수정
                {
                    let allReady = players.values.allSatisfy { $0["isReady"] as? Bool == true }

                    if allReady {
                        print("양쪽 모두 준비 완료! matchStatus → started 로 업데이트")
                        db.collection("matches").document(matchCode).updateData([
                            "matchStatus": "started",
                            "startTime": FieldValue.serverTimestamp()
                        ])
                    }
                }
                
            }
    }
    
    /// 전역 리스너 해제 메서드
    func stopListening() {
        listener?.remove()
        listener = nil
        
        if let code = lastSentMatchCode {
            lastSentStatus.removeValue(forKey: code)
        }
    }
    
    // 준비 상태 저장
    func markReady(matchCode: String, myUid: String) {
        let db = Firestore.firestore()
        print("markReady: \(myUid) → true")
        db.collection("matches").document(matchCode).updateData([
            "players.\(myUid).isReady": true
        ])
    }
    
    func updateMyStatus(matchCode: String, myUid: String, status: String) {
        let db = Firestore.firestore()
        db.collection("matches").document(matchCode).updateData([
            "players.\(myUid).status": status
        ]) { error in
            if let error = error {
                print("🔥 상태 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("✅ \(myUid)의 상태를 \(status)로 업데이트 완료")
            }
        }
    }
    
    func listenStartTime(matchCode: String) -> Observable<Date> {
        return Observable.create { observer in
            let listener = Firestore.firestore().collection("matches").document(matchCode)
                .addSnapshotListener { snapshot, error in
                    guard let data = snapshot?.data(),
                          let timestamp = data["startTime"] as? Timestamp else { return }

                    let startDate = timestamp.dateValue()
                    observer.onNext(startDate)
                }

            return Disposables.create {
                listener.remove()
            }
        }
    }
}
