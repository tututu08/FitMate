//
//  RunningViewModel.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MypageViewModel {
    struct Output {
        let nickname: Driver<String>
        let records: Driver<[WorkoutRecord]>
    }

    func transform() -> Output {
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
