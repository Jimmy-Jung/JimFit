//
//  LoadingViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/16.
//

import UIKit

class LoadingViewController: UIViewController {
    private var imageArray: [UIImage] = []
    private var imageView: UIImageView!
    private var imageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.systemBackground)
        setupImages()
        setupImageView()
        startImageTransition()
    }

    private func setupImages() {
        for i in 1...5 {
            if let image = UIImage(named: "\(i)") {
                imageArray.append(image)
            }
        }
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageArray[imageIndex]
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
    }

    private func startImageTransition() {
        let transitionDuration: TimeInterval = 0.6

        Timer.scheduledTimer(withTimeInterval: transitionDuration, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            self.imageIndex = (self.imageIndex + 1) % self.imageArray.count
            UIView.transition(with: self.imageView, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                self.imageView.image = self.imageArray[self.imageIndex]
            }, completion: nil)
            if UM.finishedLaunch {
                self.dismiss(animated: true)
            }
        }
    }
}
