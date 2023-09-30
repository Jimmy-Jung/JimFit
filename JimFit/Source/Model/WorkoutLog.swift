//
//  WorkoutLog.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/30.
//

import Foundation
import RealmSwift

final class WorkoutLog: Object {
    @Persisted(primaryKey: true) var workoutDate: String
    @Persisted var workoutMemo: String
    @Persisted var workouts = List<Workout>()
    
    convenience init(workoutDate: String, workoutMemo: String) {
        self.init()
        self.workoutDate = workoutDate
        self.workoutMemo = workoutMemo
    }
}

final class Workout: Object {
    @Persisted(primaryKey: true) var workoutId = ObjectId.generate()
    @Persisted var exercise: Exercise?
    @Persisted var exerciseTime: Int
    @Persisted var restTime: Int
    @Persisted var exerciseSets = List<ExerciseSet>()
    
    convenience init(exercise: Exercise?, exerciseTime: Int = 0, restTime: Int = 0) {
        self.init()
        self.exercise = exercise
        self.exerciseTime = exerciseTime
        self.restTime = restTime
        self.exerciseSets.append(objectsIn: [ExerciseSet(setNumber: 1), ExerciseSet(setNumber: 2), ExerciseSet(setNumber: 3), ExerciseSet(setNumber: 4)])
    }
}

final class Exercise: Object {
    @Persisted var reference: String
    @Persisted var exerciseName: String
    @Persisted var bodyPart: List<String>
    @Persisted var equipmentType: String
    @Persisted var exerciseType: String
    @Persisted var targetMuscles: List<String>
    @Persisted var synergistMuscles: List<String>
    @Persisted var liked: Bool
    
    convenience init(bodyPart: List<String>, equipmentType: String, exerciseType: String, targetMuscles: List<String>, synergistMuscles: List<String>, reference: String, exerciseName: String, liked: Bool) {
        self.init()
        self.bodyPart = bodyPart
        self.equipmentType = equipmentType
        self.exerciseType = exerciseType
        self.targetMuscles = targetMuscles
        self.synergistMuscles = synergistMuscles
        self.reference = reference
        self.exerciseName = exerciseName
        self.liked = liked
    }
}

final class ExerciseSet: Object {
    @Persisted var setNumber: Int
    @Persisted var repetitionCount: Int
    @Persisted var weight: Double
    @Persisted var isFinished: Bool
    
    convenience init(setNumber: Int, repetitionCount: Int = 12, weight: Double = 45, isFinished: Bool = false) {
        self.init()
        self.setNumber = setNumber
        self.repetitionCount = repetitionCount
        self.weight = weight
        self.isFinished = isFinished
    }
}
