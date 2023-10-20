//
//  RecoveryCollectionViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/20.
//

import UIKit

final class RecoveryCollectionViewCell: UICollectionViewCell {
    var targetInfo: TargetInfo? {
        didSet {
            guard let targetInfo else { return }
            muscleImageView.image(targetInfo.targetImage)
            muscleNameLabel.text(targetInfo.targetName.localized)
            progressLabel.text(String(format: "%.0f%%", targetInfo.alpha * 100))
            progressBar.setProgress(targetInfo.alpha, animated: true)
        }
    }
    private let muscleImageView: UIImageView = UIImageView()
        .image(UIImage(named: "mail_target_Chest"))
        .contentMode(.scaleAspectFit)
        .backgroundColor(K.Color.Grayscale.Selected)
        .cornerRadius(8)
        .clipsToBounds(true)
    
    private let muscleNameLabel = UILabel()
        .text("Chest assdadsa")
        .numberOfLines(3)
        .textAlignment(.left)
        .textColor(K.Color.Primary.Label)
        .font(K.Font.CellHeader)
    
    private lazy var progressContentView: UIView = UIView()
        .addSubView(progressBar)
        .addSubView(progressLabel)
    
    private let progressBar: UIProgressView = UIProgressView().then {
        $0.trackTintColor = K.Color.Grayscale.Selected
        $0.progressTintColor = K.Color.Primary.Blue
        $0.progress = 1
    }
    
    private let progressLabel: UILabel = UILabel()
        .text("50%")
        .textAlignment(.center)
        .textColor(K.Color.Primary.Label)
        .font(K.Font.CellBody)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressBar.setProgress(1, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView
            .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
            .backgroundColor(K.Color.Primary.Background)
            .cornerRadius(K.Size.cellRadius)
        contentView.addSubview(muscleImageView)
        contentView.addSubview(muscleNameLabel)
        contentView.addSubview(progressContentView)
        
        muscleImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(50)
        }
        
        muscleNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(muscleImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(muscleImageView)
        }
        
        progressContentView.snp.makeConstraints { make in
            make.top.equalTo(muscleImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(20)
        }
        
        progressBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(6)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.leading.equalTo(progressBar.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
