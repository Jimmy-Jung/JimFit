//
//  AppDelegate.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/25.
//

import UIKit
import FirebaseCore
import FirebaseRemoteConfig
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UM.finishedLaunch = false

        FirebaseApp.configure()
        fetchRemoteConfig()
        RealmManager.shared.localizeRealm()

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
                        guard let exerciseDataURL = remoteConfig["ExerciseDataURL"].stringValue else { return }
                        APIKEY.ExerciseDataURL = exerciseDataURL
                        FireStorage().checkETagFromFireStore()
                    } else {
                        UM.finishedLaunch = true
                    }
                }
            }
            if error != nil {
                print(error)
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

