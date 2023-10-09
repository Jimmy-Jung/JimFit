//
//  ExerciseSetViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit
import RealmSwift
import RxSwift

final class ExerciseSetViewController: UIViewController {
    private lazy var exerciseSetView = ExerciseSetView()
    private let titleTimerView = TitleTimerView()
    var workout: Workout!
    let realm = RealmManager.shared.realm
    let timer = TimerManager.shared
    let disposeBag = DisposeBag()
    init(workout: Workout?) {
        super.init(nibName: nil, bundle: nil)
        self.workout = workout
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addButtonsAction()
        configureTableView()
        setupBindings()
    }
    
    private func setupBindings() {
        timer.totalExerciseTimePublisher
            .subscribe { [weak self] in
                self?.exerciseSetView.workoutTimer.fetchTotalTime($0)
            }
            .disposed(by: disposeBag)
        
        timer.totalRestTimePublisher
            .subscribe { [weak self] in
                self?.exerciseSetView.restTimer.fetchTotalTime($0)
            }
            .disposed(by: disposeBag)
        
        timer.setExerciseTimePublisher
            .subscribe { [weak self] in
                self?.exerciseSetView.workoutTimer.fetchSetTime($0)
            }
            .disposed(by: disposeBag)
        
        timer.setRestTimePublisher
            .subscribe { [weak self] in
                self?.exerciseSetView.restTimer.fetchSetTime($0)
            }
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(timer.totalExerciseTimePublisher, timer.totalRestTimePublisher)
            .map { $0 + $1 }
            .subscribe { [weak self] in
                self?.titleTimerView.fetchTitleTime($0)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor(K.Color.Grayscale.SecondaryBackground)
        view.addSubview(exerciseSetView)
        exerciseSetView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        exerciseSetView.grabberView.delegate = self
        exerciseSetView.grabberView.setTitle(workout.exercise?.exerciseName.localized ?? "")
        navigationItem.titleView = titleTimerView
        switch timer.timerStatus {
        case .exercise:
            exerciseSetView.workoutTimer.activateColor()
            titleTimerView.fetchColor(.exercise)
        case .rest:
            exerciseSetView.restTimer.activateColor()
            titleTimerView.fetchColor(.rest)
        case .none:
            break
        }
    }
    
    private func addButtonsAction() {
        exerciseSetView.startWorkoutButton.addAction { [weak self] in self?.startWorkoutButtonTapped() }
        exerciseSetView.doneSetButton.addAction { [weak self] in self?.doneSetButtonTapped() }
    }
    
    private func configureTableView() {
        exerciseSetView.tableView.dataSource = self
        exerciseSetView.tableView.delegate = self
        exerciseSetView.tableView.register(ExerciseSetTableViewCell.self, forCellReuseIdentifier: ExerciseSetTableViewCell.identifier)
        exerciseSetView.tableView.register(AddButtonTableViewCell.self, forCellReuseIdentifier: AddButtonTableViewCell.identifier)
        exerciseSetView.tableView.rowHeight = UITableView.automaticDimension
        exerciseSetView.tableView.separatorStyle = .none
    }
    
    private func startWorkoutButtonTapped() {
        timer.startExerciseTimer()
        
        UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut]) {
            self.exerciseSetView.workoutTimer.activateColor()
            self.exerciseSetView.restTimer.deactivateColor()
        }
        titleTimerView.fetchColor(.exercise)
    }
    private func doneSetButtonTapped() {
        timer.doneExercise()
        
        UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut]) {
            self.exerciseSetView.restTimer.activateColor()
            self.exerciseSetView.workoutTimer.deactivateColor()
        }
        titleTimerView.fetchColor(.rest)
        guard let set = workout.exerciseSets.first(where: { $0.isFinished == false })
        else {
            return
        }
        try! realm.write {
            set.isFinished = true
        }
        exerciseSetView.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ExerciseSetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? workout.exerciseSets.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetTableViewCell.identifier, for: indexPath) as! ExerciseSetTableViewCell
            cell.configureCell(with: workout.exerciseSets[indexPath.row], index: indexPath.row)
            cell.selectionStyle = .none
            cell.setButtonHandler = { [weak self] in
                guard let self else { return }
                if workout.exerciseSets[indexPath.row].isFinished {
                    let index = workout.exerciseSets.lastIndex { $0.isFinished }
                    try! realm.write {
                        self.workout.exerciseSets.move(from: indexPath.row, to: index ?? indexPath.row)
                    }
                    tableView.moveRow(at: indexPath, to: IndexPath(row: index ?? indexPath.row, section: 0))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        tableView.reloadData()
                    }
                }
            }
            cell.textFieldDidBeginEditingHandler = { [weak self] in
                self?.grabber(swipeGestureFor: .up)
            }
            cell.textFieldDidEndEditingHandler = { [weak self] in
                self?.grabber(swipeGestureFor: .down)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddButtonTableViewCell.identifier, for: indexPath) as! AddButtonTableViewCell
            cell.primaryButtonSet(state: .addSet)
            cell.selectionStyle = .none
            cell.addButtonHandler = { [weak self] in
                guard let self else { return }
                let realm = RealmManager.shared.realm
                let repetitionCount = workout.exerciseSets.last?.repetitionCount ?? 0
                let weight = workout.exerciseSets.last?.weight ?? 0
                try! realm.write {
                    self.workout.exerciseSets.append(ExerciseSet(repetitionCount: repetitionCount, weight: weight))
                }
                tableView.insertRows(at: [IndexPath(row: workout.exerciseSets.count - 1, section: 0)], with: .automatic)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            workout.exerciseSets.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        try! realm.write {
            workout.exerciseSets.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tableView.reloadData()
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
}

extension ExerciseSetViewController: GrabberViewDelegate {
    func grabber(swipeGestureFor direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .up:
            if timer.timerStatus == .rest {
                exerciseSetView.timerStackView.arrangedSubviews[0].isHidden(true)
                self.exerciseSetView.grabberViewTopOffset.update(offset: 8)
            } else {
                self.exerciseSetView.grabberViewTopOffset.update(offset: -self.exerciseSetView.timerStackView.frame.height/2 + 4)
            }
            UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut]) {
                self.view.layoutIfNeeded()
            }
            
        case .down:
            self.exerciseSetView.grabberViewTopOffset.update(offset: 16)
            if exerciseSetView.timerStackView.arrangedSubviews[0].isHidden {
                exerciseSetView.timerStackView.arrangedSubviews[0].isHidden(false)
            }
            UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    func grabberDidTappedButton() {
        let shouldBeEdited = !exerciseSetView.tableView.isEditing
        exerciseSetView.tableView.setEditing(shouldBeEdited, animated: true)
        if !shouldBeEdited {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.exerciseSetView.tableView.reloadData()
            }
            
        }
        exerciseSetView.grabberView.isMenuButtonSelected = shouldBeEdited
    }
    
    
}
