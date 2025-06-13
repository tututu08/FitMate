//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import RxSwift
import RxCocoa

final class HistoryViewModel {

    let selectedCategory = BehaviorRelay<ExerciseType>(value: .all)
    let records = BehaviorRelay<[ExerciseRecord]>(value: [])

    var filteredRecords: Driver<[ExerciseRecord]> {
        return Observable.combineLatest(selectedCategory, records)
            .map { selected, all in
                guard selected != .all else { return all }
                return all.filter { $0.type == selected }
            }
            .asDriver(onErrorJustReturn: [])
    }

    func loadMockData() {
        records.accept([
            ExerciseRecord(type: .walk, date: "2025.03.15", result: .teamSuccess, detail1: "종목", detail2: "종목", detail3: "종목"),
            ExerciseRecord(type: .walk, date: "2025.03.15", result: .teamFail, detail1: "종목", detail2: "종목", detail3: "종목"),
            ExerciseRecord(type: .walk, date: "2025.03.15", result: .versusWin, detail1: "종목", detail2: "종목", detail3: "종목"),
            ExerciseRecord(type: .walk, date: "2025.03.15", result: .versusLose, detail1: "종목", detail2: "종목", detail3: "종목")
        ])
    }
}
