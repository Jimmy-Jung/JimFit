//
//  ExerciseSetViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit

final class ExerciseSetViewController: UIViewController {
    private lazy var exerciseSetView = ExerciseSetView()
    
    
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
        exerciseSetView.tableView.rowHeight = 69
    }
   

}

extension ExerciseSetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetTableViewCell.identifier, for: indexPath) as! ExerciseSetTableViewCell
        
        return cell
    }
    
    
}
