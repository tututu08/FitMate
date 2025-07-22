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
    case arako
    case baba
    case bbari
    case kaepy
    
    case bburi
    case gomjeossi
    case kimgaegul
    
    case kkiriko
    case kkuluber
    case morano
    
    case mumu
    case roko
    case tori
    case yeongdeogi
    
    var avatarName: String {
        switch self {
        case .arako: return "아라코"
        case .baba: return "바바"
        case .bbari: return "빠리"
        case .kaepy: return "캐피"
            
        case .bburi: return "뿌리"
        case .gomjeossi: return "곰저씨"
        case .kimgaegul: return "김개굴"
            
        case .kkiriko: return "끼리코"
        case .kkuluber: return "꾸루버"
        case .morano: return "머라노"
            
        case .mumu: return "무무"
        case .roko: return "로코"
        case .tori: return "토리"
        case .yeongdeogi: return "영더기"
        }
    }
    
    var category: RankCategory {
        switch self {
        case .kaepy, .bbari: return .bronze
        case .bburi, .yeongdeogi, .roko: return .silver
        case .gomjeossi, .mumu, .kimgaegul: return .gold
        case .arako, .kkiriko, .baba: return .premium
        case .tori, .kkuluber, .morano: return .diamond
        }
    }
    
    var imageName: String {
        return self.rawValue
    }
    
    var defaultRatio: CGFloat {
        switch self {
        case .bbari: return 1.2
        case .bburi: return 1.1
        case .kkiriko: return 0.9
        case .yeongdeogi: return 0.85
        default: return 1.0
        }
    }
}


