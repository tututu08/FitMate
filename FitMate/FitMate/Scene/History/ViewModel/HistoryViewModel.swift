
import RxSwift
import RxCocoa

final class HistoryViewModel {

    struct Input {
        let selectedCategory: Observable<ExerciseType>
    }

    struct Output {
        let filteredRecords: Driver<[ExerciseRecord]>
    }

    private let selectedCategoryRelay = BehaviorRelay<ExerciseType>(value: .all)
    private let recordsRelay = BehaviorRelay<[ExerciseRecord]>(value: [])

    private let currentFilteredRecordsRelay = BehaviorRelay<[ExerciseRecord]>(value: [])
    var currentFilteredRecords: [ExerciseRecord] {
        return currentFilteredRecordsRelay.value
    }

    func transform(input: Input) -> Output {
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)

        let filtered = Observable
            .combineLatest(selectedCategoryRelay, recordsRelay)
            .map { selected, records in
                if selected == .all {
                    return records
                } else {
                    return records.filter { $0.type == selected }
                }
            }
            .do(onNext: { [weak self] filtered in
                self?.currentFilteredRecordsRelay.accept(filtered)
            })
            .asDriver(onErrorJustReturn: [])

        return Output(filteredRecords: filtered)
    }

//    func loadMockData() {
//        let dummy: [ExerciseRecord] = [
//            .init(type: .walk, date: "0000.00.00", result: .versusLose, detail1: "0", detail2: "0", detail3: "0"),
//            .init(type: .jumprope, date: "0000.00.00", result: .versusWin, detail1: "0", detail2: "0", detail3: "0"),
//            .init(type: .bicycle, date: "0000.00.00", result: .versusLose, detail1: "0", detail2: "0", detail3: "0"),
//            .init(type: .run, date: "0000.00.00", result: .versusWin, detail1: "0", detail2: "0", detail3: "0"),
//            .init(type: .plank, date: "0000.00.00", result: .teamSuccess, detail1: "0", detail2: "0", detail3: "")
//        ]
//        recordsRelay.accept(dummy)
//    }
    
    func loadRemoteData(uid: String) {
        FirestoreService.shared.fetchExerciseRecords(uid: uid)
            .subscribe(onSuccess: { [weak self] records in
                print("🔥 불러온 기록 개수: \(records.count)")
                for record in records {
                    print("📌 기록: \(record)")
                }
                self?.recordsRelay.accept(records)
            }, onFailure: { error in
                print("❌ 기록 로드 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
}
