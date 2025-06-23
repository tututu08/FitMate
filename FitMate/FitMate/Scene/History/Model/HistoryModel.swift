
import Foundation

enum ExerciseType: String, CaseIterable {
    case all = "전체"
    case walk = "걷기"
    case run = "달리기"
    case bicycle = "자전거"
    case plank = "플랭크"
    case jumpRope = "줄넘기"
}

enum ExerciseResult: String {
    case teamSuccess = "협력-성공"
    case teamFail = "협력-실패"
    case versusWin = "대결-승리"
    case versusLose = "대결-패배"
}

struct ExerciseRecord {
    let type: ExerciseType
    let date: String
    let result: ExerciseResult
    let detail1: String
    let detail2: String
    let detail3: String
}
extension ExerciseRecord {
    var dateForSorting: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.date(from: self.date)
    }

    var dateOnly: String {
        return String(self.date.prefix(10))  // "yyyy.MM.dd"로 호출되게 바꿈
    }
}
