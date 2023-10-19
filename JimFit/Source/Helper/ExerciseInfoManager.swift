//
//  ExerciseInfoManager.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import Foundation

struct ExerciseInfo {
    var workoutDate: String
    var bodyParts: [String]
    var targetMuscles: [String]
}

struct ExerciseInfoManager {
    enum Period: Int {
        case threeDays = -3
        case week = -7
        case month = -30
        case threeMonth = -90
        case sixMonth = -180
        case year = -365
    }
    
    func getExerciseInfoFromWorkoutLogs(period: Period) -> [ExerciseInfo] {
        let workoutPeriods = (period.rawValue...0).map { Date().convert(to: .primaryKey, difference: $0) }
        let realm = RealmManager.shared.oldRealm
        let workoutLogs = workoutPeriods.compactMap { realm.object(ofType: WorkoutLog.self, forPrimaryKey: $0) }

        var exerciseInfos: [ExerciseInfo] = []

        for workoutLog in workoutLogs {
            let workoutDate = workoutLog.workoutDate

            for workout in workoutLog.workouts {
                let exercise = realm.object(ofType: Exercise.self, forPrimaryKey: workout.exerciseReference)

                var bodyParts: [String] = []
                var targetMuscles: [String] = []

                if let exerciseBodyParts = exercise?.bodyPart {
                    bodyParts.append(contentsOf: exerciseBodyParts)
                }

                if let exerciseTargetMuscles = exercise?.targetMuscles {
                    targetMuscles.append(contentsOf: exerciseTargetMuscles)
                }

                let exerciseInfo = ExerciseInfo(workoutDate: workoutDate, bodyParts: bodyParts, targetMuscles: targetMuscles)
                exerciseInfos.append(exerciseInfo)
            }
        }

        return exerciseInfos
    }
    
}
