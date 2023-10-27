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
import SwiftRater

protocol ReloadDelegate: AnyObject {
    func reloadData()
}

final class WorkoutLogViewController: UIViewController {
    private let workoutLogView = WorkoutLogView()
    private let titleTimerView = TitleTimerView()
    private let timer = TimerManager.shared
    private var timerStatus: TimerManager.TimerStatus = .stop
    private var workoutLog: WorkoutLog?
    private let realm: Realm = RealmManager.shared.oldRealm
    private let disposeBag = DisposeBag()
    private lazy var stopButton: UIBarButtonItem? = UIBarButtonItem(image: K.Image.Stop, primaryAction: stop)
    private lazy var stop: UIAction = UIAction { [weak self] _ in
        guard let self else { return }
        HapticsManager.shared.vibrateForNotification(style: .error)
        showAlert(
            title: "done_workout_title".localized,
            message: "done_workout_message".localized,
            preferredStyle: .alert,
            doneHandler: { _ in
                HapticsManager.shared.vibrateForSelection()
            self.timer.stopTimer()
            self.reloadCalendar()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if realm.object(ofType: Exercise.self, forPrimaryKey: "0001") == nil {
            showAlert(title: "problem_with_data".localized, message: "problem_with_data_message".localized, preferredStyle: .alert, doneTitle: "ok".localized, cancelTitle: "cancel".localized, doneHandler: { [weak self] _ in
                self?.transition(viewController: BackupViewController(), style: .pushNavigation)
            })
        }
        setNavigationBarAppearance()
        configureView()
        configureRealm()
        registerDelegate()
        setupBindings()
        SwiftRater.check()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
        fetchTimerStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadCalendar()
    }
    
    private func setupBindings() {
        timer.totalTimePublisher
            .map { $0.formattedTime() }
            .subscribe { [weak self] in
                self?.titleTimerView.title.text($0)
            }
            .disposed(by: disposeBag)
        
        timer.timerStatusPublisher
            .subscribe (onNext: { [weak self] in
                self?.timerStatus = $0
                self?.fetchTimerStatus()
            })
            .disposed(by: disposeBag)
    }
    private func configureView() {
        view.addSubview(workoutLogView)
        workoutLogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchTimerStatus() {
        navigationItem.titleView = nil
        switch timerStatus {
        case .exercise:
            titleTimerView.fetchColor(.exercise)
            navigationItem.titleView = titleTimerView
            titleTimerView.startBlinkingAnimation()
            navigationItem.rightBarButtonItem = stopButton
            stopButton?.tintColor = K.Color.Primary.Red
        case .rest:
            titleTimerView.fetchColor(.rest)
            navigationItem.titleView = titleTimerView
            titleTimerView.startBlinkingAnimation()
            navigationItem.rightBarButtonItem = stopButton
            stopButton?.tintColor = K.Color.Primary.Red
        case .stop:
            titleTimerView.fetchColor(.stop)
            navigationItem.titleView = nil
            navigationItem.rightBarButtonItem = nil
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
        let primaryKey = workoutLogView.calendar.selectedDate!.convert(to: .primaryKey)
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: primaryKey)
        #if DEBUG
        print(realm.configuration.fileURL)
        #endif
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
        HapticsManager.shared.vibrateForInteraction(style: .heavy)
        let shouldBeEdited = !workoutLogView.tableView.isEditing
        workoutLogView.tableView.setEditing(shouldBeEdited, animated: true)
        if !shouldBeEdited {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.workoutLogView.tableView.reloadData()
            }
        }
        workoutLogView.grabberView.isMenuButtonSelected = shouldBeEdited
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
        let headerDateString = currentDate.convert(to: .headerDate)
        workoutLogView.headerTitle.text(headerDateString)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let event = realm.object(ofType: WorkoutLog.self, forPrimaryKey: date.convert(to: .primaryKey))
        return event != nil ? 1 : 0
    }
    
    // 날짜를 선택했을 때 할일을 지정
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        workoutLog = realm.object(ofType: WorkoutLog.self, forPrimaryKey: date.convert(to: .primaryKey))
        let grabberString = date.convert(to: .grabberDate) + "workout".localized
        workoutLogView.grabberView.setTitle(grabberString)
        reloadTableView()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let recordingDay = timer.recordingDay, date.convert(to: .primaryKey) == recordingDay {
            return [K.Color.Primary.Blue]
        }
        return nil
    }
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        HapticsManager.shared.vibrateForSelection()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutLogTableViewCell.identifier, for: indexPath) as! WorkoutLogTableViewCell
            cell.workout = workoutLog?.workouts[indexPath.row]
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonTableViewCell.identifier, for: indexPath) as! AddButtonTableViewCell
            cell.primaryButtonSet(state: .addList)
            cell.selectionStyle = .none
            cell.addButtonHandler = { [weak self] in
                guard let self else { return }
                let date = workoutLogView.calendar.selectedDate!.convert(to: .primaryKey)
                let exerciseSearchVC = ExerciseSearchViewController(date: date)
                exerciseSearchVC.reloadDelegate = self
                transition(viewController: exerciseSearchVC, style: .present)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        guard let workout = workoutLog?.workouts[indexPath.row] else { return }
        let exerciseSetViewController = ExerciseSetViewController(viewModel: ExerciseSetViewModel(workout: workout))
        exerciseSetViewController.title = workoutLogView.calendar.selectedDate?.convert(to: .grabberDate)
        transition(viewController: exerciseSetViewController, style: .pushNavigation)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            workoutLog?.workouts.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        if workoutLog?.workouts.count == 1 {
            HapticsManager.shared.vibrateForNotification(style: .error)
            showAlert(
                title: "delete_workout_log".localized,
                message: "delete_workout_log_message".localized,
                preferredStyle: .alert,
                doneTitle: "ok".localized,
                cancelTitle: "cancel".localized,
                doneHandler: { [weak self] _ in
                    guard let self else { return }
                    try! realm.write {
                        self.workoutLog?.workouts.remove(at: indexPath.row)
                    }
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        tableView.reloadData()
                        try! self.realm.write {
                            guard let workoutLog = self.workoutLog else { return }
                            self.realm.delete(workoutLog)
                            self.reloadCalendar()
                            self.workoutLog = nil
                            self.timer.workoutLog = nil
                            self.timer.stopTimer()
                        }
                    }
                }
            )
        } else {
            try! realm.write {
                workoutLog?.workouts.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // 0번 섹션의 셀만 이동 가능하도록 설정
        if proposedDestinationIndexPath.section != 0 {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isUserInteractionEnabled = false
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
            cell.isUserInteractionEnabled = true
        }
    }
    
    func reloadData() {
        configureRealm()
        reloadTableView()
        reloadCalendar()
    }
}
