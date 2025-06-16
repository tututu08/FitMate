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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure() // Firebase
        KakaoSDK.initSDK(appKey: "f2bf0d2c2849c2afb857d80ca4231f39")
        return true
    }
    
    // MARK: Firebase Auth Google Login
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let KAKAO_NATIVE_KEY = "f2bf0d2c2849c2afb857d80ca4231f39"
        
        /// URL scheme을 기준으로 어떤 소셜 로그인 처리인지 분기
        switch url.scheme {
            ///google sdk에 url처리 요청
        case "com.googleusercontent.apps":
            return GIDSignIn.sharedInstance.handle(url)
            
        case "kakaof2bf0d2c2849c2afb857d80ca4231f39":
            /// url이 카카오 로그인용인지 확인
            if AuthApi.isKakaoTalkLoginUrl(url) {
                return AuthController.handleOpenUrl(url: url)
            }
            return false
            
        default:
            return false
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


}

