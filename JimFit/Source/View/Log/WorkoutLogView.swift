//
//  WorkoutLogView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/09.
//

import UIKit
import Then
import FSCalendar
import SnapKit
import JimmyKit

final class WorkoutLogView: UIView {
    
    let headerTitle = UILabel()
        .text(Date().convert(to: .headerDate))
        .font(K.Font.Header1)
    let calendar = FSCalendar()
    let grabberView = GrabberView()
    let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(K.Color.Grayscale.SecondaryBackground)
        configureLayout()
        configureCalendar()
        configureTableView()
        configureGrabberView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureGrabberView() {
        let grabberString = Date().convert(to: .grabberDate) + "workout".localized
        grabberView.setTitle(grabberString)
    }
    
    private func configureLayout() {
        addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
        
        calendar.addSubView(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        
        addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func configureCalendar() {
        calendar.locale = Locale(identifier: "locale_identifier".localized)
        calendar.appearance.headerTitleColor = .clear // 기본 헤더 타이틀 제거
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.placeholderType = .fillHeadTail
        calendar.appearance.todayColor = K.Color.Grayscale.Tint
        calendar.appearance.selectionColor = K.Color.Primary.Orange
        calendar.appearance.weekdayTextColor = K.Color.Grayscale.Label
        calendar.appearance.weekdayFont = K.Font.SubHeader
        calendar.appearance.titleDefaultColor = K.Color.Primary.Label
        calendar.appearance.titleWeekendColor = K.Color.Primary.Blue
        calendar.appearance.titleFont = K.Font.Body1
        calendar.appearance.eventDefaultColor = K.Color.Primary.Orange
        calendar.appearance.eventSelectionColor = K.Color.Primary.Orange
        calendar.select(Date(), scrollToDate: true)
    }
    
    private func configureTableView() {
        tableView.register(WorkoutListTableViewCell.self, forCellReuseIdentifier: WorkoutListTableViewCell.identifier)
        tableView.register(AddButtonTableViewCell.self, forCellReuseIdentifier: AddButtonTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
    }
}
