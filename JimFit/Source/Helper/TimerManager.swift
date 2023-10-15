//
//  TimerManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation
import RealmSwift
import RxSwift
import RxRelay

final class TimerManager {
    
    static let shared = TimerManager()
    let realm = RealmManager.shared.oldRealm
    var workoutLog: WorkoutLog?
    var recordingDay: String?
    var totalTimePublisher = PublishRelay<TimeInterval>()
    var totalTime: TimeInterval = 0 { didSet { totalTimePublisher.accept(totalTime) } }
    var totalExerciseTimePublisher = PublishRelay<TimeInterval>()
    var setExerciseTimePublisher = PublishRelay<TimeInterval>()
    var totalRestTimePublisher = PublishRelay<TimeInterval>()
    var setRestTimePublisher = PublishRelay<TimeInterval>()
    var totalExerciseTime: TimeInterval = 0 { didSet { totalExerciseTimePublisher.accept(totalExerciseTime) } }
    var setExerciseTime: TimeInterval = 0 { didSet { setExerciseTimePublisher.accept(setExerciseTime) } }
    var totalRestTime: TimeInterval = 0 { didSet { totalRestTimePublisher.accept(totalRestTime) } }
    var setRestTime: TimeInterval = 0 { didSet { setRestTimePublisher.accept(setRestTime) } }
    private var exerciseTimer: Timer?
    private var restTimer: Timer?
    var timerStatusPublisher = PublishRelay<TimerStatus>()
    var timerStatus: TimerStatus = .paused { didSet{ timerStatusPublisher.accept(timerStatus)}}
    
    private init() {
        self.restoreTimers()
    }
    
    func fetchTimer(with workoutLog: WorkoutLog) {
        self.workoutLog = workoutLog
        totalExerciseTime = workoutLog.exerciseTime
        totalRestTime = workoutLog.restTime
        totalTime = totalExerciseTime + totalRestTime
    }
    
    func stopTimer() {
        exerciseTimer?.invalidate()
        restTimer?.invalidate()
        timerStatus = .paused
        setExerciseTime = 0
        setRestTime = 0
        recordingDay = nil
        workoutLog = nil
    }
    
    func startExerciseTimer() {
        if timerStatus != .exercise {
            timerStatus = .exercise
            setExerciseTime = 0
            exerciseTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateExerciseTime),
                userInfo: nil,
                repeats: true
            )
            restTimer?.invalidate()
            recordingDay = workoutLog?.workoutDate
        }
    }
    
    @objc private func updateExerciseTime() {
        setExerciseTime += 1
        totalExerciseTime += 1
        totalTime += 1
    }
    
    func doneExercise() {
        if timerStatus != .rest {
            timerStatus = .rest
            setRestTime = 0
            restTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateRestTime),
                userInfo: nil,
                repeats: true
            )
            exerciseTimer?.invalidate()
            recordingDay = workoutLog?.workoutDate
        }
    }
    
    @objc private func updateRestTime() {
        setRestTime += 1
        totalRestTime += 1
        totalTime += 1
    }
    
    // 앱이 꺼졌을 때 타이머 저장
    func saveTimers() {
        exerciseTimer?.invalidate()
        restTimer?.invalidate()
        UM.savedExerciseStartTime = Date()
        UM.savedRestStartTime = Date()
        try! realm.write {
            workoutLog?.exerciseTime = totalExerciseTime
            workoutLog?.restTime = totalRestTime
        }
    }
    
    func restoreTimers() {
        if timerStatus == .exercise {
            let setTimeInterval = Date().timeIntervalSince(UM.savedExerciseStartTime)
            totalExerciseTime += setTimeInterval
            setExerciseTime += setTimeInterval
            exerciseTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateExerciseTime),
                userInfo: nil,
                repeats: true
            )
        } else if timerStatus == .rest {
            let setTimeInterval = Date().timeIntervalSince(UM.savedRestStartTime)
            totalRestTime += setTimeInterval
            setRestTime += setTimeInterval
            restTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(updateRestTime),
                userInfo: nil,
                repeats: true
            )
        }
        totalTime = totalExerciseTime + totalRestTime
    }
}

extension TimerManager {
    enum TimerStatus {
        case exercise
        case rest
        case paused
    }
}
