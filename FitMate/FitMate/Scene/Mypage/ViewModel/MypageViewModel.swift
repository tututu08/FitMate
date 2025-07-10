import Foundation
import RxSwift
import RxCocoa

final class MypageViewModel {
    private let uid: String

    init(uid: String) {
        self.uid = uid
    }

    struct Output {
        //firstore에서 가져온 닉네임 스트림
        let nickname: Driver<String>
        // 누적 기록 스트림
        let records: Driver<[WorkoutRecord]>
    }

    // 외부로 출력할 데이터 스트림 정의
    func transform() -> Output {
        // 닉네임을 가져오는 흐름
        let nickname = FirestoreService.shared
            .fetchDocument(collectionName: "users", documentName: uid)
            .map { $0["nickname"] as? String ?? "닉네임" } //닉네임 파싱
            .asDriver(onErrorJustReturn: "닉네임") // 에러가 발생하면 기본값을 제공(닉네임으로)

        // 누적기록 가져오는 흐름
        let records = FirestoreService.shared
            .fetchTotalStats(uid: uid)
            .map { records in
                var mutableRecords = records
                //플랭크가 항상 세번째에 위치하도록 설정(MVC 이후 2차에 들어가서 이렇게 순서를 변경시킴)
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
            .asDriver(onErrorJustReturn: []) //에러 발생 시 빈 배열 반환

        return Output(nickname: nickname, records: records)
    }
}
