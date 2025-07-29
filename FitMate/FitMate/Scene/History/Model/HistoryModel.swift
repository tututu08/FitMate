
import Foundation

//운동 결과 유형 정의 (협력성공,실패/대결승리,패배)
enum ExerciseResult: String {
    case teamSuccess = "협력-성공"
    case teamFail = "협력-실패"
    case versusWin = "대결-승리"
    case versusLose = "대결-패배"
}

//하나의 운동 기록을 표현하는 구조체
struct ExerciseRecord {
    let type: ExerciseType //운동 유형
    let date: String // 기록 일시
    let result: ExerciseResult // 운동 결과
    let detail1: String
    let detail2: String
    let detail3: String
}

extension ExerciseRecord {
    var dateForSorting: Date? { // 정렬을 위한 Data 전환
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.date(from: self.date)
    }
    
    var dateOnly: String {
        return String(self.date.prefix(10))  // "yyyy.MM.dd"로 호출되게 바꿈
    }
}
