//
//  FirestoreService.swift
//  FitMate
//
//  Created by NH on 6/12/25.
//

import Foundation
import FirebaseFirestore
import RxSwift

class FirestoreService {
    static let shared = FirestoreService() // 싱글턴 패턴 사용
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// 초대코드 생성 메서드
    func generateInviteCode(length: Int = 6) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// 코드 중복 검사
    /// 초대 코드 및 운동 코드로 사용 예정
    func checkInviteCodeDuplicate(code: String, completion: @escaping (Bool) -> Void) {
        db.collection("users")
            .whereField("inviteCode", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Firestore error: \(error)")
                    // 에러가 났을 때는 '중복 아님'으로 처리하는 게 안전하지 않으니 false로 처리
                    completion(false)
                    return
                }
                // 중복이 있다면 count > 0
                if let count = snapshot?.documents.count, count > 0 {
                    completion(true) // 이미 존재(중복)
                } else {
                    completion(false) // 중복 아님
                }
            }
    }
    
    // MARK: - Create
    
    /// user 생성 메소드
    /// 사용자의 정보를 저장하는 문서를 생성합니다.
    
    func createUserDocument(uid: String) -> Single<Void> {
        return Single.create { single in
            func tryGenerateAndSave() {
                let inviteCode = self.generateInviteCode()
                // inviteCode 중복 체크
                self.checkInviteCodeDuplicate(code: inviteCode) { isDuplicate in
                    if isDuplicate {
                        // 중복이면 다시 시도 (재귀)
                        tryGenerateAndSave()
                    } else {
                        let newRef = self.db.collection("users").document(uid)
                        let data: [String: Any] = [
                            "uid": uid,
                            "inviteCode": inviteCode,
                            "hasMate" : false, // 메이트 매칭 여부
                            "totalStats": [ // 총 기록
                                "walkingKm": 0, // 걷기
                                "runningKm": 0, // 달리기
                                "cyclingKm": 0, // 자전거
                                "plankRounds": 0, // 플랭크
                                "jumpRopeCount": 0 // 줄넘기
                                          ],
                            "winCount": 0,
                            "loseCount": 0,
                            "createAt": FieldValue.serverTimestamp(), // 만든 시간
                        ]
                        
                        // users 컬렉션의 uid 문서 생성
                        // 데이터 생성
                        newRef.setData(data) { error in
                            if let error = error {
                                single(.failure(error))
                                print("User 데이터 생성 실패: \(error.localizedDescription)")
                            } else {
                                single(.success(()))
                                print("User 데이터 생성 완료: \(uid), 초대코드: \(inviteCode)")
                            }
                        }
                    }
                }
            }
            tryGenerateAndSave()
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
    
    func createMatchDocument(inviterUid: String, inviteeUid: String, exerciseType: String, goalValue: Int, goalUnit: String, mode: String) -> Single<String> {
        return Single.create { single in
            func tryGenerateAndSave() {
                let matchCode = self.generateInviteCode()
                // inviteCode 중복 체크
                self.checkInviteCodeDuplicate(code: matchCode) { isDuplicate in
                    if isDuplicate {
                        // 중복이면 다시 시도 (재귀)
                        tryGenerateAndSave()
                    } else {
                        let newRef = self.db.collection("matches").document(matchCode)
                        let data: [String: Any] = [
                            "exerciseType": exerciseType, // 운동 종목
                            "goalValue": goalValue, // 목표 수치
                            "goalUnit": goalUnit,
                            "mode": mode, // 운동 모드
                            "matchStatus": "waiting", // waiting or started
                            "inviterUid": inviterUid, // 운동 생성자 uid
                            "inviteeUid": inviteeUid, // 운동 초대 받는 uid (mate)
                            "createAt": FieldValue.serverTimestamp(), // 만든 시간
                            // "startedAt": FieldValue.serverTimestamp(),     // 실제 시작 시각 넣을 땐 따로 업데이트
                            // "finishedAt": FieldValue.serverTimestamp(),    // 실제 종료 시각 넣을 땐 따로 업데이트
                            "players": [
                                inviterUid: [
                                    // "avatar": "끼리꼬", // 아바타 구현 되면 넣어야됨
                                    "isOnline": true,
                                    // "isWinner": true, // (대결모드에만 사용) 실제 게임 종료 후 따로 업데이트
                                    "progress": 0.0,
                                    "status": "waiting"
                                ],
                                inviteeUid: [
                                    // "avatar": "끼리꼬",
                                    "isOnline": true,
                                    // "isWinner": true,
                                    "progress": 0.0,
                                    "status": "waiting"
                                ]
                            ]
                        ]
                        
                        // Match 컬렉션의 MatchCode 문서 생성
                        // 데이터 생성
                        newRef.setData(data) { error in
                            if let error = error {
                                single(.failure(error))
                                print("Match 데이터 생성 실패: \(error.localizedDescription)")
                            } else {
                                // MatchCode 반환
                                single(.success(newRef.documentID))
                                print("Match 데이터 생성 완료: 매치코드: \(matchCode)")
                            }
                        }
                    }
                }
            }
            tryGenerateAndSave()
            return Disposables.create()
        }
    }
    
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
        .subscribe(onSuccess: { data in
                print(" 문서 데이터: \(data)")
            }, onFailure: { error in
                print(" 문서 가져오기 실패: \(error.localizedDescription)")
            })
     */
    
//    func findMateUid(uid: String) -> Single<String> {
//        return Single.create { single in
//            let docRef = self.db.collection("users").document(uid)
//            docRef.getDocument { document, error in
//                if let error = error {
//                    single(.failure(error))
//                } else if let data = document?.data(),
//                          let mate = data["mate"] as? [String: Any],
//                          let mateUid = mate["uid"] as? String {
//                    print("Mate uid: \(mateUid)")
//                    single(.success(mateUid))
//                } else {
//                    // NSError : 직접 에러를 만들때 사용
//                    // domain : 에러의 범주/이름, 모통 모듈 이름이나 기능을 넣음
//                    // code :  에러를 구분하기 위한 숫자 코드, 보통 -1 이 일반적인 실패 의미
//                    // userInfo : 에러에 대한 추가 정보 (딕셔너리), NSLocalizedDescriptionKey 가 중요
//                    // NSLocalizedDescriptionKey : .localizedDescription으로 출력될 때 사용되는 메시지를 담음.
//                    let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "문서가 존재하지 않거나 데이터가 없습니다."])
//                    single(.failure(noDataError))
//                }
//            }
//            return Disposables.create()
//        }
//    }
    /// - 사용자의 메이트 UID 찾는 메서드
    /// - mateUid 를 반환
    func findMateUid(uid: String) -> Single<String> {
        return fetchDocument(collectionName: "users", documentName: uid)
            .map { document in
                if let mate = document["mate"] as? [String: Any],
                   let mateUid = mate["uid"] as? String {
                    return mateUid
                } else {
                    return "" // 메이트 없음
                }
            }
            .catch { error in
                // 문서가 아예 없으면 → 메이트 없음으로 간주
                print("findMateUid: 문서 없음, UID=\(uid) → 빈 문자열 반환")
                return .just("")
            }
    }
    
    /// 닉네임 중복 여부 검사
    func nicknameCheck(nickname: String) -> Single<Bool> {
        return Single<Bool>.create { single in
            self.db.collection("users")
                .whereField("nickname", isEqualTo: nickname)
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        let isExist = (snapshot?.documents.count ?? 0) > 0
                        single(.success(isExist))
                    }
                }
            return Disposables.create()
        }
    }
    
    // 초대 코드 읽기
    func fetchUserByInviteCode(_ code: String) -> Single<[String: Any]> {
        return Single.create { single in
            self.db.collection("users")
                .whereField("inviteCode", isEqualTo: code)
                .getDocuments { snapshot, error in
                    if let error = error {
                        single(.failure(error))
                    } else if let document = snapshot?.documents.first {
                        single(.success(document.data()))
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "해당 초대 코드를 가진 사용자를 찾을 수 없습니다."
                        ])
                        single(.failure(error))
                    }
                }
            return Disposables.create()
        }
    }
    
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
    
    /// 프로그레스 업데이트 함수
    func updateMyProgressToFirestore(matchCode: String, uid: String, progress: Double) -> Completable {
        return Completable.create { completable in
            let db = Firestore.firestore()
            db.collection("matches").document(matchCode)
                .updateData([
                    "players.\(uid).progress": progress,
                    "players.\(uid).status": "playing"
                ]) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                }
            return Disposables.create()
        }
    }
    
    // 내 거리 실시간 리스너
       func observeMyProgress(matchCode: String, myUid: String) -> Observable<Double> {
           return Observable.create { observer in
               let listener = self.db.collection("matches")
                   .document(matchCode)
                   .addSnapshotListener { snapshot, error in
                       guard let data = snapshot?.data(),
                             let players = data["players"] as? [String: Any],
                             let me = players[myUid] as? [String: Any],
                             let progress = me["progress"] as? Double else {
                           observer.onNext(0.0) // ❗️문서가 없거나 초기값일 수 있음
                           return
                       }

                       observer.onNext(progress)
                   }

               return Disposables.create {
                   listener.remove()
               }
           }
       }

       // 메이트 거리 실시간 리스너
       func observeMateProgress(matchCode: String, mateUid: String) -> Observable<Double> {
           return Observable.create { observer in
               let listener = self.db.collection("matches")
                   .document(matchCode)
                   .addSnapshotListener { snapshot, error in
                       guard let data = snapshot?.data(),
                             let players = data["players"] as? [String: Any],
                             let mate = players[mateUid] as? [String: Any],
                             let progress = mate["progress"] as? Double else {
                           observer.onNext(0.0)
                           return
                       }

                       observer.onNext(progress)
                   }

               return Disposables.create {
                   listener.remove()
               }
           }
       }
    
    // MARK: - Delete
    func deleteDocument(collectionName: String, documentName: String) -> Single<Void> {
        return Single.create { single in
            let ref = self.db.collection(collectionName).document(documentName)
            ref.delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    /* deleteDocumentRx 사용 예시
     // 사용자 정보 삭제
     FirestoreService.shared
         .deleteDocumentRx(collectionName: "user", documentName: "abc123")
         .subscribe(
             onSuccess: { print("삭제 성공!") },
             onFailure: { error in print("삭제 실패: \(error.localizedDescription)") }
         )
         .disposed(by: disposeBag)
     */
}

extension FirestoreService {
    // MARK: - 플랭크
    func startPlankSession(matchCode: String, isMyTurn: Bool) -> Completable {
        let now = Timestamp(date: Date())
        let turn = isMyTurn ? "my" : "mate"
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).setData([
                "startedAt": now,
                "turn": turn,
                "timerStartAt": now,
                "paused": false,
                "quittingUid": NSNull(),
                "status": "inProgress"
            ], merge: true) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func listenToMatchStatus(matchCode: String) -> Observable<[String: Any]> {
        return Observable.create { observer in
            let ref = self.db.collection("matches").document(matchCode)
            let listener = ref.addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data() else { return }
                observer.onNext(data)
            }
            return Disposables.create { listener.remove() }
        }
    }
    
    func updatePlankTurn(matchCode: String, isMyTurn: Bool) -> Completable {
        let now = Timestamp(date: Date())
        let turn = isMyTurn ? "my" : "mate"
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).updateData([
                "turn": turn,
                "timerStartAt": now,
                "paused": false
            ]) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func pausePlank(matchCode: String) -> Completable {
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).updateData([
                "paused": true
            ]) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func resumePlank(matchCode: String) -> Completable {
        let now = Timestamp(date: Date())
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).updateData([
                "paused": false,
                "timerStartAt": now
            ]) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func quitPlank(matchCode: String, uid: String) -> Completable {
        let now = Timestamp(date: Date())
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).updateData([
                "quittingUid": uid,
                "status": "finished",
                "finishedAt": now
            ]) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func updatePlankProgress(matchCode: String, uid: String, progress: Int) -> Completable {
        return Completable.create { completable in
            self.db.collection("matches").document(matchCode).updateData([
                "players.\(uid).progress": progress
            ]) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
}

extension FirestoreService {
    // 게임 종료 결과 업데이트
    func updateMatchResult(
        matchCode: String,
        myUid: String,
        mateUid: String,
        mode: FinishViewModel.Mode,
        isWinner: Bool,
        goal: Int,
        myDistance: Double,
        exerciseType: String
    ) -> Completable {
        let batch = db.batch()
        
        // 1. matches/{matchCode} 문서 업데이트
        let matchRef = db.collection("matches").document(matchCode)
        var matchData: [String: Any] = [
            "matchStatus": "finished",
            "finishedAt": FieldValue.serverTimestamp(),
            "players.\(myUid).status": "finished",
            "players.\(mateUid).status": "finished"
        ]
        if mode == .battle {
            matchData["players.\(myUid).isWinner"] = isWinner
        }
        batch.updateData(matchData, forDocument: matchRef)
        
        // 2. users/{myUid} 문서 업데이트
        let userRef = db.collection("users").document(myUid)
        var userData: [String: Any] = [:]
        
        if mode == .battle {
            userData["winCount"] = FieldValue.increment(Int64(isWinner ? 1 : 0))
            userData["loseCount"] = FieldValue.increment(Int64(!isWinner ? 1 : 0))
        }
        
        userData.merge(makeExerciseStatField(exerciseType: exerciseType, myDistance: myDistance)) { _, new in new }
        
        batch.updateData(userData, forDocument: userRef)
        
        return Completable.create { completable in
            batch.commit { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    // 운동 타입별 누적 필드 반환
    private func makeExerciseStatField(exerciseType: String, myDistance: Double) -> [String: Any] {
        switch exerciseType {
        case "달리기": return ["totalStats.runningKm": FieldValue.increment(myDistance / 1000.0)]
        case "걷기": return ["totalStats.walkingKm": FieldValue.increment(myDistance / 1000.0)]
        case "자전거": return ["totalStats.cyclingKm": FieldValue.increment(myDistance / 1000.0)]
        case "줄넘기": return ["totalStats.jumpRopeCount": FieldValue.increment(Int64(myDistance))]
        case "플랭크": return ["totalStats.plankRounds": FieldValue.increment(Int64(myDistance))]
        default: return [:]
        }
    }
}

extension FirestoreService {
    func saveExerciseRecord(uid: String, record: ExerciseRecord) -> Completable {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid).collection("records").document() // autoId 생성
        
        let data: [String: Any] = [
            "type": record.type.rawValue,
            "date": record.date,
            "result": record.result.rawValue,
            "detail1": record.detail1,
            "detail2": record.detail2,
            "detail3": record.detail3
        ]
        
        return Completable.create { completable in
            ref.setData(data) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
}

// 기록 저장 관련 메서드
extension FirestoreService {
    func fetchExerciseRecords(uid: String) -> Single<[ExerciseRecord]> {
        let ref = db.collection("users").document(uid).collection("records")
        
        return Single.create { single in
            ref.getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    single(.success([]))
                    return
                }
                
                let records: [ExerciseRecord] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let typeString = data["type"] as? String,
                          let type = ExerciseType(rawValue: typeString),
                          let date = data["date"] as? String,
                          let resultString = data["result"] as? String,
                          let result = ExerciseResult(rawValue: resultString),
                          let detail1 = data["detail1"] as? String,
                          let detail2 = data["detail2"] as? String,
                          let detail3 = data["detail3"] as? String
                    else {
                        print("잘못된 type 값: \(data["type"] ?? "")")
                        return nil
                    }
                    
                    guard let resultString = data["result"] as? String,
                          let result = ExerciseResult(rawValue: resultString) else {
                        print("잘못된 result 값: \(data["result"] ?? "")")
                        return nil
                    }
                    
                    return ExerciseRecord(
                        type: type,
                        date: date,
                        result: result,
                        detail1: detail1,
                        detail2: detail2,
                        detail3: detail3
                    )
                }
                
                single(.success(records))
            }
            
            return Disposables.create()
        }
    }
}


extension FirestoreService {
    func fetchTotalStats(uid: String) -> Single<[WorkoutRecord]> {
        let ref = Firestore.firestore().collection("users").document(uid)
        
        return Single.create { single in
            ref.getDocument { snapshot, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = snapshot?.data(),
                      let stats = data["totalStats"] as? [String: Any] else {
                    single(.success([])) // 없으면 빈 배열 반환
                    return
                }
                //print("📦 totalStats 데이터: \(stats)")
                
//                let records: [WorkoutRecord] = [
//                    WorkoutRecord(type: "걷기", totalDistance: "\(stats["walkingKm"] as? Double ?? 0)", unit: "Km"),
//                    WorkoutRecord(type: "달리기", totalDistance: "\(stats["runningKm"] as? Double ?? 0)", unit: "Km"),
//                    WorkoutRecord(type: "자전거", totalDistance: "\(stats["cyclingKm"] as? Double ?? 0)", unit: "Km"),
//                    WorkoutRecord(type: "줄넘기", totalDistance: "\(stats["jumpRopeCount"] as? Int ?? 0)", unit: "회"),
//                    WorkoutRecord(type: "플랭크", totalDistance: "\(stats["plankRounds"] as? Int ?? 0)", unit: "회")
//                ]
                let records: [WorkoutRecord] = [
                    WorkoutRecord(type: "걷기", totalDistance: "\(stats["walkingKm"] as? Double ?? 0)", unit: "Km"),
                    WorkoutRecord(type: "달리기", totalDistance: "\(stats["runningKm"] as? Double ?? 0)", unit: "Km"),
                    WorkoutRecord(type: "자전거", totalDistance: "\(stats["cyclingKm"] as? Double ?? 0)", unit: "Km"),
                    
                    {
                        let raw = stats["jumpRopeCount"]
                        let count: Int
                        if let intValue = raw as? Int {
                            count = intValue
                        } else if let doubleValue = raw as? Double {
                            count = Int(doubleValue)
                        } else {
                            count = 0
                        }
                        return WorkoutRecord(type: "줄넘기", totalDistance: "\(count)", unit: "회")
                    }(),

                    {
                        let raw = stats["plankRounds"]
                        let count: Int
                        if let intValue = raw as? Int {
                            count = intValue
                        } else if let doubleValue = raw as? Double {
                            count = Int(doubleValue)
                        } else {
                            count = 0
                        }
                        return WorkoutRecord(type: "플랭크", totalDistance: "\(count)", unit: "회")
                    }()
                ]
                
                //print("✅ WorkoutRecord 생성 완료: \(records)")
                single(.success(records))
            }
            return Disposables.create()
        }
    }
}

/// 메이트 해지 사유 저장
enum DisconnectReason {
    case byMate // 메이트 끊기
    case byWithdrawal // 회원탈퇴
}

// 메이트 끊기
// 회원 탈퇴 관련 메서드
extension FirestoreService {
    /// 메이트를 끊을 때 호출
    func disconnectMate(forUid myUid: String, mateUid: String, reason: DisconnectReason = .byMate) -> Single<Void> {
        let myRef = db.collection("users").document(myUid)
        let mateRef = db.collection("users").document(mateUid)
        
//        return Single.create { single in
//            let batch = self.db.batch()
            
//            // A 문서 업데이트
//            batch.updateData([
//                "mate": FieldValue.delete(),
//                "hasMate": false,
//                "inviteStatus": "waiting",
//                "updatedAt": FieldValue.serverTimestamp()
//            ], forDocument: myRef)
            
//            // B 문서에 알림용 상태 전달
//            batch.updateData([
//                "inviteStatus": "disconnectedByMate",
//                "updatedAt": FieldValue.serverTimestamp()
//            ], forDocument: mateRef)
            
            
            
//            batch.commit { error in
//                if let error = error {
//                    single(.failure(error))
//                } else {
//                    single(.success(()))
//                }
//            }
//            
//            return Disposables.create()
//        }
        // 사용자 문서 업데이트
        let myUpdate: [String: Any] = [
            "mate": FieldValue.delete(),
            "hasMate": false,
            "inviteStatus": FieldValue.delete()
        ]
        
        // 메이트 문서 업데이트
        let mateUpdate: [String: Any] = [
            "mate": FieldValue.delete(),
            "hasMate": false,
            "inviteStatus": reason == .byMate ? "disconnectedByMate" : "disconnectedByWithdrawal"
        ]
        
        return Single.create { single in
            let batch = self.db.batch()
            batch.updateData(myUpdate, forDocument: myRef)
            batch.updateData(mateUpdate, forDocument: mateRef)
            batch.commit { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    /// 메이트가 끊겼다는 알림 확인 시 자신의 데이터 정리
    func deleteMate(myUid: String) -> Single<Void> {
        let ref = db.collection("users").document(myUid)
        return Single.create { single in
            ref.updateData([
                "mate": FieldValue.delete(),
                "hasMate": false,
                "inviteStatus": "waiting",
                "updatedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
}

// 메이트 게임 종료 감지
extension FirestoreService {
    // 메이트 종료 감지
    func listenMateQuitStatus(matchCode: String, myUid: String) -> Observable<Bool> {
        return Observable.create { observer in
            let ref = self.db.collection("matches").document(matchCode)

            let listener = ref.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ 리스너 에러 발생: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = snapshot else {
                    print("❌ 스냅샷이 nil입니다")
                    return
                }

                guard snapshot.exists else {
                    print("❌ 문서가 존재하지 않습니다: matches/\(matchCode)")
                    return
                }

                guard let data = snapshot.data() else {
                    print("❌ snapshot.data()가 nil입니다")
                    return
                }

                print("📄 문서 데이터: \(data)")

                if let quitStatus = data["quitStatus"] as? [String: Bool] {
                    print("📡 quitStatus 감지됨: \(quitStatus)")
                    for (uid, didQuit) in quitStatus {
                        if uid != myUid && didQuit == true {
                            print("⚠️ 상대방 종료 감지됨: \(uid)")
                            observer.onNext(true)
                            break
                        }
                    }
                } else {
                    print("❌ quitStatus 필드가 없거나 형식이 [String: Bool] 아님")
                }
            }

            return Disposables.create {
                listener.remove()
            }
        }
    }
    
    // 내 종료 업데이트
    func updateMyQuitStatus(matchCode: String, uid: String) -> Completable {
        let ref = db.collection("matches").document(matchCode)
        return Completable.create { completable in
            ref.setData([
                "quitStatus": [
                    uid: true
                ]
            ], merge: true) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    print("✅ quitStatus 저장 성공 [Map 구조]")
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
}
// 디데이 위한 데이트포매터
extension FirestoreService {
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국시간으로
        return df
    }()
}
