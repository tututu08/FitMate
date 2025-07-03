import Foundation
import RxSwift
import RxCocoa

final class MypageViewModel {
    private let uid: String

    init(uid: String) {
        self.uid = uid
    }

    struct Output {
        let nickname: Driver<String>
        let records: Driver<[WorkoutRecord]>
    }

    func transform() -> Output {
        let nickname = FirestoreService.shared
            .fetchDocument(collectionName: "users", documentName: uid)
            .map { $0["nickname"] as? String ?? "닉네임" }
            .asDriver(onErrorJustReturn: "닉네임")

        let records = FirestoreService.shared
            .fetchTotalStats(uid: uid)
            .map { records in
                var mutableRecords = records
                if let plankIndex = mutableRecords.firstIndex(where: { $0.type == "플랭크" }) {
                    let plank = mutableRecords.remove(at: plankIndex)
                    let insertIndex = min(2, mutableRecords.count)
                    mutableRecords.insert(plank, at: insertIndex)
                }
                return mutableRecords
            }
            .do(onSuccess: { (records: [WorkoutRecord]) in
                print("ViewModel에서 받은 기록: \(records.map { $0.type })")
            })
            .asDriver(onErrorJustReturn: [])

        return Output(nickname: nickname, records: records)
    }
}
