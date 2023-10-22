//
//  ExerciseSetViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

final class ExerciseSetViewController: UIViewController {
    private lazy var exerciseSetView = ExerciseSetView()
    private let titleTimerView = TitleTimerView()
    private var viewModel: ExerciseSetViewModelProtocol!
    private var timerStatus: TimerManager.TimerStatus = .stop
    private let disposeBag = DisposeBag()
    private lazy var stopButton: UIBarButtonItem? = UIBarButtonItem(image: K.Image.Stop, primaryAction: stop)
    private lazy var playButton: UIBarButtonItem? = UIBarButtonItem(systemItem: .play, primaryAction: play)
    private lazy var play: UIAction = UIAction { [weak self] _ in
        HapticsManager.shared.vibrateForInteraction(style: .medium)
        self?.startWorkoutButtonTapped()
        self?.stopButton?.tintColor = K.Color.Primary.Red
    }
    private lazy var stop = UIAction { [weak self] _ in
        HapticsManager.shared.vibrateForNotification(style: .error)
        self?.showAlert(
            title: "done_workout_title".localized,
            message: "done_workout_message".localized,
            preferredStyle: .alert,
            doneHandler: { _ in
                HapticsManager.shared.vibrateForSelection()
            self?.viewModel.stopExercise()
        })
    }
    
    init(viewModel: ExerciseSetViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        bindingView()
        BindingViewModel()
        
        navigationItem.titleView = timerStatus == .stop ? nil : titleTimerView
    }
    
    private func BindingViewModel() {
        
        viewModel.totalExerciseTime
            .subscribe { [weak self] in
                self?.exerciseSetView.workoutTimer.totalTimeLabel.text($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.totalRestTime
            .subscribe { [weak self] in
                self?.exerciseSetView.restTimer.totalTimeLabel.text($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.setExerciseTime
            .subscribe { [weak self] in
                self?.exerciseSetView.workoutTimer.setTimeLabel.text($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.setRestTime
            .subscribe { [weak self] in
                self?.exerciseSetView.restTimer.setTimeLabel.text($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.totalTime
            .asDriver()
            .drive { [weak self] in
                self?.titleTimerView.title.text($0)
            }
            .disposed(by: disposeBag)
        
        viewModel.timerStatus
            .asDriver()
            .drive { [weak self] in
                guard let self else { return }
                timerStatus = $0
                switch $0 {
                case .exercise:
                    exerciseSetView.workoutTimer.activateColor()
                    navigationItem.titleView = titleTimerView
                    titleTimerView.fetchColor(.exercise)
                    navigationItem.rightBarButtonItem = stopButton
                case .rest:
                    exerciseSetView.restTimer.activateColor()
                    navigationItem.titleView = titleTimerView
                    titleTimerView.fetchColor(.rest)
                    navigationItem.rightBarButtonItem = stopButton
                case .stop:
                    exerciseSetView.restTimer.deactivateColor()
                    exerciseSetView.workoutTimer.deactivateColor()
                    navigationItem.titleView = nil
                    titleTimerView.fetchColor(.stop)
                    navigationItem.rightBarButtonItem = playButton
                }
            }
            .disposed(by: disposeBag)
    }
    
    func bindingView() {
        exerciseSetView.startWorkoutButton.isEnabled = viewModel.isActiveTimerButton
        exerciseSetView.doneSetButton.isEnabled = viewModel.isActiveTimerButton
        if !viewModel.isActiveTimerButton {
            playButton = nil
            stopButton = nil
        }
        exerciseSetView.startWorkoutButton.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.startWorkoutButtonTapped()
            })
            .disposed(by: disposeBag)
        
        exerciseSetView.doneSetButton.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.doneSetButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor(K.Color.Grayscale.SecondaryBackground)
        view.addSubview(exerciseSetView)
        exerciseSetView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        exerciseSetView.grabberView.delegate = self
        exerciseSetView.grabberView.setTitle(viewModel.grabberTitle)
        
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
        HapticsManager.shared.vibrateForInteraction(style: .medium)
        viewModel.startExerciseTimer()
        UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut]) {
            self.exerciseSetView.workoutTimer.activateColor()
            self.exerciseSetView.restTimer.deactivateColor()
        }
        UIView.transition(with: titleTimerView, duration: 0.3, options: .transitionCrossDissolve) {
            self.titleTimerView.fetchColor(.exercise)
            self.titleTimerView.setNeedsDisplay()
        }
    }
    private func doneSetButtonTapped() {
        HapticsManager.shared.vibrateForInteraction(style: .medium)
        viewModel.startRestTimer()
        UIView.transition(with: exerciseSetView.timerStackView, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut]) {
            self.exerciseSetView.restTimer.activateColor()
            self.exerciseSetView.workoutTimer.deactivateColor()
        }
        UIView.transition(with: titleTimerView, duration: 0.3, options: .transitionCrossDissolve) {
            self.titleTimerView.fetchColor(.rest)
            self.titleTimerView.setNeedsDisplay()
        }
        exerciseSetView.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExerciseSetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? viewModel.exerciseSetsCount : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetTableViewCell.identifier, for: indexPath) as! ExerciseSetTableViewCell
            cell.configureCell(with: viewModel.exerciseSet(at: indexPath.row), index: indexPath.row)
            cell.selectionStyle = .none
            cell.setButtonHandler = { [weak self] in
                guard let self else { return }
                if let lastIndex = viewModel.lastFinishedExerciseSetIndex , indexPath.row < lastIndex {
                    tableView.moveRow(at: indexPath, to: IndexPath(row: lastIndex, section: 0))
                    viewModel.moveExerciseSet(from: indexPath.row, to: lastIndex)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    tableView.reloadData()
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
                viewModel.appendExerciseSet()
                tableView.insertRows(at: [IndexPath(row: viewModel.exerciseSetsCount - 1, section: 0)], with: .automatic)
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
        viewModel.moveExerciseSet(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.removeExerciseSet(at: indexPath.row)
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
            if timerStatus == .rest {
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
    func grabberButtonTapped() {
        HapticsManager.shared.vibrateForInteraction(style: .heavy)
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
