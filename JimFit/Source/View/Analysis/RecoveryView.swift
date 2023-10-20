//
//  RecoveryView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit

final class RecoveryView: UIView {
        
    private lazy var containerView = UIView()
    
    private lazy var imageStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fillEqually)
        .spacing(10)
        .addArrangedSubview(frontImageView)
        .addArrangedSubview(backImageView)
    
    let frontImageView = UIImageView()
        .image(UIImage(named: "mail_front"))
        .contentMode(.scaleAspectFit)
    
    let backImageView = UIImageView()
        .image(UIImage(named: "mail_back"))
        .contentMode(.scaleAspectFit)
    
    lazy var progressContainer = UIView()
        .backgroundColor(K.Color.Primary.Background)
        .cornerRadius(K.Size.cellRadius)
        .clipsToBounds(true)
        .addSubView(totalFatigueLabel)
        .addSubView(progressBar)
        .addSubView(progressLabel)
    
    private let totalFatigueLabel = UILabel()
        .text("total_fatigue".localized)
        .font(K.Font.CellHeader)
        .textColor(K.Color.Primary.Label)
    
    let progressBar: UIProgressView = UIProgressView().then {
        $0.trackTintColor = K.Color.Grayscale.Selected
        $0.progressTintColor = K.Color.Primary.Blue
        $0.progress = 0.5
    }
    
    let progressLabel = UILabel()
        .text("70%")
        .textColor(K.Color.Grayscale.Label)
        .font(K.Font.CellHeader)
    
    let separatorView = UIView()
        .backgroundColor(K.Color.Grayscale.Background)
    
    let titleLabel = UILabel()
        .text("muscle_fatigue".localized)
        .font(K.Font.Header1)
        .textAlignment(.left)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        configureCollectionView()
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
        
        addSubView(progressContainer)
        progressContainer.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        totalFatigueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        progressBar.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(totalFatigueLabel.snp.trailing).offset(16)
            make.height.equalTo(6)
        }
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(progressBar.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
        }
        
        addSubView(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(progressContainer.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(8)
        }
        
        addSubView(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        
        addSubView(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(140)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 60) / 2, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.register(RecoveryCollectionViewCell.self, forCellWithReuseIdentifier: RecoveryCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
