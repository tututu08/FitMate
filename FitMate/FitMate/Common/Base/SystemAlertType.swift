//
//  SystemALertType.swift
//  FitMate
//
//  Created by soophie on 6/16/25.
//

import UIKit

enum SystemAlertType {
    case copied
    case invalidCode
    case codeSent
    case overLimit
    case duplicateNickname
    case custom(title: String, Message: String? = nil)
    
    var title: String {
        switch self {
        case .copied:
            return "코드가 복사되었습니다"
        case .invalidCode:
            return "잘못된 코드입니다"
        case .codeSent:
            return "메이트에게 요청을 보냈어요"
        case .overLimit:
            return "8자 이하로 입력해주세요"
        case .duplicateNickname:
            return "앗! 중복된 닉네임 입니다."
        case .custom(let title, _):
            return title
        }
    }
    
    var message: String? {
        switch self {
        case .copied, .invalidCode, .codeSent, .overLimit, .duplicateNickname:
            return nil
        case .custom(_, let message):
            return message
        }
    }
    
    var actions: [UIAlertAction] {
        switch self {
        case .copied, .invalidCode, .codeSent, .overLimit, .duplicateNickname, .custom:
            return [
                UIAlertAction(title: "확인", style: .default, handler: nil)
            ]
        }
    }
    
    func makeAlertController() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        return alert
    }
}
