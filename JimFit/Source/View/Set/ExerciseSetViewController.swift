//
//  ExerciseSetViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit
import RealmSwift

final class ExerciseSetViewController: UIViewController {
    private lazy var exerciseSetView = ExerciseSetView()
    var workout: Workout!
    
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
    }
    
    private func configureView() {
        view.backgroundColor(K.Color.Grayscale.SecondaryBackground)
        view.addSubview(exerciseSetView)
        exerciseSetView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        exerciseSetView.grabberView.delegate = self
    }
    
    private func addButtonsAction() {
        exerciseSetView.startWorkoutButton.addAction { [weak self] in self?.startWorkoutButtonTapped() }
        exerciseSetView.doneSetButton.addAction { [weak self] in self?.doneSetButtonTapped() }
    }
    
    private func configureTableView() {
        exerciseSetView.tableView.dataSource = self
        exerciseSetView.tableView.delegate = self
        exerciseSetView.tableView.register(ExerciseSetTableViewCell.self, forCellReuseIdentifier: ExerciseSetTableViewCell.identifier)
        exerciseSetView.tableView.rowHeight = UITableView.automaticDimension
        exerciseSetView.tableView.separatorStyle = .none
    }
    
    private func startWorkoutButtonTapped() {
        
    }
    private func doneSetButtonTapped() {
        for (index, value) in workout.exerciseSets.enumerated() {
            if value.isFinished == false {
                let cell = exerciseSetView.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! ExerciseSetTableViewCell
                cell.doneSet()
                
                let realm = RealmManager.shared.realm!
                try! realm.write {
                    value.isFinished = true
                }
                return
            }
        }
        exerciseSetView.tableView.reloadData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ExerciseSetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.exerciseSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetTableViewCell.identifier, for: indexPath) as! ExerciseSetTableViewCell
        cell.configureCell(with: workout.exerciseSets[indexPath.row], index: indexPath.row)
        cell.weighTextField.delegate = self
        cell.repsTextField.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension ExerciseSetViewController: GrabberViewDelegate {
    func grabber(swipeGestureFor direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .up:
            
            UIView.transition(with: view, duration: 0.3) {
                self.exerciseSetView.grabberViewTopOffset.update(offset: -self.exerciseSetView.stopWatchStackView.frame.height/2 + 4)
                self.view.layoutIfNeeded()
            }
            
        case .down:
            UIView.transition(with: view, duration: 0.3) {
                self.exerciseSetView.grabberViewTopOffset.update(offset: 16)
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    func grabberDidTappedButton() {
        
    }
    
    
}

extension ExerciseSetViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
        grabber(swipeGestureFor: .up)
    }
}
