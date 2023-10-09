//
//  UserDefaultManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

typealias UM = UserDefaultManager

struct UserDefaultManager {
    
    @OptionalUserDefault(key: KeyEnum.exerciseStartTime.rawValue)
    static var exerciseStartTime: Date?
    
    @OptionalUserDefault(key: KeyEnum.restStartTime.rawValue)
    static var restStartTime: Date?
    
    @UserDefault(key: KeyEnum.totalExerciseTime.rawValue, defaultValue: 0)
    static var totalExerciseTime: TimeInterval
    
    @UserDefault(key: KeyEnum.setExerciseTime.rawValue, defaultValue: 0)
    static var setExerciseTime: TimeInterval
    
    @UserDefault(key: KeyEnum.totalRestTime.rawValue, defaultValue: 0)
    static var totalRestTime: TimeInterval
    
    @UserDefault(key: KeyEnum.setRestTime.rawValue, defaultValue: 0)
    static var setRestTime: TimeInterval
    
    enum KeyEnum: String {
        case exerciseStartTime
        case restStartTime
        case totalExerciseTime
        case setExerciseTime
        case totalRestTime
        case setRestTime
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

