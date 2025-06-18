
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
        // 이후에 데이터 연결 예정
        let nickname = Driver.just("닉네임")

        let records = Driver.just([
            WorkoutRecord(type: "종목명", totalDistance: "총기록", unit: "단위"),
            WorkoutRecord(type: "종목명", totalDistance: "총기록", unit: "단위"),
            WorkoutRecord(type: "종목명", totalDistance: "총기록", unit: "단위"),
            WorkoutRecord(type: "종목명", totalDistance: "총기록", unit: "단위"),
            WorkoutRecord(type: "종목명", totalDistance: "총기록", unit: "단위")
        ])

        return Output(nickname: nickname, records: records)
    }
}
