//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation

enum ExerciseType: String, CaseIterable {
    case all = "전체"
    case walk = "걷기"
    case run = "달리기"
    case bike = "자전거"
    case plank = "플랭크"
    case rope = "줄넘기"
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
