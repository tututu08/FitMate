//
//  Untitled.swift
//  FitMate
//
//  Created by Sophie on 6/10/25.
//

import UIKit

enum SystemAlertType {
    case copied
    case invalidCode
    case codeSent
    
    var title: String {
        switch self{
        case.copied:
            return "코드가 복사되었습니다"
        case.invalidCode:
            return "잘못된 코드입니다"
        case.codeSent:
            return "메이트에게 요청을 보냈습니다"
        }
    }
    
    var actions: [UIAlertAction] {
        switch self {
        case .copied,.invalidCode, .codeSent:
            return [UIAlertAction(
                title: "확인",
                style: .default,
                handler: nil)]
        }
    }
}
