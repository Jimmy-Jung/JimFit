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
        .font(K.Font.Header)
    let grabberView = GrabberView()
    let tableView = UITableView()
    
    private let headerDateFormatter = DateFormatter().then {
      $0.dateFormat = "YYYY년 MM월"
      $0.locale = Locale(identifier: "ko_kr")
//      $0.timeZone = TimeZone(identifier: "KST")
    }
    
    var events: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        title = "운동 기록"
        view.backgroundColor(.systemBackground)
        configureCalendar()
        configureTableView()
        view.addSubview(calendarView)
        view.addSubview(grabberView)
        view.addSubview(tableView)
        calendarView.addSubView(headerTitle)
        swipeGesture()
        
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TodoListTableViewCell.self, forCellReuseIdentifier: TodoListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
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
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
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
        case .down:
            self.calendarView.setScope(.month, animated: true)
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
        headerTitle.text(headerDateFormatter.string(from: currentDate))
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return self.events.filter { $0 == date }.count
    }
    
    // 날짜를 선택했을 때 할일을 지정
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    }

    
}


extension ExerciseLogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListTableViewCell.identifier, for: indexPath) as! TodoListTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    
    
}
