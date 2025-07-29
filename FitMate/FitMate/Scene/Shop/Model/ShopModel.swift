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
    
    var imageName: String {
           return self.rawValue
       }
}


