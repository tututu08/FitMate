//
//  CustomAlertType.swift
//  FitMate
//
//  Created by soophie on 6/23/25.
//

import UIKit

enum CustomAlertType {
    case mateRequest(nickname: String)
    case inviteSent(nickname: String)
    case requestFailed(message: String)
    case rejectRequest(message: String)

    var title: String {
        switch self {
        case .mateRequest: return "메이트 요청 도착"
        case .inviteSent: return "초대 전송 완료"
        case .requestFailed: return "초대 요청 실패"
        case .rejectRequest: return "메이트 요청이 거절됨"
        }
    }

    var message: String {
        switch self {
        case .mateRequest:
            return "상대방이 메이트 요청을 보냈습니다"
        case .inviteSent(let nickname):
            return "\(nickname)님에게 메이트 요청을 보냈습니다"
        case .requestFailed(let message):
            return message
        case .rejectRequest(let message):
            return message
        }
    }

    var buttonStyle: ButtonType {
        switch self {
        case .mateRequest:
            return .double("거절하기", "승인하기")
        default:
            return .single("확인")
        }
    }

    enum ButtonType {
        case single(String)
        case double(String, String)
    }
}

