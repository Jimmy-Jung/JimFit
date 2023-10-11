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

final class ExerciseSetViewModel {
    private var workout: Workout
    private let realm = RealmManager.shared.realm
    private let timer = TimerManager.shared
    
    private let disposeBag = DisposeBag()
    var totalExerciseTime = PublishRelay<String>()
    var totalRestTime = PublishRelay<String>()
    var setExerciseTime = PublishRelay<String>()
    var setRestTime = PublishRelay<String>()
    var totalTime = PublishRelay<String>()
    
    var grabberTitle: String {
        return workout.exercise?.exerciseName.localized ?? ""
    }
    
    
    init(workout: Workout) {
        self.workout = workout
        let date = workout.OriginWorkoutLog.first?.workoutDate
        self.setupBindings()
    }
    
    private func setupBindings() {
        
        timer.totalExerciseTimePublisher
            .map { $0.formattedTime() }
            .bind(to: totalExerciseTime)
            .disposed(by: disposeBag)
        
        timer.totalRestTimePublisher
            .map { $0.formattedTime() }
            .bind(to: totalRestTime)
            .disposed(by: disposeBag)
        
        timer.setExerciseTimePublisher
            .map {$0.formattedTime()}
            .bind(to: setExerciseTime)
            .disposed(by: disposeBag)
        
        timer.setRestTimePublisher
            .map {$0.formattedTime()}
            .bind(to: setRestTime)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(timer.totalExerciseTimePublisher, timer.totalRestTimePublisher)
            .map { $0 + $1 }
            .map { $0.formattedTime() }
            .bind(to: totalTime)
            .disposed(by: disposeBag)
    }
}
