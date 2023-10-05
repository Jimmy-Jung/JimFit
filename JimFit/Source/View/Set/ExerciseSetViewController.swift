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
        view.backgroundColor(.systemBackground)
        view.addSubview(exerciseSetView)
        exerciseSetView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        exerciseSetView.tableView.dataSource = self
        exerciseSetView.tableView.delegate = self
        exerciseSetView.tableView.register(ExerciseSetTableViewCell.self, forCellReuseIdentifier: ExerciseSetTableViewCell.identifier)
        exerciseSetView.tableView.rowHeight = UITableView.automaticDimension
        exerciseSetView.tableView.separatorStyle = .none
        
        
        exerciseSetView.startWorkoutButton.addAction { [weak self] in self?.startWorkoutButtonTapped() }
        exerciseSetView.doneSetButton.addAction { [weak self] in self?.doneSetButtonTapped() }
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
//                    realm.add(workout, update: .modified)
                }
                return
            }
        }
        exerciseSetView.tableView.reloadData()
        
    }

}

extension ExerciseSetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.exerciseSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetTableViewCell.identifier, for: indexPath) as! ExerciseSetTableViewCell
        cell.configureCell(with: workout.exerciseSets[indexPath.row], index: indexPath.row)
        return cell
    }
    
    
}
