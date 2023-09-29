//
//  ExerciseLogViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/26.
//

import UIKit
import Then
import FSCalendar
import SnapKit
import JimmyKit

final class ExerciseLogViewController: UIViewController {
    
    let calendarView = FSCalendar()
    private lazy var headerTitle = UILabel()
        .text(headerDateFormatter.string(from: Date()))
        .font(K.Font.Header1)
    let grabberView = GrabberView()
    let tableView = UITableView()
    
    private let headerDateFormatter = DateFormatter().then {
      $0.dateFormat = "YYYY년 MM월"
      $0.locale = Locale(identifier: "ko_kr")
//      $0.timeZone = TimeZone(identifier: "KST")
    }
    
    private let grabberDateFormatter = DateFormatter().then {
        $0.dateFormat = "MM월 dd일"
        $0.locale = Locale(identifier: "ko_kr")
    }
    
    var events: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .secondarySystemGroupedBackground
        configureUI()
        configureLayout()
        setEvents()
    }
    
    func setEvents() {
        let dfMatter = DateFormatter()
        dfMatter.locale = Locale(identifier: "ko_KR")
        dfMatter.dateFormat = "yyyy-MM-dd"
        
        // events
        let myFirstEvent = dfMatter.date(from: "2023-09-26")
        let mySecondEvent = dfMatter.date(from: "2023-09-27")
        let myThirdEvent = dfMatter.date(from: "2023-09-20")
        
        events = [myFirstEvent!,myFirstEvent!, mySecondEvent!, myThirdEvent!]

    }
    
    func configureUI() {
        view.backgroundColor(.secondarySystemGroupedBackground)
        configureCalendar()
        configureGrabberView()
        configureTableView()
        view.addSubview(calendarView)
        view.addSubview(grabberView)
        view.addSubview(tableView)
        calendarView.addSubView(headerTitle)
        swipeGesture()
        
        
    }
    
    func configureGrabberView() {
        let grabberString = grabberDateFormatter.string(from: Date()) + " 운동"
        grabberView.setTitle(grabberString)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoListTableViewCell.self, forCellReuseIdentifier: TodoListTableViewCell.identifier)
        tableView.register(AddButtonTableViewCell.self, forCellReuseIdentifier: AddButtonTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0
    }
    
    func configureLayout() {
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
        headerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        grabberView.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(64)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func configureCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerTitleColor = .clear // 기본 헤더 타이틀 제거
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.placeholderType = .fillHeadTail
        calendarView.appearance.todayColor = K.Color.Grayscale.Tint
        calendarView.appearance.selectionColor = K.Color.Primary.Orange
        
        calendarView.appearance.weekdayTextColor = K.Color.Grayscale.Label
        calendarView.appearance.weekdayFont = K.Font.SubHeader
        calendarView.appearance.titleDefaultColor = K.Color.Primary.Label
        calendarView.appearance.titleWeekendColor = K.Color.Primary.Blue
        
        calendarView.appearance.titleFont = K.Font.Body
        
        calendarView.appearance.eventDefaultColor = K.Color.Primary.Orange
        calendarView.appearance.eventSelectionColor = K.Color.Primary.Orange
        
    }
    
    func swipeGesture() {
        let swipeUpForGrabber = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        let swipeUpForCalendar = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeUpForGrabber.direction = UISwipeGestureRecognizer.Direction.up
        swipeUpForCalendar.direction = UISwipeGestureRecognizer.Direction.up
        grabberView.addGestureRecognizer(swipeUpForGrabber)
        calendarView.addGestureRecognizer(swipeUpForCalendar)
        let swipeDownForGrabber = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        let swipeDownForCalendar = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeDownForGrabber.direction = UISwipeGestureRecognizer.Direction.down
        swipeDownForCalendar.direction = UISwipeGestureRecognizer.Direction.down
        
        grabberView.addGestureRecognizer(swipeDownForGrabber)
        calendarView.addGestureRecognizer(swipeDownForCalendar)
    }
    
    @objc func swipe(_ gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else {
            return
        }
        switch swipeGesture.direction {
        case .up :
            self.calendarView.setScope(.week, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(.secondarySystemBackground)
            }
            
        case .down:
            self.calendarView.setScope(.month, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(.secondarySystemGroupedBackground)
            }
        default: break
        }
    }
    
    
}

extension ExerciseLogViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // 주/월 단위 바뀔 때 애니메이션
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarView.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentDate = calendar.currentPage
        let headerDateString = headerDateFormatter.string(from: currentDate)
        let grabberString = grabberDateFormatter.string(from: currentDate) + " 운동"
        headerTitle.text(headerDateString)
        grabberView.setTitle(grabberString)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return self.events.filter { $0 == date }.count
    }
    
    // 날짜를 선택했을 때 할일을 지정
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    }

    
}


extension ExerciseLogViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TodoListTableViewCell.identifier, for: indexPath) as! TodoListTableViewCell
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
        
        if indexPath.section == 1 {
            transition(viewController: ExerciseSearchViewController(), style: .present)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
}
