//
//  GrabberView.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

final class GrabberView: UIView {
    let backView = UIView()
        .backgroundColor(.systemBackground)
    private let grabberView = UIView()
        .cornerRadius(2)
        .backgroundColor(K.Color.Grayscale.border_Medium)
    
        private let titleLabel = UILabel()
        private let menuButton = UIButton()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            addSubView(backView)
            backView.layer.cornerRadius = 30
            backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backView.layer.masksToBounds = true
            backView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            // Setup grabber view
            backView.addSubview(grabberView)
            grabberView.snp.makeConstraints { make in
                make.width.equalTo(70)
                make.height.equalTo(4)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(8)
            }

            // Setup title label
            titleLabel.text = "Title"
            backView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(grabberView.snp.bottom).offset(12)
                make.leading.equalToSuperview().offset(16)
            }
            
            // Setup menu button
            menuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            backView.addSubview(menuButton)
            menuButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(16)
            }
            
            // Add shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0, height: -6)
            layer.shadowRadius = 4
            layer.masksToBounds = false
            
            
        }
    
    
    
}
