//
//  Components.swift
//  FitMate
//
//  Created by 김은서 on 6/9/25.
//

import UIKit
import RxSwift
import CoreLocation
import RxCoreLocation

// 네비게이션바 세팅
extension UINavigationBar {
    func applyCustomAppearance(backgroundColor: UIColor = .black, titleColor: UIColor = .white, font: UIFont = .boldSystemFont(ofSize: 20)) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: font
        ]
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
        self.compactAppearance = appearance
        self.tintColor = titleColor // 뒤로가기 버튼 등 색상 설정
    }
}

// CLLocationManager의 위치가 업데이트될 때 호출되는 이벤트
extension Reactive where Base: CLLocationManager {
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                parameters[1] as? [CLLocation] ?? []
            }
    }
}
