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
    var grabberTitle: String? { get }
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
    func startRestTimer()
    func stopExercise()
}

final class ExerciseSetViewModel: ExerciseSetViewModelProtocol {
    // MARK: - Private Properties

    private var workout: Workout
    private let realm = RealmManager.shared.oldRealm
    private let timer = TimerManager.shared
    private let disposeBag = DisposeBag()
   
    // MARK: - Properties

    lazy var totalExerciseTime = BehaviorRelay<String>(value: timer.totalExerciseTime.formattedTime())
    lazy var totalRestTime = BehaviorRelay<String>(value: timer.totalRestTime.formattedTime())
    lazy var setExerciseTime = BehaviorRelay<String>(value: timer.setExerciseTime.formattedTime())
    lazy var setRestTime = BehaviorRelay<String>(value: timer.setRestTime.formattedTime())
    lazy var totalTime = BehaviorRelay<String>(value: timer.totalTime.formattedTime())
    lazy var timerStatus = BehaviorRelay<TimerManager.TimerStatus>(value: timer.timerStatus)
    var grabberTitle: String? {
        return realm.object(ofType: Exercise.self, forPrimaryKey: workout.exerciseReference)?.exerciseName
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
        if timer.timerStatus == .stop {
            timer.fetchTimer(with: workoutLog)
            self.setUpBinding_Today()
            self.isActiveTimerButton = true
        } else {
            if timer.recordingDay == workoutLog.workoutDate {
                self.setUpBinding_Today()
                self.isActiveTimerButton = true
            } else {
                self.setUpBinding_NotToday()
                self.isActiveTimerButton = false
            }
        }
        if workoutLog.workoutDate != Date().convert(to: .primaryKey) {
            self.isActiveTimerButton = false
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
    
    func startRestTimer() {
        self.timer.startRestTimer()
        guard let set = workout.exerciseSets
            .first(where: { $0.isFinished == false })
        else { return }
        try! realm.write {
            set.isFinished = true
        }
    }
    
    func stopExercise() {
        self.timer.stopTimer()
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
            .just(.stop)
            .bind(to: timerStatus)
            .disposed(by: disposeBag)
    }
}

final class ExerciseSetViewModelTest: ExerciseSetViewModelProtocol {
    var totalExerciseTime: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var totalRestTime: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var setExerciseTime: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var setRestTime: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var totalTime: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var timerStatus: BehaviorRelay<TimerManager.TimerStatus> = BehaviorRelay<TimerManager.TimerStatus>(value: .stop)
    var grabberTitle: String? = ""
    var exerciseSetsCount: Int = 0
    var lastFinishedExerciseSetIndex: Int? = nil
    var isActiveTimerButton: Bool = false
    
    var isExerciseSetFinishedCalled: Bool = false
    var exerciseSetCalled: Bool = false
    var toggleExerciseSetFinishedCalled: Bool = false
    var moveExerciseSetCalled: Bool = false
    var removeExerciseSetCalled: Bool = false
    var appendExerciseSetCalled: Bool = false
    var startExerciseTimerCalled: Bool = false
    var startRestTimerCalled: Bool = false
    var stopExerciseCalled: Bool = false
    
    func isExerciseSetFinished(at index: Int) -> Bool {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        isExerciseSetFinishedCalled = true
        
        // ExerciseSet이 끝났는지 여부를 판단하여 반환합니다.
        // 여기에서는 항상 false를 반환하도록 설정되어 있습니다.
        return false
    }
    
    func exerciseSet(at index: Int) -> ExerciseSet {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        exerciseSetCalled = true
        
        // repetitionCount와 weight가 0인 ExerciseSet 인스턴스를 생성하여 반환합니다.
        return ExerciseSet(repetitionCount: 0, weight: 0)
    }
    
    func toggleExerciseSetFinished(at index: Int) {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        toggleExerciseSetFinishedCalled = true
        
        // ExerciseSet의 완료 여부를 토글합니다.
        // 여기에서는 실제로 토글되는 동작은 구현되어 있지 않습니다.
    }
    
    func moveExerciseSet(from source: Int, to destination: Int) {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        moveExerciseSetCalled = true
        
        // source 인덱스에서 destination 인덱스로 ExerciseSet을 이동시킵니다.
        // 여기에서는 실제로 이동되는 동작은 구현되어 있지 않습니다.
    }
    
    func removeExerciseSet(at index: Int) {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        removeExerciseSetCalled = true
        
        // 주어진 인덱스에 해당하는 ExerciseSet을 제거합니다.
        // 여기에서는 실제로 제거되는 동작은 구현되어 있지 않습니다.
    }
    
    func appendExerciseSet() {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        appendExerciseSetCalled = true
        
        // 새로운 ExerciseSet을 추가합니다.
        // 여기에서는 실제로 추가되는 동작은 구현되어 있지 않습니다.
    }
    
    func startExerciseTimer() {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        startExerciseTimerCalled = true
        
        // 운동 타이머를 시작합니다.
        // 여기에서는 실제로 타이머가 시작되는 동작은 구현되어 있지 않습니다.
    }
    
    func startRestTimer() {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        startRestTimerCalled = true
        
        // 휴식 타이머를 시작합니다.
        // 여기에서는 실제로 타이머가 시작되는 동작은 구현되어 있지 않습니다.
    }
    
    func stopExercise() {
        // 해당 메서드가 호출되었음을 나타내는 플래그 변수를 설정합니다.
        stopExerciseCalled = true
        
        // 운동을 중지합니다.
        // 여기에서는 실제로 운동이 중지되는 동작은 구현되어 있지 않습니다.
    }
}
