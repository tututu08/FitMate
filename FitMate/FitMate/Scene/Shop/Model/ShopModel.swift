//
//  ShopModel.swift
//  FitMate
//
//  Created by soophie on 6/27/25.
//

import Foundation

enum RankCategory: String, CaseIterable {
    case all = "전체"
    case bronze = "브론즈"
    case silver = "실버"
    case gold = "골드"
    case premium = "프리미엄"
    case diamond = "다이아"
}

/// 아바타 고유값과 메타데이터를 담고 있는 타입(enum)
enum AvatarType: String, CaseIterable {
    case koala
    case dog
    case jellyfish
    case kappy
    
    case rhinoceros
    case bear
    case frog
    
    case elephant
    case bee
    case dinosaur
    
    case ladybug
    case crocodile
    case cat
    case crab
    
    var avatarName: String {
        switch self {
        case .koala: return "아라코"
        case .dog: return "바바"
        case .jellyfish: return "빠리"
        case .kappy: return "캐피"
            
        case .rhinoceros: return "뿌리"
        case .bear: return "곰저씨"
        case .frog: return "김개굴"
            
        case .elephant: return "끼리코"
        case .bee: return "꾸루버"
        case .dinosaur: return "머라노"
            
        case .ladybug: return "무무"
        case .crocodile: return "로코"
        case .cat: return "토리"
        case .crab: return "영더기"
        }
    }
    
    var category: RankCategory {
        switch self {
        case .kappy, .jellyfish: return .bronze
        case .rhinoceros, .crab, .crocodile: return .silver
        case .bear, .ladybug, .frog: return .gold
        case .koala, .elephant, .dog: return .premium
        case .cat, .bee, .dinosaur: return .diamond
        }
    }
    
    var imageName: String {
        return self.rawValue
    }
    
    var defaultRatio: CGFloat {
        switch self {
        case .jellyfish: return 1.2
        case .rhinoceros: return 1.1
        case .elephant: return 0.9
        case .crab: return 0.85
        default: return 1.0
        }
    }
}


