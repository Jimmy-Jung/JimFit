//
//  RecoveryViewModel.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit
import RealmSwift
import RxSwift
import RxRelay

final class RecoveryViewModel {
    private let exerciseInfoManager = ExerciseInfoManager()
    var frontImagePublisher = PublishRelay<UIImage>()
    var backImagePublisher = PublishRelay<UIImage>()
    var targetImagesPublisher = PublishRelay<[TargetInfo]>()
    var fatiguePublisher = PublishRelay<Float>()
    var disposeBag = DisposeBag()
    
    init() {
        binding()
    }
    
    func binding() {
        let exerciseInfo = exerciseInfoManager.getExerciseInfoFromWorkoutLogs(period: .threeDays)
        let imageBlender = ImageBlender(exerciseInfos: exerciseInfo)
        let (frontImage, backImage): (UIImage, UIImage) = imageBlender.getBlendedImage()
        let targetInfos = imageBlender.getTargetImages()
        let fatigue = targetInfos.map { Float($0.alpha) }.reduce(0, +) / Float(targetInfos.count)
        self.frontImagePublisher.accept(frontImage)
        self.backImagePublisher.accept(backImage)
        self.targetImagesPublisher.accept(targetInfos)
        self.fatiguePublisher.accept(fatigue)
    }
}
