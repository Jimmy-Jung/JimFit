//
//  RecoveryView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit

final class RecoveryView: UIView {
    
    let loadingProgressView = UIActivityIndicatorView(style: .large)
    
    private lazy var containerView = UIView()
    
    private lazy var imageStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fillEqually)
        .spacing(10)
        .addArrangedSubview(frontImageView)
        .addArrangedSubview(backImageView)
    
    let frontImageView = UIImageView()
        .image(UIImage(named: "mail_front_Adductor Magnus"))
        .contentMode(.scaleAspectFit)
    let backImageView = UIImageView()
        .image(UIImage(named: "mail_back_Forearms"))
        .contentMode(.scaleAspectFit)
    
    private let coolDownLabel = UILabel()
        .text("cool_down".localized)
        .font(K.Font.CellHeader)
        .textColor(K.Color.Primary.Label)
    
    let progressView: UIProgressView = UIProgressView().then {
        $0.trackTintColor = K.Color.Grayscale.SecondaryFill
        $0.progressTintColor = K.Color.Primary.Green
        $0.progress = 0
    }
    
    let progressLabel = UILabel()
        .text("70%")
        .textColor(K.Color.Grayscale.Label)
        .font(K.Font.CellBody)
    
    private lazy var progressStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(coolDownLabel)
        .addArrangedSubview(progressView)
        .addArrangedSubview(progressLabel)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    private func setupConstraints() {
        addSubView(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        containerView.addSubView(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubView(progressStackView)
        progressStackView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints { make in
            make.height.equalTo(6)
        }
        
        addSubView(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(progressStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(200)
            make.bottom.equalToSuperview()
        }
    }
    
//    func fetchData(front: UIImage, back: UIImage, progress: Float) {
//        frontImageView.image = front
//        backImageView.image = back
//        progressView.setProgress(progress, animated: true)
//        progressLabel.text = "\(Int(progress * 100))%"
//    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
