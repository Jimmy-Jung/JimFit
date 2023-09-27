//
//  GrabberView.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

final class GrabberView: UIView {
    private let backView = UIView()
        .backgroundColor(.systemBackground)
    
    private let grabberView = UIView()
        .cornerRadius(2)
        .backgroundColor(K.Color.Grayscale.border_Medium)
    
    private let titleLabel = UILabel()
        .font(K.Font.Header2)
        .textColor(K.Color.Primary.Label)
    
    private let menuButton = UIButton(configuration: .plain())
        .image(UIImage(systemName: "arrow.up.arrow.down")?
            .font(.systemFont(ofSize: 14, weight: .medium)))
        .baseForegroundColor(K.Color.Primary.Label)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addShadow()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ text: String) {
        titleLabel.text(text)
    }
    
    private func setupUI() {
        addSubView(backView)
        backView.layer.cornerRadius = 30
        backView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backView.addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
        }
        
        backView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(30)
        }
        
        backView.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(50)
        }
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -6)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.shadowColor = UIColor.label.cgColor
        }
    }
    
    
    
}
