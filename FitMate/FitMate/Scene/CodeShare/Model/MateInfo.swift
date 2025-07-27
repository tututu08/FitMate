//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import Foundation

struct MateInfo {
    let uid: String
    let nickname: String
    let startDate: String
    
    // Firebase는 Swift 객체 자체를 저장할 수 없기 때문에
    // [String: Any] 같은 딕셔너리로 변환해서 저장해야 함
    var asDictionary: [String: Any] {
        return [
            "uid": uid,
            "nickname": nickname,
            "startDate": startDate
        ]
    }
}
