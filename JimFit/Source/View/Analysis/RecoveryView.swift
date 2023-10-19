//
//  RecoveryView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit

final class RecoveryView: UIView {
    
    lazy var containerView = UIView()
        .addSubView(imageStackView)
    
    lazy var imageStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fillEqually)
        .spacing(10)
        .addArrangedSubview(frontImageView)
        .addArrangedSubview(backImageView)
    
    let frontImageView = UIImageView()
    let backImageView = UIImageView()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    func setupUI() {
        frontImageView.image = UIImage(named: "front")
        backImageView.image = UIImage(named: "back")
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
