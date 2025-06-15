//
//  TabBarController.swift
//  FitMate
//
//  Created by 김은서 on 6/6/25.
//
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(CustomTabBar(), forKey: "tabBar")
        configureTabBar()
        setUp()
    }
    private func configureTabBar() {
        
        let historyVC = HistoryViewController()
        let nav1 = UINavigationController(rootViewController: historyVC)
        
        nav1.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(named: "history"),
            selectedImage: UIImage(named: "historyTapped")
        )
        
        let mainVC = MainViewController()
        let nav2 = UINavigationController(rootViewController: mainVC)
        nav2.tabBarItem = UITabBarItem(
            title: "메인",
            image: UIImage(named: "main"),
            selectedImage: UIImage(named: "mainTapped")
        )
        
        let myPageVC = MypageViewController()
        let nav3 = UINavigationController(rootViewController: myPageVC)
        nav3.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(named: "mypage"),
            selectedImage: UIImage(named: "mypageTapped")
        )
        
        viewControllers = [nav1, nav2, nav3]
    }
    
    private func setUp() {
        tabBar.backgroundColor = .background400
        tabBar.barTintColor = .white
        tabBar.isTranslucent = true
    }
    
}
class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 83 // 원하는 길이
        return sizeThatFits
    }
}
