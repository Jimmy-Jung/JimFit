//
//  UserDefaultManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

typealias UM = UserDefaultManager

struct UserDefaultManager {
    
    @UserDefault(key: KeyEnum.savedTime.rawValue, defaultValue: Date())
    static var savedTime: Date
    
    @UserDefault(key: KeyEnum.ETag.rawValue, defaultValue: "")
    static var ETag: String
    
    @UserDefault(key: KeyEnum.currentLanguage.rawValue, defaultValue: "")
    static var currentLanguage: String
    
    @UserDefault(key: KeyEnum.finishedLaunch.rawValue, defaultValue: false)
    static var finishedLaunch: Bool
    
    @UserDefault(key: KeyEnum.recoveryPeriod.rawValue, defaultValue: 72)
    static var recoveryPeriod: Int
    
    enum KeyEnum: String {
        case savedTime
        case ETag
        case currentLanguage
        case finishedLaunch
        case recoveryPeriod
    }
}

@propertyWrapper
/// 유저 디퐅트
struct OptionalUserDefault<T> {
    private let key: String
    
    init(key: String) {
        self.key = key
    }
    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
/// 유저 디퐅트
struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

