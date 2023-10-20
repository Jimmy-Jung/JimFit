//
//  ImageBlender.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit
import RealmSwift

struct TargetInfo: Hashable {
    let targetName: String
    let targetImage: UIImage
    let alpha: Float
}

struct ImageBlender {
    var exerciseInfos: [ExerciseInfo]
    init(exerciseInfos: [ExerciseInfo]) {
        self.exerciseInfos = exerciseInfos
    }
    
    func getTargetImages() -> [TargetInfo] {
        var targetImages = [TargetInfo]()
        for exerciseInfo in exerciseInfos {
            let targetImage = getTargetImage(exerciseInfo: exerciseInfo)
            for newTargetImage in targetImage {
                if let existingIndex = targetImages.firstIndex(where: { $0.targetName == newTargetImage.targetName && $0.alpha <= newTargetImage.alpha }) {
                    targetImages.remove(at: existingIndex)
                }
                if newTargetImage.alpha != 0 {
                    targetImages.append(newTargetImage)
                }
            }
        }
        return targetImages
    }
    
    private func getTargetImage(exerciseInfo: ExerciseInfo) -> [TargetInfo] {
        let alpha = hourPassedSince(date: exerciseInfo.completedTime)
        let bodyParts = exerciseInfo.bodyParts
        let targetMuscles = exerciseInfo.targetMuscles
        var targets = Set<TargetInfo>()
        bodyParts.forEach {
            if let image = UIImage(named: "mail_target_\($0)") {
                targets.insert(.init(targetName: $0, targetImage: image, alpha: Float(alpha)))
            }
        }
        targetMuscles.forEach {
            if let image = UIImage(named: "mail_target_\($0)") {
                targets.insert(.init(targetName: $0, targetImage: image, alpha: Float(alpha)))
            }
        }
        return Array(targets)
    }
    
    func getBlendedImage() -> (UIImage, UIImage) {
        var frontImage = [UIImage(named: "mail_front")!]
        var backImage = [UIImage(named: "mail_back")!]
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
        let alpha = hourPassedSince(date: exerciseInfo.completedTime)
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
    
    private func hourPassedSince(date: Date) -> CGFloat {
        let recoveryPeriod = UM.recoveryPeriod
        let timeInterval = Date().timeIntervalSince(date)
        let hoursPassed = Int(timeInterval / 3600)
        let hour = hoursPassed > recoveryPeriod ? recoveryPeriod : hoursPassed
        let alpha = CGFloat(recoveryPeriod - hour) / CGFloat(recoveryPeriod)
        return alpha
    }
    
    /// 여러 이미지를 darken blend 모드로 합성하여 하나의 이미지로 반환합니다.
    ///
    /// - Parameters:
    ///   - images: 합성할 이미지 배열
    ///   - alpha: 이미지의 투명도
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
