//
//  WorkoutLogViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/26.
//

import UIKit
import FSCalendar
import RealmSwift
import RxSwift

protocol ReloadDelegate: AnyObject {
    func reloadData()
}

final class WorkoutLogViewController: UIViewController {
    private let workoutLogView = WorkoutLogView()
    private let titleTimerView = TitleTimerView()
    private let timer = TimerManager.shared
    private var workoutLog: WorkoutLog?
    private let realm: Realm = RealmManager.shared.realm
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureRealm()
        registerDelegate()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
        reloadCalendar()
        fetchTimerStatus()
    }
    
    private func setupBindings() {
        Observable
            .combineLatest(timer.totalExerciseTimePublisher, timer.totalRestTimePublisher)
            .map { $0 + $1 }
            .subscribe { [weak self] in
                self?.titleTimerView.fetchTitleTime($0)
            }
            .disposed(by: disposeBag)
    }
    private func configureView() {
        view.addSubview(workoutLogView)
        workoutLogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fetchTimerStatus()
    }
    
    func fetchTimerStatus() {
        navigationItem.titleView = nil
        switch timer.timerStatus {
        case .exercise:
            titleTimerView.fetchColor(.exercise)
            navigationItem.titleView = titleTimerView
        case .rest:
            titleTimerView.fetchColor(.rest)
            navigationItem.titleView = titleTimerView
        case .none:
            titleTimerView.fetchColor(.none)
            navigationItem.titleView = nil
            break
        }
    }
    private func registerDelegate() {
        workoutLogView.tableView.delegate = self
        workoutLogView.tableView.dataSource = self
        workoutLogView.calendar.delegate = self
        workoutLogView.calendar.dataSource = self
        workoutLogView.grabberView.delegate = self
    }
    
    private func configureRealm() {
        let primaryKey = DateFormatter.format(with: .primaryKey, from: workoutLogView.calendar.selectedDate!)
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: primaryKey)
        print(realm.configuration.fileURL)
    }
    
    private func reloadTableView() {
        workoutLogView.tableView.reloadData()
    }

    private func reloadCalendar() {
        workoutLogView.calendar.reloadData()
    }
}

extension WorkoutLogViewController: GrabberViewDelegate {
    
    func grabber(swipeGestureFor direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .up :
            self.workoutLogView.calendar.setScope(.week, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(K.Color.Grayscale.Background)
            }
        case .down:
            self.workoutLogView.calendar.setScope(.month, animated: true)
            UIView.transition(with: view, duration: 0.3) {
                self.view.backgroundColor(K.Color.Grayscale.SecondaryBackground)
            }
        default: break
        }
    }
    
    func grabberButtonTapped() {
        
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
        let headerDateString = DateFormatter.format(with: .headerDate, from: currentDate)
        workoutLogView.headerTitle.text(headerDateString)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let event = realm.object(ofType: WorkoutLog.self, forPrimaryKey: DateFormatter.format(with: .primaryKey, from: date))
        return event != nil ? 1 : 0
    }
    
    // 날짜를 선택했을 때 할일을 지정
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: DateFormatter.format(with: .primaryKey, from: date))
        let grabberString = DateFormatter.format(with: .grabberDate, from: date) + "workout".localized
        workoutLogView.grabberView.setTitle(grabberString)
        reloadTableView()
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
            cell.addButtonHandler = { [weak self] in
                guard let self else { return }
                let date = DateFormatter.format(with: .primaryKey, from: workoutLogView.calendar.selectedDate!)
                let exerciseSearchVC = ExerciseSearchViewController(date: date)
                exerciseSearchVC.reloadDelegate = self
                transition(viewController: exerciseSearchVC, style: .present)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workout = workoutLog?.workouts[indexPath.row]
        transition(viewController: ExerciseSetViewController(workout: workout), style: .pushNavigation)
    }
    
    func reloadData() {
        configureRealm()
        reloadTableView()
        reloadCalendar()
    }
}
