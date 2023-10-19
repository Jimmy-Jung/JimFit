//
//  ImageBlender.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit
import RealmSwift

struct ImageBlender {
    var exerciseInfos: [ExerciseInfo]
    init(exerciseInfos: [ExerciseInfo]) {
        self.exerciseInfos = exerciseInfos
    }
    
    func getBlendedImage() -> (UIImage, UIImage) {
        dump(exerciseInfos)
        var frontImage = [UIImage(named: "mail_front")!]
        var backImage = [UIImage(named: "mail_back")!]
        exerciseInfos.forEach {
            print("count")
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
        let calendar = Calendar.current
        let now = Date()
        let previousDay = calendar.startOfDay(for: date)
        let difference = calendar.dateComponents([.hour], from: previousDay, to: now)
        let hour = difference.hour! > 48 ? 48 : difference.hour!
        let alpha = CGFloat(48 - hour) / 48
        return alpha > 1 ? 1 : alpha
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
