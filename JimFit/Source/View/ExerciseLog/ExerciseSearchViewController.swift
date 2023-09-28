//
//  ExerciseSearchViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit
import RealmSwift

final class ExerciseSearchViewController: UIViewController {
    
    private let realm = try! Realm()
    private lazy var searchView = ExerciseSearchView(frame: view.frame)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchView)
        searchView.bodyPartList = Bo
        
    }
    
    private func makeButtonList() {
        if let realmPath = Bundle.main.path(forResource: "Exercise", ofType: "realm") {
            let realm = try! Realm(fileURL: URL(filePath: realmPath))
            
            let list = realm.objects(ExerciseRealm.self)
        }
    }
  

}
