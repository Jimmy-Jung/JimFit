//
//  TimerManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import Foundation

final class TimerManager {
    
    enum TimerStatus {
        case exercise
        case rest
        case none
    }
    
    static let shared = TimerManager()
    var exerciseStartTime: Date? // 운동 시작 시간을 저장하는 변수
    var restStartTime: Date? // 휴식 시작 시간을 저장하는 변수
    var totalExerciseTime: TimeInterval = 0 // 총 운동시간을 저장하는 변수
    var setExerciseTime: TimeInterval = 0 // 세트 운동시간을 저장하는 변수
    var totalRestTime: TimeInterval = 0 // 총 휴식시간을 저장하는 변수
    var setRestTime: TimeInterval = 0 // 세트 휴식시간을 저장하는 변수
    var exerciseTimer: Timer? // 운동 타이머
    var restTimer: Timer? // 휴식 타이머
    var timetStatus: TimerStatus = .none
    
    private init() {
        self.restoreTimers()
    }
    
    func startExerciseTimer() {
        timetStatus = .exercise
        setExerciseTime = 0
        exerciseStartTime = Date()
        exerciseTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateExerciseTime),
            userInfo: nil,
            repeats: true
        )
        restTimer?.invalidate()
        restStartTime = nil
    }
    
    @objc private func updateExerciseTime() {
        setExerciseTime += 1
        totalExerciseTime += 1
    }
    
    func completeExercise() {
        timetStatus = .rest
        restStartTime = Date()
        restTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateRestTime),
            userInfo: nil,
            repeats: true
        )
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
