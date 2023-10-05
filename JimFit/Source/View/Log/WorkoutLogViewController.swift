//
//  WorkoutLogViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/26.
//

import UIKit
import Then
import FSCalendar
import SnapKit
import JimmyKit
import RealmSwift

protocol ReloadDelegate: AnyObject {
    func reloadTableView()
}

final class WorkoutLogViewController: UIViewController {
    
    let calendar = FSCalendar()
    private lazy var headerTitle = UILabel()
        .text(headerDateFormatter.string(from: Date()))
        .font(K.Font.Header1)
    let grabberView = GrabberView()
    let tableView = UITableView()
    
    
    private let headerDateFormatter = DateFormatter().then {
        $0.dateFormat = "header_date_formatter".localized
    }
    
    private let grabberDateFormatter = DateFormatter().then {
        $0.dateFormat = "grabber_date_formatter".localized
    }
    
    private let pkDateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyyMMdd"
    }
    
    var workoutLog: WorkoutLog?
    let realm: Realm! = RealmManager.shared.realm
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureLayout()
        configureRealm()
        configureGrabberView()
        print(realm.configuration.fileURL)
    }

    private func configureGrabberView() {
        grabberView.delegate = self
        let grabberString = grabberDateFormatter.string(from: Date()) + "workout".localized
        grabberView.setTitle(grabberString)
    }
    
    private func configureUI() {
        view.backgroundColor(.secondarySystemGroupedBackground)
        configureCalendar()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WorkoutListTableViewCell.self, forCellReuseIdentifier: WorkoutListTableViewCell.identifier)
        tableView.register(AddButtonTableViewCell.self, forCellReuseIdentifier: AddButtonTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
    }
    
    private func configureLayout() {
        view.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
        
        calendar.addSubView(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        
        view.addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func configureCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
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
    
    private func configureRealm() {
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: pkDateFormatter.string(from: calendar.selectedDate!))
    }
}

extension WorkoutLogViewController: GrabberViewDelegate {
    
    func grabber(swipeGestureFor direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .up :
            self.calendar.setScope(.week, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(.secondarySystemBackground)
            }
            
        case .down:
            self.calendar.setScope(.month, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(.secondarySystemGroupedBackground)
            }
        default: break
        }
    }
    func grabberDidTappedButton() {
        
    }
    
    
}

extension WorkoutLogViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 주/월 단위 바뀔 때 애니메이션
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentDate = calendar.currentPage
        let headerDateString = headerDateFormatter.string(from: currentDate)
        headerTitle.text(headerDateString)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let event = realm.object(ofType: WorkoutLog.self, forPrimaryKey: pkDateFormatter.string(from: date))
        return event != nil ? 1 : 0
    }
    
    // 날짜를 선택했을 때 할일을 지정
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: pkDateFormatter.string(from: date))
        let grabberString = grabberDateFormatter.string(from: date) + "workout".localized
        grabberView.setTitle(grabberString)
        tableView.reloadData()
    }

    
}


extension WorkoutLogViewController: UITableViewDelegate, UITableViewDataSource, ReloadDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workoutLog?.workouts.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutListTableViewCell.identifier, for: indexPath) as! WorkoutListTableViewCell
            cell.workout = workoutLog?.workouts[indexPath.row]
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonTableViewCell.identifier, for: indexPath) as! AddButtonTableViewCell
            cell.primaryButtonSet(state: .addList)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let workout = workoutLog?.workouts[indexPath.row]
            transition(viewController: ExerciseSetViewController(workout: workout), style: .pushNavigation)
        } else {
            let date = pkDateFormatter.string(from: calendar.selectedDate!)
            let exerciseSearchVC = ExerciseSearchViewController(date: date)
            exerciseSearchVC.reloadDelegate = self
            transition(viewController: exerciseSearchVC, style: .present)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reloadTableView() {
        configureRealm()
        self.tableView.reloadData()
        self.calendar.reloadData()
    }
}
