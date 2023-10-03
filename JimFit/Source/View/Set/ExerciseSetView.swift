//
//  ExerciseSetView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit

final class ExerciseSetView: UIView {
    private let workoutStopWatch = StopWatchView(type: .workout)
    private let restStopWatch = StopWatchView(type: .rest)
    private lazy var stopWatchStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .spacing(10)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(workoutStopWatch)
        .addArrangedSubview(restStopWatch)
    
    let grabberView = GrabberView()
    let tableView = UITableView()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView(stopWatchStackView)
        stopWatchStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        addSubView(grabberView)
        grabberView.snp.makeConstraints { make in
            make.top.equalTo(stopWatchStackView.snp.bottom).offset(18)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }
        addSubView(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        startWorkoutButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        doneSetButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        addSubView(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
