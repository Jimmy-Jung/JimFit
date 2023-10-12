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
    func exerciseSet(at index: Int) -> ExerciseSet
    func arrangeExerciseSet(at index: Int)
    func moveExerciseSet(from source: Int, to destination: Int)
    func removeExerciseSet(at index: Int)
    func appendExerciseSet()
    func startExerciseTimer()
    func doneExercise()
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
    lazy var timerStatus = BehaviorRelay<TimerManager.TimerStatus>(value: timer.latestTimerStatus)
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
        if let date = workout.OriginWorkoutLog.first?.workoutDate, date == Date().convertToTimeString() {
            self.setUpBinding_Today()
            self.isActiveTimerButton = true
        } else {
            self.setUpBinding_NotToday()
            self.isActiveTimerButton = false
        }
    }
    
    // MARK: - Methods

    func exerciseSet(at index: Int) -> ExerciseSet {
        return workout.exerciseSets[index]
    }
    
    func arrangeExerciseSet(at index: Int) {
        if workout.exerciseSets[index].isFinished {
            let lastIndex = lastFinishedExerciseSetIndex
            try! realm.write {
                self.workout.exerciseSets.move(from: index, to: lastIndex ?? index)
            }
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
    
    // MARK: - Private Methods

    private func setUpBinding_Today() {
        
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
        
        timer.timerStatus
            .bind(to: timerStatus)
            .disposed(by: disposeBag)
    }
    
    private func setUpBinding_NotToday() {
        Observable<String>
            .just(workout.exerciseTime.formattedTime())
            .bind(to: totalExerciseTime)
            .disposed(by: disposeBag)
        
        Observable<String>
            .just(workout.restTime.formattedTime())
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
            .just(workout.exerciseTime + workout.restTime)
            .map { $0.formattedTime()}
            .bind(to: totalTime)
            .disposed(by: disposeBag)
        
        Observable<TimerManager.TimerStatus>
            .just(.none)
            .bind(to: timerStatus)
            .disposed(by: disposeBag)
    }
}
