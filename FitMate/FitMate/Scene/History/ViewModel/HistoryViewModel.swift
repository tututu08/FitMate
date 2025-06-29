
import RxSwift
import RxCocoa
import Foundation

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

    private let disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)

        let filtered = Observable
            .combineLatest(selectedCategoryRelay, recordsRelay)
            .map { selected, records in
                let sortedRecords = records.sorted {
                    ($0.dateForSorting ?? Date.distantPast) > ($1.dateForSorting ?? Date.distantPast)
                }
                let filtered = (selected == .all) ? sortedRecords : sortedRecords.filter { $0.type == selected }
                return filtered
            }
            .do(onNext: { [weak self] filtered in
                self?.currentFilteredRecordsRelay.accept(filtered)
            })
            .asDriver(onErrorJustReturn: [])

        return Output(filteredRecords: filtered)
    }

    func loadRemoteData(uid: String) {
        FirestoreService.shared.fetchExerciseRecords(uid: uid)
            .subscribe(onSuccess: { [weak self] records in
                print("기록 로드 성공!\n불러온 기록 개수: \(records.count)")
                for record in records {
                    //print("📌 기록: \(record)")
                }
                self?.recordsRelay.accept(records)
            }, onFailure: { error in
                print("기록 로드 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
