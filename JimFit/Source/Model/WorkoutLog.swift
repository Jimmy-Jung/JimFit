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
    @Persisted var exerciseTime: TimeInterval
    @Persisted var restTime: TimeInterval
    @Persisted var completedTime: Date?
    @Persisted var workoutMemo: String
    @Persisted var workouts = List<Workout>()
    
    convenience init(workoutDate: String, exerciseTime: TimeInterval = 0, restTime: TimeInterval = 0, workoutMemo: String) {
        self.init()
        self.workoutDate = workoutDate
        self.exerciseTime = exerciseTime
        self.restTime = restTime
        self.workoutMemo = workoutMemo
    }
}

final class Workout: Object,Codable {
    @Persisted(primaryKey: true) var workoutId = ObjectId.generate()
    @Persisted var exerciseReference: String
    @Persisted var exerciseSets = List<ExerciseSet>()
    @Persisted(originProperty: "workouts") var OriginWorkoutLog: LinkingObjects<WorkoutLog>
    
    convenience init(exerciseReference: String) {
        self.init()
        self.exerciseReference = exerciseReference
        self.exerciseSets.append(ExerciseSet(repetitionCount: 0, weight: 0))
    }
    
    enum CodingKeys: String, CodingKey {
        case workoutId
        case exerciseReference
        case exerciseSets
    }
}

final class Exercise: Object, Codable {
    @Persisted(primaryKey: true) var reference: String
    @Persisted var exerciseName: String
    @Persisted var bodyPart: List<String>
    @Persisted var equipmentType: String
    @Persisted var targetMuscles: List<String>
    @Persisted var synergistMuscles: List<String>
    @Persisted var liked: Bool
    
    convenience init(bodyPart: List<String>, equipmentType: String, targetMuscles: List<String>, synergistMuscles: List<String>, reference: String, exerciseName: String, liked: Bool) {
        self.init()
        self.bodyPart = bodyPart
        self.equipmentType = equipmentType
        self.targetMuscles = targetMuscles
        self.synergistMuscles = synergistMuscles
        self.reference = reference
        self.exerciseName = exerciseName
        self.liked = liked
    }
}

final class ExerciseSet: Object, Codable {
    @Persisted var repetitionCount: Int
    @Persisted var weight: Int
    @Persisted var isFinished: Bool
    
    convenience init(repetitionCount: Int, weight: Int, isFinished: Bool = false) {
        self.init()
        self.repetitionCount = repetitionCount
        self.weight = weight
        self.isFinished = isFinished
    }
}
