//
//  ExerciseSetView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit
import SnapKit

final class ExerciseSetView: UIView {
    let workoutTimer = TimerView(type: .workout)
    let restTimer = TimerView(type: .rest)
    lazy var timerStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .spacing(10)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(workoutTimer)
        .addArrangedSubview(restTimer)
    
    let grabberView = GrabberView()
    let tableView = UITableView()
    
    var grabberViewTopOffset: Constraint!
    
    let startWorkoutButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .baseBackgroundColor(K.Color.Primary.Blue)
        .titleWithFont(title: "start_set".localized, font: K.Font.Header2)
        .cornerRadius(16)
    
    let doneSetButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .baseBackgroundColor(K.Color.Primary.Green)
        .titleWithFont(title: "done_set".localized, font: K.Font.Header2)
        .cornerRadius(16)
    
    private lazy var buttonStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .spacing(8)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(startWorkoutButton)
        .addArrangedSubview(doneSetButton)
    
    private lazy var buttonStackViewBackgroundView: UIView = UIView()
        .backgroundColor(K.Color.Primary.Background)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(K.Color.Grayscale.SecondaryBackground)
        addSubView(timerStackView)
        timerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        addSubView(grabberView)
        grabberView.snp.makeConstraints { make in
            grabberViewTopOffset = make.top.equalTo(timerStackView.snp.bottom).offset(16).constraint
            make.horizontalEdges.equalToSuperview()
        }
        addSubView(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
        startWorkoutButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        doneSetButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        buttonStackViewBackgroundView.addSubView(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(50)
        }
        addSubView(buttonStackViewBackgroundView)
        buttonStackViewBackgroundView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(tableView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
