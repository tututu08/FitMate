//
//  AppDelegate.swift
//  FitMate
//
//  Created by 강성훈 on 6/3/25.
//

import UIKit
import FirebaseCore // Firebase
import GoogleSignIn // FirebaseAuth google 로그인
import KakaoSDKAuth
import KakaoSDKCommon
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure() // Firebase
        
        // 알림 권한 요청
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Kakao 앱 키를 Info.plist에서 불러오기
        if let kakaoKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: kakaoKey)
        } else {
            print("Kakao 앱 키 불러오기 실패")
        }
        // FCM delegate
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // MARK: Firebase Auth Login
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // URL scheme을 기준으로 어떤 소셜 로그인 처리인지 분기
        switch url.scheme {
            
            // Google 로그인 처리
        case "com.googleusercontent.apps":
            return GIDSignIn.sharedInstance.handle(url)
            
            // Kakao 로그인 처리 (scheme은 더이상 비교하지 않아도 됨)
        default:
            if AuthApi.isKakaoTalkLoginUrl(url) {
                return AuthController.handleOpenUrl(url: url)
            }
            return false
        }
    }
    // APNs 토큰 → FCM에 등록
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}


// MARK: UISceneSession Lifec

func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

// UNUserNotificationCenterDelegate
extension AppDelegate {

    /// 포그라운드에서도 배너·소리 노출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {

        completion([.banner, .sound])   // 원하는 표시 옵션
    }

    /// 사용자가 배너를 탭했을 때 deep-link 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completion: @escaping () -> Void) {

        let info = response.notification.request.content.userInfo
        if
          let type = info["type"] as? String, type == "invitation",
          let matchCode = info["matchCode"] as? String {

            // 예시: NotificationCenter 로 앱 전체에 이벤트 전달
            NotificationCenter.default.post(
                name: .init("DidReceiveInvitation"),
                object: nil,
                userInfo: ["matchCode": matchCode]
            )
        }
        completion()
    }
}


