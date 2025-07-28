//
//  KakaoLoginError.swift
//  FitMate
//
//  Created by NH on 7/28/25.
//

import Foundation

enum KakaoLoginError: LocalizedError {
  case userCancelled
  case networkError
  case invalidToken
  case unknownError(String)
  var errorDescription: String? {
    switch self {
    case .userCancelled:
      return "사용자가 로그인을 취소했습니다."
    case .networkError:
      return "네트워크 연결을 확인해주세요."
    case .invalidToken:
      return "로그인 토큰이 유효하지 않습니다."
    case .unknownError(let message):
      return message
    }
  }
}
