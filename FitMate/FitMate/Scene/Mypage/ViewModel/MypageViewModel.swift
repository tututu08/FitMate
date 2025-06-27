
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
                records.filter { $0.type != "플랭크" }  //플랭크 필터처리
            }
            .do(onSuccess: { print("🏁 ViewModel에서 받은 기록: \($0)") })
            .asDriver(onErrorJustReturn: [])
        
        return Output(nickname: nickname, records: records)
    }
}
