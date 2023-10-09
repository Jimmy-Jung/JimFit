//
//  TimerManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation
import RxSwift
import RxRelay

final class TimerManager {
    
    static let shared = TimerManager()
    
    var totalExerciseTimePublisher = BehaviorSubject<TimeInterval>(value: 0)
    var setExerciseTimePublisher = BehaviorSubject<TimeInterval>(value: 0)
    var totalRestTimePublisher = BehaviorSubject<TimeInterval>(value: 0)
    var setRestTimePublisher = BehaviorSubject<TimeInterval>(value: 0)
    private var totalExerciseTime: TimeInterval = 0 { didSet { totalExerciseTimePublisher.onNext(totalExerciseTime) } }
    private var setExerciseTime: TimeInterval = 0 { didSet { setExerciseTimePublisher.onNext(setExerciseTime) } }
    private var totalRestTime: TimeInterval = 0 { didSet { totalRestTimePublisher.onNext(totalRestTime) } }
    private var setRestTime: TimeInterval = 0 { didSet { setRestTimePublisher.onNext(setRestTime) } }
    private var exerciseStartTime: Date?
    private var restStartTime: Date?
    private var exerciseTimer: Timer?
    private var restTimer: Timer?
    var timerStatus: TimerStatus = .none
    
    private init() {
        self.restoreTimers()
    }
    
    func startExerciseTimer() {
        if exerciseStartTime == nil {
            timerStatus = .exercise
            setExerciseTime = 0
            exerciseStartTime = Date()
            exerciseTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateExerciseTime),
                userInfo: nil,
                repeats: true
            )
        }
        restTimer?.invalidate()
        restStartTime = nil
    }
    
    @objc private func updateExerciseTime() {
        setExerciseTime += 1
        totalExerciseTime += 1
    }
    
    func doneExercise() {
        if restStartTime == nil {
            timerStatus = .rest
            restStartTime = Date()
            restTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateRestTime),
                userInfo: nil,
                repeats: true
            )
        }
        exerciseTimer?.invalidate()
        exerciseStartTime = nil
    }
    
    @objc private func updateRestTime() {
        setRestTime += 1
        totalRestTime += 1
    }
    
    // 앱이 꺼졌을 때 타이머 저장
    func saveTimers() {
        UM.exerciseStartTime = exerciseStartTime
        UM.restStartTime = restStartTime
        UM.totalExerciseTime = totalExerciseTime
        UM.setExerciseTime = setExerciseTime
        UM.totalRestTime = totalRestTime
        UM.setRestTime = setRestTime
    }
    
    func restoreTimers() {
        if let storedExerciseStartTime = UM.exerciseStartTime {
            exerciseStartTime = storedExerciseStartTime
        }
        if let storedRestStartTime = UM.restStartTime {
            restStartTime = storedRestStartTime
        }
    }
}

extension TimerManager {
    enum TimerStatus {
        case exercise
        case rest
        case none
    }
}
