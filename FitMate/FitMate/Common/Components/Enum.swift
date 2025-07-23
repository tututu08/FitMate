//
//  Enum.swift
//  FitMate
//
//  Created by sophie on 7/23/25.
//

import UIKit

enum SocialLoginType { // used at CustomButton
    case kakao, google, apple
    
    var title: String {
        switch self {
        case .kakao: return "카카오로 시작하기"
        case .google: return "Google로 시작하기"
        case .apple: return "Apple로 시작하기"
        }
    }
    
    var iconName: String {
        switch self {
        case .kakao: return "kakao_renew"
        case .google: return "google_renew"
        case .apple: return "apple_renew"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .kakao: return UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
        case .google: return .white
        case .apple: return .background900
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .kakao: return .background900
        case .google: return .background900
        case .apple: return .white
        }
    }
}

enum LanguagesOption: CaseIterable {
    case korean, english, japanese, chinese
    
    var languageName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        case .japanese: return "日本語"
        case .chinese: return "中文"
        }
    }
}

enum TextOnlyType { // used at CustomButton
    case language(type: LanguagesOption, isSelected: Bool)
    case confirm
    case cancel
    
    var title: String {
        switch self {
        case .language(let type, _):
            return type.languageName
        case .confirm:
            return "선택 완료"
        case .cancel:
            return "취소"
        }
    }
    
    var buttonImageName: String? {
        switch self {
        case .language(_, let isSelected):
            return isSelected ? "radio_selected" : "radio_unselected"
        case .confirm, .cancel:
            return nil
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .language(_, let isSelected):
            return isSelected ? UIColor.primary500 : UIColor.background50
        case .confirm:
            return UIColor.primary500
        case .cancel:
            return UIColor.background50
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .language(_, let isSelected):
            return isSelected ? UIColor.white : UIColor.background500
        case .confirm:
            return UIColor.white
        case .cancel:
            return UIColor.background500
        }
    }
}

//운동 유형 정의 (전체,걷기,달리기)
enum ExerciseType: String, CaseIterable { // from HistoryModel
    case all = "전체"
    case walk = "걷기"
    case run = "달리기"
    case bicycle = "자전거"
    case plank = "플랭크"
    case jumpRope = "줄넘기"
}






