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
    private var realm: Realm!
    private var list: Results<ExerciseRealm>!
    private lazy var bodyPartButtons = searchView.bodyPartStackView.subviews as! [UIButton]
    private lazy var equipmentTypeButtons = searchView.equipmentTypeStackView.subviews as! [UIButton]
    var bodyPartSelected: UIButton?
    var equipmentTypeSelected: UIButton?
    
    var queryArray: [NSPredicate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSearchList()
        view.addSubview(searchView)
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.register(ExerciseListTableViewCell.self, forCellReuseIdentifier: ExerciseListTableViewCell.identifier)
        
        bodyPartButtons.dropFirst().forEach { //dropFirst() 는 like버튼 제외
            $0.addTarget(self, action: #selector(bodyPartButtonTapped(_:)), for: .touchUpInside)
        }
        bodyPartButtons[0].addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        equipmentTypeButtons.forEach {
            $0.addTarget(self, action: #selector(equipmentTypeButtonsTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func bodyPartButtonTapped(_ sender: UIButton) {
        updateSelectedButton(selectedButton: &bodyPartSelected, sender: sender)
        if sender.isSelected {
            let bodypart = BodyPart.allCases[sender.tag].rawValue
            queryArray.append(NSPredicate(format: "ANY bodyPart CONTAINS %@", bodypart))
            let query = NSCompoundPredicate(type: .or, subpredicates: queryArray)
            list = realm.objects(ExerciseRealm.self).filter(query)
        }
        searchView.tableView.reloadData()
    }
    
    @objc func equipmentTypeButtonsTapped(_ sender: UIButton) {
        updateSelectedButton(selectedButton: &equipmentTypeSelected, sender: sender)
    }
    
    private func updateSelectedButton( selectedButton: inout UIButton?, sender: UIButton) {
        selectedButton?.baseBackgroundColor(.clear)
        selectedButton?.baseForegroundColor(K.Color.Primary.Label)
        selectedButton?.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        
        sender.isSelected.toggle()
        selectedButton?.isSelected = false
        
        if sender.isSelected {
            selectedButton = sender
            sender.baseBackgroundColor(K.Color.Primary.Orange)
            sender.baseForegroundColor(.white)
            sender.layer.borderColor = UIColor.clear.cgColor
        } else {
            selectedButton?.isSelected = false
            selectedButton = nil
            sender.baseBackgroundColor(.clear)
            sender.baseForegroundColor(K.Color.Primary.Label)
            sender.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        }
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            sender.baseBackgroundColor(K.Color.Primary.Blue)
            sender.baseForegroundColor(.white)
            sender.layer.borderColor = UIColor.clear.cgColor
        } else {
            sender.baseBackgroundColor(.clear)
            sender.baseForegroundColor(.red)
            sender.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        }
    }
    private func fetchSearchList() {
        let fileManager = FileManager.default
        // 도큐먼트 디렉토리 경로
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 저장할 파일의 URL
        let fileURL = documentsDirectory.appendingPathComponent("Exercise.realm")
        realm = try! Realm(fileURL: fileURL)
        list = realm.objects(ExerciseRealm.self).sorted(byKeyPath: "reference", ascending: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            bodyPartButtons.dropFirst().forEach {
                $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
                bodyPartSelected?.layer.borderColor = UIColor.clear.cgColor
            }
            bodyPartButtons[0].layer.borderColor = bodyPartButtons[0].isSelected ? UIColor.clear.cgColor : K.Color.Grayscale.Tint.cgColor
            
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
        var secondaryString: String {
            if targetMuscleString.isEmpty {
                return bodyPartString
            } else {
                return bodyPartString + " / " + targetMuscleString
            }
        }
        cell.titleLabel.text(list[indexPath.row].exerciseName)
        cell.secondaryLabel.text(secondaryString)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.dequeueReusableCell(withIdentifier: ExerciseListTableViewCell.identifier, for: indexPath) as! ExerciseListTableViewCell
        
    }
    
    
}

