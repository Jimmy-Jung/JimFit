//
//  AppDelegate.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/25.
//

import UIKit
import FirebaseAnalytics
import FirebaseCore
import FirebaseRemoteConfig
import RealmSwift
import SwiftRater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UM.finishedLaunch = false

        FirebaseApp.configure()
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        fetchRemoteConfig()
        RealmManager.shared.localizeRealm()
        // 알림 권한 설정
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
        }
        rateStar()
        return true
    }
    
    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate { changed, error in
                    if changed || APIKEY.ExerciseDataURL.isEmpty {
                        if let minimumVersion = remoteConfig["MinimumVersion"].stringValue {
                            UM.minimumVersion = minimumVersion
                        }
                        if let exerciseDataURL = remoteConfig["ExerciseDataURL"].stringValue {
                            APIKEY.ExerciseDataURL = exerciseDataURL
                            FireStorage().checkETagFromFireStore()
                        }
                    } else {
                        UM.finishedLaunch = true
                    }
                }
            }
            if error != nil {
                UM.finishedLaunch = true
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 포그라운드에서 알림 받기
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge, .banner, .list])
    }
    // 푸쉬 탭을 선택했을 때 아래 코드 실행
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        let userInfo = notification.request.content.userInfo
        
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            print ("Message Closed")
        }
        else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print ("푸시 메시지 클릭 했을 때")
            print(userInfo)
        }
        completionHandler()
    }
    
    func rateStar() {
        SwiftRater.daysUntilPrompt = 7
        SwiftRater.usesUntilPrompt = 10
        SwiftRater.significantUsesUntilPrompt = 3
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.appID = "6470066708"
        SwiftRater.appLaunched()
    }
}
