import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    
    // MARK: - FCM 토큰 수신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM 토큰 수신: \(token)")

        // 로그인 되어 있을 경우에만 저장
        if Auth.auth().currentUser != nil {
            AppDelegate.saveFCMToken(token)
        } else {
            print("사용자 인증 안됨 - 로그인 후 저장 필요")
        }
    }

    // MARK: - FCM 토큰 Firestore 저장
    static func saveFCMToken(_ token: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🛑 토큰 저장 실패: 로그인 안됨")
            return
        }

        let db = Firestore.firestore()
        let tokenData: [String: Any] = [
            "fcmToken": token,
            "updatedAt": Timestamp(date: Date())
        ]

        // (1) tokens/{uid} → merge 방식으로 항상 저장
        db.collection("tokens").document(uid)
          .setData(tokenData, merge: true) { error in
            if let error = error {
                print("❌ tokens 저장 실패:", error.localizedDescription)
            } else {
                print("✅ tokens 저장 완료")
            }
        }

        // (2) users/{uid} → 기존 문서가 있는 경우에만 merge update
        let userDoc = db.collection("users").document(uid)
        userDoc.getDocument { snapshot, error in
            if let err = error {
                print("⚠️ users 문서 확인 실패:", err.localizedDescription)
                return
            }
            guard let snap = snapshot, snap.exists else {
                print("❌ users 문서 없음. fcmToken 덮어쓰기 안 함")
                return
            }

            userDoc.setData(tokenData, merge: true) { error in
                if let error = error {
                    print("❌ users 덮어쓰기 실패:", error.localizedDescription)
                } else {
                    print("✅ users 덮어쓰기 성공")
                }
            }
        }
    }


    // MARK: - 앱 실행 시 초기 설정
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // 푸시 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // Kakao 초기화
        if let kakaoKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String {
            KakaoSDK.initSDK(appKey: kakaoKey)
        } else {
            print("Kakao 앱 키 불러오기 실패")
        }

        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      return UIBackgroundFetchResult.newData
    }
    
    // MARK: - APNs → FCM 토큰 등록
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: - URL Scheme 처리 (Google, Kakao)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        switch url.scheme {
        case "com.googleusercontent.apps":
            return GIDSignIn.sharedInstance.handle(url)
        default:
            if AuthApi.isKakaoTalkLoginUrl(url) {
                return AuthController.handleOpenUrl(url: url)
            }
            return false
        }
    }

    // MARK: - Scene 세션
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
    
    /// 앱이 포그라운드에 있을 때 알림 표시 방법
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void) {
        completion([.banner, .sound])
    }

    /// 사용자가 알림을 탭했을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completion: @escaping () -> Void) {
        
        let info = response.notification.request.content.userInfo

        if
          let type = info["type"] as? String,
          type == "invitation",
          let matchCode = info["matchCode"] as? String {
            
            NotificationCenter.default.post(
                name: .init("DidReceiveInvitation"),
                object: nil,
                userInfo: ["matchCode": matchCode]
            )

        } else if
          let type = info["type"] as? String,
          type == "friend_invitation",
          let fromUid = info["fromUid"] as? String {

            NotificationCenter.default.post(
                name: .init("DidReceiveFriendInvitation"),
                object: nil,
                userInfo: ["fromUid": fromUid]
            )
        }

        completion()
    }
}
