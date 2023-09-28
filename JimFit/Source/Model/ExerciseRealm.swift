//
//  ExerciseRealm.swift
//  GymVisual crawler
//
//  Created by 정준영 on 2023/09/22.
//

import Foundation
import RealmSwift

final class ExerciseRealm: Object {
    @Persisted var reference: String
    @Persisted var exerciseName: String
    @Persisted var bodyPart: List<String>
    @Persisted var equipmentType: String
    @Persisted var exerciseType: String
    @Persisted var targetMuscles: List<String>
    @Persisted var synergistMuscles: List<String>
    
    
    convenience init(bodyPart: List<String>, equipmentType: String, exerciseType: String, targetMuscles: List<String>, synergistMuscles: List<String>, reference: String, exerciseName: String) {
        self.init()
        self.bodyPart = bodyPart
        self.equipmentType = equipmentType
        self.exerciseType = exerciseType
        self.targetMuscles = targetMuscles
        self.synergistMuscles = synergistMuscles
        self.reference = reference
        self.exerciseName = exerciseName
    }
}
