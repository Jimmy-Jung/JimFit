//
//  TitleTimerView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import UIKit

final class TitleTimerView: UIView {
    
    private let indicatorView = UIView()
        .cornerRadius(3)
        .clipsToBounds(true)
    
    private let title = UILabel()
        .font(K.Font.SubHeader)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(6)
        }
        
        addSubView(title)
        title.snp.makeConstraints { make in
            make.leading.equalTo(indicatorView.snp.trailing).offset(8)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        startBlinkingAnimation()
    }
    
    func fetchTitleTime(_ timeInterval: TimeInterval) {
        title.text(timeInterval.formattedTime())
    }
    
    func fetchColor(_ timerStatus: TimerManager.TimerStatus) {
        switch timerStatus {
        case .exercise:
            indicatorView.backgroundColor(K.Color.Primary.Blue)
            self.isHidden(false)
        case .rest:
            indicatorView.backgroundColor(K.Color.Primary.Green)
            self.isHidden(false)
        case .none:
            indicatorView.backgroundColor(.clear)
            self.isHidden(true)
        }
    }
    
    private func startBlinkingAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 1.0
            animation.autoreverses = true
            animation.repeatCount = .infinity
            indicatorView.layer.add(animation, forKey: "blinkingAnimation")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
