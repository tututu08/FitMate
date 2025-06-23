//
//  TopViewController.swift
//  FitMate
//
//  Created by NH on 6/23/25.
//

import UIKit

/// 현재 화면에서 가장 위에 떠 있는 ViewController를 찾아주는 확장 함수
/// - alert를 어떤 화면에서도 안전하게 띄우기 위해 사용됨
extension UIApplication {
    
    /// 최상단에 있는 ViewController를 재귀적으로 탐색하여 반환
    /// - 파라미터: 기본값은 앱의 rootViewController
    class func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            // 모든 windowScene 중에서
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            // 첫 번째 keyWindow의 rootViewController부터 시작
            .first?.rootViewController
    ) -> UIViewController? {
        
        // 1. base가 UINavigationController라면
        if let nav = base as? UINavigationController {
            // 현재 보이는 뷰컨(visibleViewController)을 기준으로 다시 탐색
            return topViewController(base: nav.visibleViewController)
        }
        
        // 2. base가 UITabBarController라면
        else if let tab = base as? UITabBarController {
            // 현재 선택된 탭(selectedViewController)을 기준으로 다시 탐색
            return topViewController(base: tab.selectedViewController)
        }
        
        // 3. base 위에 뷰컨이 하나 더 present 되어 있다면 (모달 등)
        else if let presented = base?.presentedViewController {
            // 그 presented된 VC를 기준으로 다시 탐색
            return topViewController(base: presented)
        }
        
        // 4. 더 이상 중첩된 VC가 없다면 현재 base를 반환
        return base
    }
}
