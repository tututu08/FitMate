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
    case sportsMateRequest(message: String)
    case alreadyCancel(message: String)
    case matchingFail(message: String)

    var title: String {
        switch self {
        case .mateRequest: return "메이트 요청 도착"
        case .inviteSent: return "초대 전송 완료"
        case .requestFailed: return "초대 요청 실패"
        case .rejectRequest: return "메이트 요청이 거절됨"
        case .sportsMateRequest: return "운동 메이트 요청"
        case .alreadyCancel: return "매칭이 취소되었습니다"
        case .matchingFail: return "매칭 실패"
        }
    }

    var message: String {
        switch self {
        case .mateRequest(let nickname):
            return "\(nickname)님이 메이트 요청을 보냈어요!"
        case .inviteSent(let nickname):
            return "\(nickname)님에게 메이트 요청을 보냈어요!"
        case .requestFailed(let message):
            return message
        case .rejectRequest(let message):
            return message
        case .sportsMateRequest(let message):
            return "운동 초대가 도착했어요!"
        case .alreadyCancel(let message):
            return "운동이 취소되었습니다"
        case .matchingFail(let message):
            return "메이트가 거절했습니다."
        }
    }

    var buttonStyle: ButtonType {
        switch self {
        case .mateRequest, .sportsMateRequest:
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

