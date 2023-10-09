//
//  TimerView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit

final class TimerView: UIView {
    
    enum TimerType {
        case workout
        case rest
    }
    
    private var timerType: TimerType!
    
    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: .clear, width: 0)
        .backgroundColor(.secondarySystemFill)
 
    private let totalTimeTextLabel = UILabel()
        .font(.systemFont(ofSize: 16, weight: .bold))
        .textColor(K.Color.Grayscale.Label)
        .textAlignment(.left)
    
    private let totalTimeLabel = UILabel()
        .font(.systemFont(ofSize: 16, weight: .bold))
        .textColor(K.Color.Grayscale.Label)
        .textAlignment(.right)
        .text("0:00:00:00")
    
    private let setTimeTextLabel = UILabel()
        .font(.systemFont(ofSize: 28, weight: .heavy))
        .textColor(K.Color.Grayscale.Label)
        .textAlignment(.left)
    
    private let setTimeLabel = UILabel()
        .font(.systemFont(ofSize: 28, weight: .bold))
        .textColor(K.Color.Grayscale.Label)
        .textAlignment(.right)
        .text("0:00:00:00")
    
    private lazy var totalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(totalTimeTextLabel)
        .addArrangedSubview(totalTimeLabel)
    
    private lazy var setStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(setTimeTextLabel)
        .addArrangedSubview(setTimeLabel)
    
    private lazy var verticalStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(totalStackView)
        .addArrangedSubview(setStackView)
    
    func fetchTotalTime(_ timeInterval: TimeInterval) {
        totalTimeLabel.text(timeInterval.formattedTime())
    }
    
    func fetchSetTime(_ timeInterval: TimeInterval) {
        setTimeLabel.text(timeInterval.formattedTime())
    }
    
    func activateColor() {
        let tintColor = timerType == .workout ? K.Color.Primary.Blue : K.Color.Primary.Green
        borderView
            .setBorder(color: tintColor, width: K.Size.border_Thin)
            .backgroundColor(.clear)
        totalTimeTextLabel.textColor(K.Color.Primary.Label)
        totalTimeLabel.textColor(K.Color.Primary.Label)
        setTimeTextLabel.textColor(tintColor)
        setTimeLabel.textColor(K.Color.Primary.Label)
    }
    
    func deactivateColor() {
        borderView
            .setBorder(color: .clear, width: 0)
            .backgroundColor(.secondarySystemFill)
        totalTimeTextLabel.textColor(K.Color.Grayscale.Label)
        totalTimeLabel.textColor(K.Color.Grayscale.Label)
        setTimeTextLabel.textColor(K.Color.Grayscale.Label)
        setTimeLabel.textColor(K.Color.Grayscale.Label)
    }
    
    convenience init(type: TimerType) {
        self.init()
        switch type {
        case .workout:
            totalTimeTextLabel.text("total_workout_time".localized)
            setTimeTextLabel.text("set_workout_time".localized)
            timerType = .workout
        case .rest:
            totalTimeTextLabel.text("total_rest_time".localized)
            setTimeTextLabel.text("set_rest_time".localized)
            timerType = .rest
        }
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubView(borderView)
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        borderView.addSubView(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
