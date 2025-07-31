
import RxSwift
import RxCocoa
import Foundation

final class HistoryViewModel {
    
    struct Input { // 선택된 운동 카테고리를 외부에서 전달받음
        let selectedCategory: Observable<ExerciseType>
    }
    
    struct Output { // 필터링된 운동 기록 배열을 드라이버로 전달( UI에 반인딩하기 위해 드라이버 사용 )
        let filteredRecords: Driver<[ExerciseRecord]>
    }
    
    //사용자가 선택한 운동 카테고리 저장
    private let selectedCategoryRelay = BehaviorRelay<ExerciseType>(value: .all)
    //전체 운동 기록을 저장하는 릴레이
    private let recordsRelay = BehaviorRelay<[ExerciseRecord]>(value: [])
    // 현재 선택된 카테고리에 따라 필터링된 기록을 따로 저장시킴(UI에서 셀의 개수를 계산하거나 별도로 접근할 때 사용)
    private let currentFilteredRecordsRelay = BehaviorRelay<[ExerciseRecord]>(value: [])
    
    
    // 외부에서 바로 접근할 수 있도록 함
    var currentFilteredRecords: [ExerciseRecord] {
        return currentFilteredRecordsRelay.value
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 인풋에서 선택된 카테고리를 내부 릴레이에 바인딩시킴
        input.selectedCategory
            .bind(to: selectedCategoryRelay)
            .disposed(by: disposeBag)
        
        // 선택된 카테고리와 전체 기록이 변경될 때 마다 결과를 필터링함
        let filtered = Observable
            .combineLatest(selectedCategoryRelay, recordsRelay)
            .map { selected, records in
                // 정렬을 날짜기준으로 최신순으로
                let sortedRecords = records.sorted {
                    ($0.dateForSorting ?? Date.distantPast) > ($1.dateForSorting ?? Date.distantPast)
                }
                
                // 전체 혹은 특정 타입만 필터링시킴
                let filtered = (selected == .all) ? sortedRecords : sortedRecords.filter { $0.type == selected }
                return filtered
            }
        // 결과를 내부 저장소에서 저장시킴( 뷰컨에서 직접 접근 가능 )
            .do(onNext: { [weak self] filtered in
                self?.currentFilteredRecordsRelay.accept(filtered)
            })
        // UI에서 사용 가능하도록 드라이버로 변환
            .asDriver(onErrorJustReturn: [])
        
        return Output(filteredRecords: filtered)
    }
    
    func loadRemoteData(uid: String) {
        FirestoreService.shared.fetchExerciseRecords(uid: uid)
            .subscribe(onSuccess: { [weak self] records in
                print("기록 로드 성공!\n불러온 기록 개수: \(records.count)")
                for record in records {
                    //print("기록: \(record)")
                }
                //전체 기록을 릴레이에 저장
                self?.recordsRelay.accept(records)
            }, onFailure: { error in
                print("기록 로드 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
