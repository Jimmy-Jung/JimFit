//
//  GrabberView.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

protocol GrabberViewDelegate: AnyObject {
    func grabber(configureTitle label: UILabel)
    func grabber(swipeGestureFor direction: UISwipeGestureRecognizer.Direction)
    func grabberDidTappedButton()
}

extension GrabberViewDelegate {
    func grabber(configureTitle label: UILabel) { }
}

final class GrabberView: UIView {
    private let backView = UIView()
        .backgroundColor(.systemBackground)
    
    private let grabberView = UIView()
        .cornerRadius(2)
        .backgroundColor(K.Color.Grayscale.border_Medium)
    
    private let titleLabel = UILabel()
        .font(K.Font.Header2)
        .textColor(K.Color.Primary.Label)
    
    private lazy var menuButton = UIButton(configuration: .plain())
        .image(UIImage(systemName: "arrow.up.arrow.down")?
            .font(.systemFont(ofSize: 14, weight: .medium)))
        .baseForegroundColor(K.Color.Primary.Label)
    
    weak var delegate: GrabberViewDelegate?
    
    func setTitle(_ title: String) {
        titleLabel.text(title)
    }
    
    func setImage(_ image: UIImage?) {
        menuButton.image(image)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addShadow()
        performDelegate()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func performDelegate() {
        delegate?.grabber(configureTitle: titleLabel)
        menuButton.addAction { [unowned self] in
                self.delegate?.grabberDidTappedButton()
            }
        let swipeUpForGrabber = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeUpForGrabber.direction = UISwipeGestureRecognizer.Direction.up
        let swipeDownForGrabber = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeDownForGrabber.direction = UISwipeGestureRecognizer.Direction.down
        backView.addGestureRecognizer(swipeUpForGrabber)
        backView.addGestureRecognizer(swipeDownForGrabber)
    }
    
    @objc func swipe(_ gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
            return
        }
        delegate?.grabber(swipeGestureFor: swipeGesture.direction)
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
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: -6)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.shadowColor = UIColor.darkGray.cgColor
        }
    }
}
