//
//  ImageBlender.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit
import RealmSwift

struct ImageBlender {
    let exerciseInfos: [ExerciseInfo]
    init(exerciseInfos: [ExerciseInfo]) {
        self.exerciseInfos = exerciseInfos
    }
//    /// 이미지를 가져오는 함수입니다.
//    func get() -> ([UIImage], [UIImage]) {
//        let workoutPeriods = (-3...0).map { Date().convert(to: .primaryKey, difference: $0) }
//        let realm = RealmManager.shared.oldRealm
//        let workouts = workoutPeriods.map { realm.object(ofType: WorkoutLog.self, forPrimaryKey: $0) }
//        let workoutIds = workouts.map { $0?.workouts.map { $0.workoutId }}
//        let workoutDates = workouts.map { $0?.workoutDate }
//        var frontImages = [UIImage]()
//        var backImages = [UIImage]()
//
//        exerciseInfos.forEach {
//            let date = $0.workoutDate
//        }
//        for (index, workoutId) in workoutIds.enumerated() {
//            if let exercise = realm.object(ofType: Exercise.self, forPrimaryKey: workoutId), let date = workoutDates[index] {
//                let (front, back) = getBlendedImage(exercise: exercise, alpha: hourPassedSince(dateString: date))
//                frontImages.append(front)
//                backImages.append(back)
//            }
//        }
//        return (frontImages, backImages)
//    }
    
    func getBlendedImage() -> (UIImage, UIImage) {
        var frontImage = [UIImage]()
        var backImage = [UIImage]()
        exerciseInfos.forEach {
            let (front, back) = blendImage(exerciseInfo: $0)
            frontImage.append(front)
            backImage.append(back)
        }
        let front = blendImagesWithDarken(images: frontImage, alpha: 1)
        let back = blendImagesWithDarken(images: backImage, alpha: 1)
        return (front, back)
    }
 
    private func blendImage(exerciseInfo: ExerciseInfo) -> (UIImage, UIImage) {
        let bodyParts = exerciseInfo.bodyParts
        let targetMuscles = exerciseInfo.targetMuscles
        let alpha = hourPassedSince(dateString: exerciseInfo.workoutDate)
        var frontImages = Set<UIImage>()
        var backImages = Set<UIImage>()
        bodyParts.forEach {
            if let image = UIImage(named: "mail_front_\($0)") {
                frontImages.insert(image)
            }
            if let image = UIImage(named: "mail_back_\($0)") {
                backImages.insert(image)
            }
        }
        targetMuscles.forEach {
            if let image = UIImage(named: "mail_front_\($0)") {
                frontImages.insert(image)
            }
            if let image = UIImage(named: "mail_back_\($0)") {
                backImages.insert(image)
            }
        }
        let frontImage = blendImagesWithDarken(images: Array(frontImages), alpha: alpha)
        let backImage = blendImagesWithDarken(images: Array(backImages), alpha: alpha)
        return (frontImage, backImage)
    }
    
//    func getBlendedImage(exercise: Exercise, alpha: CGFloat) -> (UIImage, UIImage) {
//        let bodyPart = exercise.bodyPart
//        let targetMuscle = exercise.targetMuscles
//        var frontImages = Set<UIImage>()
//        var backImages = Set<UIImage>()
//        bodyPart.forEach {
//            if let image = UIImage(named: "mail_front_\($0)") {
//                frontImages.insert(image)
//            }
//            if let image = UIImage(named: "mail_back_\($0)") {
//                backImages.insert(image)
//            }
//        }
//        targetMuscle.forEach {
//            if let image = UIImage(named: "mail_front_\($0)") {
//                frontImages.insert(image)
//            }
//            if let image = UIImage(named: "mail_back_\($0)") {
//                backImages.insert(image)
//            }
//        }
//        let frontImage = blendImagesWithDarken(images: Array(frontImages), alpha: alpha)
//        let backImage = blendImagesWithDarken(images: Array(backImages), alpha: alpha)
//        return (frontImage, backImage)
//    }
    
    private func hourPassedSince(dateString: String) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: dateString) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: date, to: Date())
        let hour = components.hour ?? 0
        return CGFloat(hour) / 48
    }
    
    /// 여러 이미지를 darken blend 모드로 합성하여 하나의 이미지로 반환합니다.
    ///
    /// - Parameters:
    ///   - images: 합성할 이미지 배열
    ///   - alpha: 각 이미지의 투명도 배열 (기본값: 1.0)
    /// - Returns: 합성된 이미지
    private func blendImagesWithDarken(images: [UIImage], alpha: CGFloat) -> UIImage {
        guard let firstImage = images.first else { return UIImage() }
        
        let imageSize = firstImage.size
        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let result = renderer.image { ctx in
            UIColor.clear.set()
            ctx.fill(rect)
            images.forEach {
                $0.draw(in: rect, blendMode: .darken, alpha: alpha)
            }
        }
        return result
    }
}
