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
    let exerciseInfoManager = ExerciseInfoManager()
    var frontImagePublisher = PublishRelay<UIImage>()
    var backImagePublisher = PublishRelay<UIImage>()
    var loadingProgressStatePublisher = BehaviorRelay<Bool>(value: true)
    var disposeBag = DisposeBag()
    
    init() {
        
        binding()
    }
    
    func binding() {
        let exerciseInfo = exerciseInfoManager.getExerciseInfoFromWorkoutLogs(period: .threeDays)
        let imageBlender = ImageBlender(exerciseInfos: exerciseInfo)
        let (frontImage, backImage): (UIImage, UIImage) = imageBlender.getBlendedImage()
        self.frontImagePublisher.accept(frontImage)
        self.backImagePublisher.accept(backImage)
        self.loadingProgressStatePublisher.accept(false)
    }
}
