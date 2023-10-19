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
    let imageBlender: ImageBlender
    let exerciseInfoManager = ExerciseInfoManager()
    var frontImagePublisher = PublishRelay<UIImage>()
    var backImagePublisher = PublishRelay<UIImage>()
    var loadingProgressStatePublisher = BehaviorRelay<Bool>(value: true)
    var disposeBag = DisposeBag()
    
    init() {
        let exerciseInfo = exerciseInfoManager.getExerciseInfoFromWorkoutLogs(period: .threeDays)
        imageBlender = ImageBlender(exerciseInfos: exerciseInfo)
    }
    
    func binding() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let (frontImage, backImage): (UIImage, UIImage) = imageBlender.getBlendedImage()
            Observable<UIImage>
                .just(frontImage)
                .bind(to: frontImagePublisher)
                .disposed(by: disposeBag)
            
            Observable<UIImage>
                .just(backImage)
                .bind(to: backImagePublisher)
                .disposed(by: disposeBag)
            
            Observable<Bool>
                .just(false)
                .bind(to: loadingProgressStatePublisher)
                .disposed(by: disposeBag)
        }
    }
}
