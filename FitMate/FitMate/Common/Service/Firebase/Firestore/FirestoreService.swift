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
    
    func findMateUid(uid: String) -> Single<String> {
        return Single.create { single in
            let docRef = self.db.collection("users").document(uid)
            docRef.getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                } else if let data = document?.data(),
                          let mate = data["mate"] as? [String: Any],
                          let mateUid = mate["uid"] as? String {
                    print("Mate uid: \(mateUid)")
                    single(.success(mateUid))
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
    
    // 메이트 거리 실시간 리스닝 추가
    func observeMateProgress(matchCode: String, mateUid: String) -> Observable<Double> {
        return Observable.create { observer in
            let listener = Firestore.firestore()
                .collection("matches").document(matchCode)
                .addSnapshotListener { snapshot, error in
                    if let data = snapshot?.data(),
                       let players = data["players"] as? [String: Any],
                       let mate = players[mateUid] as? [String: Any],
                       let progress = mate["progress"] as? Double {
                        observer.onNext(progress)
                    }
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
