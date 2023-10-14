//
//  ExerciseSetViewModel.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/10.
//

import UIKit
import RealmSwift
import RxSwift
import RxRelay

protocol ExerciseSetViewModelProtocol {
    var totalExerciseTime: BehaviorRelay<String> { get set }
    var totalRestTime: BehaviorRelay<String> { get set }
    var setExerciseTime: BehaviorRelay<String> { get set }
    var setRestTime: BehaviorRelay<String> { get set }
    var totalTime: BehaviorRelay<String> { get set }
    var timerStatus: BehaviorRelay<TimerManager.TimerStatus> { get set }
    var grabberTitle: String { get }
    var exerciseSetsCount: Int { get }
    var lastFinishedExerciseSetIndex: Int? { get }
    var isActiveTimerButton: Bool { get set }
    func isExerciseSetFinished(at index: Int) -> Bool
    func exerciseSet(at index: Int) -> ExerciseSet
    func toggleExerciseSetFinished(at index: Int)
    func moveExerciseSet(from source: Int, to destination: Int)
    func removeExerciseSet(at index: Int)
    func appendExerciseSet()
    func startExerciseTimer()
    func doneExercise()
    func stopExercise()
}

final class ExerciseSetViewModel: ExerciseSetViewModelProtocol {
    // MARK: - Private Properties

    private var workout: Workout
    private let realm = RealmManager.shared.realm
    private let timer = TimerManager.shared
    private let disposeBag = DisposeBag()
   
    // MARK: - Properties

    lazy var totalExerciseTime = BehaviorRelay<String>(value: timer.totalExerciseTime.formattedTime())
    lazy var totalRestTime = BehaviorRelay<String>(value: timer.totalRestTime.formattedTime())
    lazy var setExerciseTime = BehaviorRelay<String>(value: timer.setExerciseTime.formattedTime())
    lazy var setRestTime = BehaviorRelay<String>(value: timer.setRestTime.formattedTime())
    lazy var totalTime = BehaviorRelay<String>(value: timer.totalTime.formattedTime())
    lazy var timerStatus = BehaviorRelay<TimerManager.TimerStatus>(value: timer.timerStatus)
    var grabberTitle: String {
        return workout.exercise?.exerciseName.localized ?? ""
    }
    var exerciseSetsCount: Int {
        return workout.exerciseSets.count
    }
    var lastFinishedExerciseSetIndex: Int? {
        return workout.exerciseSets.lastIndex { $0.isFinished }
    }
    
    var isActiveTimerButton: Bool = false
    
    // MARK: - Init

    init(workout: Workout) {
        self.workout = workout
        guard let workoutLog = workout.OriginWorkoutLog.first else { return }
        if timer.timerStatus == .paused {
            timer.fetchTimer(with: workoutLog)
            self.setUpBinding_Today()
            self.isActiveTimerButton = true
        } else {
            if timer.recordingDay == workoutLog.workoutDate {
                timer.fetchTimer(with: workoutLog)
                self.setUpBinding_Today()
                self.isActiveTimerButton = true
            } else {
                timer.fetchTimer(with: workoutLog)
                self.setUpBinding_NotToday()
                self.isActiveTimerButton = false
            }
        }
    }
    
    // MARK: - Methods

    func isExerciseSetFinished(at index: Int) -> Bool {
        return workout.exerciseSets[index].isFinished
    }
    
    func exerciseSet(at index: Int) -> ExerciseSet {
        return workout.exerciseSets[index]
    }
    
    func toggleExerciseSetFinished(at index: Int) {
        try! realm.write {
            workout.exerciseSets[index].isFinished.toggle()
        }
    }
    
    func moveExerciseSet(from source: Int, to destination: Int) {
        try! realm.write {
            workout.exerciseSets.move(from: source, to: destination)
        }
    }
    
    func removeExerciseSet(at index: Int) {
        try! realm.write {
            workout.exerciseSets.remove(at: index)
        }
    }
    
    func appendExerciseSet() {
        let repetitionCount = workout.exerciseSets.last?.repetitionCount ?? 0
        let weight = workout.exerciseSets.last?.weight ?? 0
        try! realm.write {
            self.workout.exerciseSets.append(ExerciseSet(repetitionCount: repetitionCount, weight: weight))
        }
    }
    
    func startExerciseTimer() {
        self.timer.startExerciseTimer()
    }
    
    func doneExercise() {
        self.timer.doneExercise()
        guard let set = workout.exerciseSets
            .first(where: { $0.isFinished == false })
        else { return }
        try! realm.write {
            set.isFinished = true
        }
    }
    
    func stopExercise() {
        self.timer.stopTimer()
        try! realm.write {
            guard let workoutLog = workout.OriginWorkoutLog.first else { return }
            workoutLog.exerciseTime = timer.totalExerciseTime
            workoutLog.restTime = timer.totalRestTime
        }
    }
    
    // MARK: - Private Methods

    private func setUpBinding_Today() {
        guard let workoutLog = workout.OriginWorkoutLog.first else { return }
        
        timer.totalExerciseTimePublisher
            .map { $0.formattedTime() }
            .bind(to: totalExerciseTime)
            .disposed(by: disposeBag)
        
        timer.totalRestTimePublisher
            .map { $0.formattedTime() }
            .bind(to: totalRestTime)
            .disposed(by: disposeBag)
        
        timer.setExerciseTimePublisher
            .map { $0.formattedTime() }
            .bind(to: setExerciseTime)
            .disposed(by: disposeBag)
        
        timer.setRestTimePublisher
            .map { $0.formattedTime() }
            .bind(to: setRestTime)
            .disposed(by: disposeBag)
        
        timer.totalTimePublisher
            .map { $0.formattedTime() }
            .bind(to: totalTime)
            .disposed(by: disposeBag)
        
        timer.timerStatusPublisher
            .bind(to: timerStatus)
            .disposed(by: disposeBag)
    }
    
    private func setUpBinding_NotToday() {
        guard let workoutLog = workout.OriginWorkoutLog.first else { return }
        Observable<String>
            .just(workoutLog.exerciseTime.formattedTime())
            .bind(to: totalExerciseTime)
            .disposed(by: disposeBag)
        
        Observable<String>
            .just(workoutLog.restTime.formattedTime())
            .bind(to: totalRestTime)
            .disposed(by: disposeBag)
        
        Observable<String>
            .just(0.formattedTime())
            .bind(to: setExerciseTime)
            .disposed(by: disposeBag)
        
        Observable<String>
            .just(0.formattedTime())
            .bind(to: setRestTime)
            .disposed(by: disposeBag)
        
        Observable<TimeInterval>
            .just(workoutLog.exerciseTime + workoutLog.restTime)
            .map { $0.formattedTime()}
            .bind(to: totalTime)
            .disposed(by: disposeBag)
        
        Observable<TimerManager.TimerStatus>
            .just(.paused)
            .bind(to: timerStatus)
            .disposed(by: disposeBag)
    }
}
