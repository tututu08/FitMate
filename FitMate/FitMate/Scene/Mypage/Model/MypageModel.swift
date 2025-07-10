
import Foundation

//마이페이지에서 표시될 종목별 누적 기록모델
struct WorkoutRecord {
    let type: String //운동 종목명
    let totalDistance: String //누적거리나 시간 등
    let unit: String //운동 단위
}
