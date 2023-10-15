//
//  JSONExercise.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/15.
//

import Foundation

struct JSONExercises: Codable {
    let exercises: [JSONExercise]
}

// MARK: - Exercise
struct JSONExercise: Codable {
    let bodyPart: [String]?
    let exerciseName: String
    let equipmentType: String
    let liked: Bool
    let reference: String
    let targetMuscles: [String]
    let synergistMuscles: [String]?
}
