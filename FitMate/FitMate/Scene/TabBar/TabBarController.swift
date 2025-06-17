//
//  TabBarController.swift
//  FitMate
//
//  Created by 김은서 on 6/6/25.
//
import UIKit

class TabBarController: UITabBarController {
    
    // 로그인 유저의 uid
    private let uid: String
    
    // 초기화 함수
    init(uid: String) {
        self.uid = uid // 로그인 유저의 uid 의존성 주입
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(CustomTabBar(), forKey: "tabBar")
        configureTabBar()
        setUp()
        selectedIndex = 1 // 시작화면을 메인뷰로 시작
        
        // 운동 매칭 글로벌 리스너 서비스 시작
        MatchEventService.shared.startListening(for: uid)
    }
    
    deinit {
        // 운동 매칭 글로벌 리스너 서비스 중지
        MatchEventService.shared.stopListening()
    }
    
    private func configureTabBar() {
        
        let historyVC = HistoryViewController(uid: self.uid)
        let nav1 = UINavigationController(rootViewController: historyVC)
        
        nav1.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(named: "history"),
            selectedImage: UIImage(named: "historyTapped")
        )
        
        let mainVC = MainViewController(uid: self.uid)
        let nav2 = UINavigationController(rootViewController: mainVC)
        nav2.tabBarItem = UITabBarItem(
            title: "메인",
            image: UIImage(named: "main"),
            selectedImage: UIImage(named: "mainTapped")
        )
        
        let myPageVC = MypageViewController(uid: self.uid)
        let nav3 = UINavigationController(rootViewController: myPageVC)
        nav3.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(named: "mypage"),
            selectedImage: UIImage(named: "mypageTapped")
        )
        
        viewControllers = [nav1, nav2, nav3]
    }
    
    private func setUp() {
        tabBar.barTintColor = .background700
        tabBar.backgroundColor = .background700
        tabBar.tintColor = .secondary400
        tabBar.unselectedItemTintColor = .background400
        tabBar.isTranslucent = false
    }
    
}
class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100 // 원하는 길이
        return sizeThatFits
    }
}
