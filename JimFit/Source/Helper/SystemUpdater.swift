//
//  SystemUpdater.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/27.
//

import UIKit

/// app version 확인, 앱 업데이트 관련
struct SystemUpdater {
    private let appleID = "6470066708"
    /// 현재 버전 정보 : 타겟 -> 일반 -> Version
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    /// 개발자가 내부적으로 확인하기 위한 용도 : 타겟 -> 일반 -> Build
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    private var appStoreOpenUrlString: String { return "itms-apps://itunes.apple.com/app/apple-store/\(appleID)"}
        
    // MARK: - Internal
    
    /// 앱 업데이트가 필요한지 확인
    func isUpdateRequires() -> Bool {
        guard let currentVersion = appVersion else {
            return false
        }
        let minimumVersion = UM.minimumVersion.split(separator: ".").map {$0}
        let splitCurrentVersion = currentVersion.split(separator: ".").map {$0}
        
        // 가장 앞자리 확인 : 1.2.3 -> 1
        if splitCurrentVersion[0] < minimumVersion[safe: 0] ?? "0"  {
            return true
            
        // 두 번째 자리 확인 : 1.2.3 -> 2
        } else if splitCurrentVersion[1] < minimumVersion[safe: 1] ?? "0"  {
            return true
            
        // 세 번째 자리 확인 : 1.2.3 -> 3
        } else if splitCurrentVersion[2] < minimumVersion[safe: 2] ?? "0"  {
            return true
            
        } else {
            return false
        }
    }
    
    /// 앱의 현재 버전과 최신 버전을 비교하여 다를 경우 true를 반환하는 메서드
    func isUpdateNeeds() async -> Bool {
        guard let currentVersion = appVersion,
              let latestVersion = await latestVersion() else {
            return false
        }
        let splitLatestVersion = latestVersion.split(separator: ".").map {$0}
        let splitCurrentVersion = currentVersion.split(separator: ".").map {$0}
        
        // 가장 앞자리 확인 : 1.2.3 -> 1
        if splitCurrentVersion[0] < splitLatestVersion[safe: 0] ?? "0" {
            return true
        // 두 번째 자리 확인 : 1.2.3 -> 2
        } else if splitCurrentVersion[1] < splitLatestVersion[safe: 1] ?? "0" {
            return true
            
        // 세 번째 자리 확인 : 1.2.3 -> 3
        } else {
            return false
        }
    }
    
    
    
    /// 앱 스토어로 이동 -> urlStr 에 appStoreOpenUrlString 넣으면 이동
    func openAppStore() {
        guard let url = URL(string: appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Private

    /// 앱 스토어 최신 정보 확인
    func latestVersion() async -> String? {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=\(appleID)&country=kr") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results[safe: 0]?["version"] as? String else {
                return nil
            }
            return appStoreVersion
        } catch {
            return nil
        }
    }
}
