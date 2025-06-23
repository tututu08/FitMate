//
//  TabBarController.swift
//  FitMate
//
//  Created by 김은서 on 6/6/25.
//
import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    
    // 로그인 유저의 uid
    private let uid: String
    private let disposeBag = DisposeBag()
    
    // 운동 초대 수락 시 Firestore 상태 변경을 위한 ViewModel
    private let matchAcceptViewModel = MatchAcceptViewModel()
        
    lazy var mainVC = MainViewController(uid: self.uid)
    
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
        
        // 전역 초대 알림 감지 및 처리 로직 실행
        observeMatchInvites()
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
    
    // matchEventRelay를 전역에서 구독하여 초대 수신 시 alert 띄우기
    private func observeMatchInvites() {
        MatchEventService.shared.matchEventRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] matchCode in
                self?.presentMatchAlert(matchCode: matchCode)
            })
            .disposed(by: disposeBag)
    }
    
    // 초대 alert 띄우고 수락/거절 처리
    private func presentMatchAlert(matchCode: String) {
        let alert = UIAlertController(
            title: "운동 메이트 요청",
            message: "운동 초대가 도착했습니다!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "수락", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            // matchStatus 최신값 확인!
            FirestoreService.shared.fetchDocument(collectionName: "matches", documentName: matchCode)
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { data in
                    if let matchStatus = data["matchStatus"] as? String, matchStatus == "canceled" {
                        // 이미 취소된 운동!
                        let cancelAlert = UIAlertController(title: "매칭 취소", message: "이미 취소된 운동입니다.", preferredStyle: .alert)
                        cancelAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                            self.popToTabBar() // 또는 popToRootViewController
                        }))
                        UIApplication.topViewController()?.present(cancelAlert, animated: true)
                        return
                    }
                    let gameVC = LoadingViewController(uid: self.uid, matchCode: matchCode)
                    gameVC.hidesBottomBarWhenPushed = true
                    if let nav = self.selectedViewController as? UINavigationController {
                        nav.pushViewController(gameVC, animated: true)
                    }
                }).disposed(by: self.disposeBag)
        }))
        
        alert.addAction(UIAlertAction(title: "거절", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            self.matchAcceptViewModel.respondToMatch(matchCode: matchCode, myUid: self.uid, accept: false)
        }))
        
        UIApplication.topViewController()?.present(alert, animated: true)
    }
    
    class CustomTabBar: UITabBar {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var sizeThatFits = super.sizeThatFits(size)
            sizeThatFits.height = 100 // 원하는 길이
            return sizeThatFits
        }
    }
}
