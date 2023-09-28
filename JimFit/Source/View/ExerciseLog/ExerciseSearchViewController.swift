//
//  ExerciseSearchViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit
import RealmSwift

final class ExerciseSearchViewController: UIViewController {
    
    private lazy var searchView = ExerciseSearchView(frame: view.frame)
    private var list: Results<ExerciseRealm>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSearchList()
        view.addSubview(searchView)
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.register(ExerciseListTableViewCell.self, forCellReuseIdentifier: ExerciseListTableViewCell.identifier)
        
    }
    
    private func fetchSearchList() {
        if let realmPath = Bundle.main.path(forResource: "Exercise", ofType: "realm") {
            let realm = try! Realm(fileURL: URL(filePath: realmPath))
            
            list = realm.objects(ExerciseRealm.self).sorted(byKeyPath: "reference", ascending: true)
        }
    }
  

}

extension ExerciseSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseListTableViewCell.identifier, for: indexPath) as! ExerciseListTableViewCell
        let bodyPartList = list[indexPath.row].bodyPart
        let bodyPartString = bodyPartList.joined(separator: ", ")
        let targerMuscleList = list[indexPath.row].targetMuscles
        let targetMuscleString = targerMuscleList.joined(separator: ", ")
        let secondaryString = bodyPartString + " / " + targetMuscleString
        cell.titleLabel.text(list[indexPath.row].exerciseName)
        cell.secondaryLabel.text(secondaryString)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseListTableViewCell.identifier, for: indexPath) as! ExerciseListTableViewCell
        
    }
    
    
}

