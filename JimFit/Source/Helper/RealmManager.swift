//
//  RealmManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/30.
//

import Foundation
import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    var realm: Realm!
    var memoryRealm: Realm!
    private init() {
        realm = self.createRealm()
        memoryRealm = self.createMemoryRealm()
    }
    
    private func createRealm() -> Realm {
        let fileManager = FileManager.default
        // 도큐먼트 디렉토리 경로
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 저장할 파일의 URL
        let fileURL = documentsDirectory.appendingPathComponent("Exercise.realm")
        return try! Realm(fileURL: fileURL)
    }
    
    private func createMemoryRealm() -> Realm {
        let configuration = Realm.Configuration(inMemoryIdentifier: "MemoryRealm")
        return try! Realm(configuration: configuration)
    }
}
