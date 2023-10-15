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
    lazy var oldRealm: Realm = { return createOldRealm() }()
    lazy var newRealm: Realm = { return createNewRealm() }()
    
    private lazy var fileManager = FileManager.default
    // 도큐먼트 디렉토리 경로
    private lazy var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // 저장할 파일의 URL
    private lazy var newFileURL = documentsDirectory.appendingPathComponent("NewExercise.realm")
    
    private lazy var oldFileURL = documentsDirectory.appendingPathComponent("OldExercise.realm")
        
    private init() {}
    
    private func createOldRealm() -> Realm {
        return try! Realm(fileURL: oldFileURL)
    }
    
    private func createNewRealm() -> Realm {
        return try! Realm(fileURL: newFileURL)
    }
    
    func saveNewRealm(exercises: [Exercise]) {
        try! newRealm.write {
            newRealm.deleteAll()
            newRealm.add(exercises)
        }
    }
    
    func copyLikeAndRemoveOldRealm() {
        let new = newRealm.objects(Exercise.self)
        let old = oldRealm.objects(Exercise.self)
        
        try! newRealm.write {
            for i in old {
                let object = newRealm.object(ofType: Exercise.self, forPrimaryKey: i.reference)
                object?.liked = i.liked
            }
        }
       
        try! oldRealm.write {
            oldRealm.delete(oldRealm.objects(Exercise.self))
            for i in new {
                let newObject = oldRealm.create(Exercise.self, value: i)
                newObject.exerciseName = i.exerciseName.localized
                oldRealm.add(newObject)
            }
        }
    }
    
    func localizeRealm() {
        let old = oldRealm.objects(Exercise.self)
        try! oldRealm.write {
            for i in old {
                i.exerciseName = i.exerciseName.localized
            }
        }
    }
}
