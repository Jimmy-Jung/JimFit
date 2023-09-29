//
//  ExerciseSearchViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit
import RealmSwift

final class ExerciseSearchViewController: UIViewController {
    enum ButtonType {
        case bodyPart
        case equipmentType
    }
    
    private lazy var searchView = ExerciseSearchView(frame: view.frame)
    private var realm: Realm!
    private var list: Results<Exercise>!
    private lazy var bodyPartButtons = searchView.bodyPartStackView.subviews as! [UIButton]
    private lazy var equipmentTypeButtons = searchView.equipmentTypeStackView.subviews as! [UIButton]
    var bodyPartSelectedButton: UIButton?
    var equipmentTypeSelectedButton: UIButton?
    var isLikeButtonSelected: Bool = false
    
    var queryTuple: (NSPredicate?, NSPredicate?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchView)
        fetchSearchList()
        configureTableView()
        configureButtons()
        
    }
    func configureTableView() {
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.register(ExerciseListTableViewCell.self, forCellReuseIdentifier: ExerciseListTableViewCell.identifier)
    }
    func configureButtons() {
        bodyPartButtons.dropFirst().forEach { //dropFirst() 는 like버튼 제외
            $0.addTarget(self, action: #selector(bodyPartButtonTapped(_:)), for: .touchUpInside)
        }
        bodyPartButtons[0].addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        
        equipmentTypeButtons.forEach {
            $0.addTarget(self, action: #selector(equipmentTypeButtonsTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func bodyPartButtonTapped(_ sender: UIButton) {
        selectButton(type: .bodyPart, button: sender)
    }
    
    @objc func equipmentTypeButtonsTapped(_ sender: UIButton) {
        selectButton(type: .equipmentType, button: sender)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        isLikeButtonSelected.toggle()
        if isLikeButtonSelected {
            sender.baseBackgroundColor(K.Color.Primary.Blue)
            sender.baseForegroundColor(.white)
            sender.layer.borderColor = UIColor.clear.cgColor
        } else {
            sender.baseBackgroundColor(.clear)
            sender.baseForegroundColor(.red)
            sender.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        }
        updateList()
    }
    private func fetchSearchList() {
        let fileManager = FileManager.default
        // 도큐먼트 디렉토리 경로
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        // 저장할 파일의 URL
        let fileURL = documentsDirectory.appendingPathComponent("Exercise.realm")
        realm = try! Realm(fileURL: fileURL)
        list = realm.objects(Exercise.self).sorted(byKeyPath: "reference", ascending: true)
    }
    
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
    
                bodyPartButtons.dropFirst().forEach {
                    $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
                    bodyPartSelectedButton?.layer.borderColor = UIColor.clear.cgColor
                }
                bodyPartButtons[0].layer.borderColor = bodyPartButtons[0].isSelected ? UIColor.clear.cgColor : K.Color.Grayscale.Tint.cgColor
                
                equipmentTypeButtons.forEach {
                    $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
                    equipmentTypeSelectedButton?.layer.borderColor = UIColor.clear.cgColor
                }
    
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
        let equipmentTypeString = list[indexPath.row].equipmentType
        var secondaryString: String {
            if equipmentTypeString == "none" {
                return bodyPartString
            } else {
                return bodyPartString + " / " + equipmentTypeString
            }
        }
        cell.titleLabel.text = list[indexPath.row].exerciseName
        cell.secondaryLabel.text(secondaryString)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.dequeueReusableCell(withIdentifier: ExerciseListTableViewCell.identifier, for: indexPath) as! ExerciseListTableViewCell
        
    }
    
    
}

extension ExerciseSearchViewController {
    func selectButton(type: ButtonType, button: UIButton) {
        // 선택했던 버튼인지 확인 후 같은 버튼이면 리셋
        if isSameWithSelectedButton(type: type, button: button) {
            resetButtonStyle(type: type, button: button)
            removeSortFromList(type: type, button: button)
        } else { // 선택했던 버튼이 아니면 버튼 업데이트 및 정렬 추가
            updateButtonStyle(type: type, button: button)
            addSortToList(type: type, button: button)
        }
        // 선택한 버튼에 저장 or 같은 버튼이면 nil할당
        saveSelectedButton(type: type, button: button)
        updateList()
    }
    
    func isSameWithSelectedButton(type: ButtonType, button: UIButton) -> Bool {
        switch type {
        case .bodyPart:
            return bodyPartSelectedButton == button
        case .equipmentType:
            return equipmentTypeSelectedButton == button
        }
    }
    
    func saveSelectedButton(type: ButtonType, button: UIButton) {
        switch type {
        case .bodyPart:
            if bodyPartSelectedButton == button {
                bodyPartSelectedButton = nil
            } else {
                bodyPartSelectedButton = button
            }
            
        case .equipmentType:
            if equipmentTypeSelectedButton == button {
                equipmentTypeSelectedButton = nil
            } else {
                equipmentTypeSelectedButton = button
            }
            
        }
    }
    
    func updateList() {
            switch queryTuple {
            case (nil, nil):
                list = realm.objects(Exercise.self)
                    .filter("liked == %@", isLikeButtonSelected)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, nil):
                list = realm.objects(Exercise.self)
                    .filter("liked == %@", isLikeButtonSelected)
                    .filter(predicate1)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (nil, let predicate2?):
                list = realm.objects(Exercise.self)
                    .filter("liked == %@", isLikeButtonSelected)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, let predicate2?):
                list = realm.objects(Exercise.self)
                    .filter("liked == %@", isLikeButtonSelected)
                    .filter(predicate1)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            }
        searchView.tableView.reloadData()
    }
    
    func addSortToList(type: ButtonType, button: UIButton) {
        // 해당 타입과 버튼을 기준으로 정렬을 리스트에 추가하는 로직을 작성해주세요.
        switch type {
        case .bodyPart:
            let bodyPart = BodyPart.allCases[button.tag].rawValue
            queryTuple.0 = NSPredicate(format: "ANY bodyPart CONTAINS %@", bodyPart)
        case .equipmentType:
            let equipmentType = EquipmentType.allCases[button.tag].rawValue
            queryTuple.1 = NSPredicate(format: "equipmentType == %@", equipmentType)
        }
    }
    
    func resetButtonStyle(type: ButtonType, button: UIButton) {
        switch type {
        case .bodyPart:
            bodyPartButtons.dropFirst().forEach {
                $0.baseBackgroundColor(.clear)
                $0.baseForegroundColor(K.Color.Primary.Label)
                $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
            }
        case .equipmentType:
            equipmentTypeButtons.forEach {
                $0.baseBackgroundColor(.clear)
                $0.baseForegroundColor(K.Color.Primary.Label)
                $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
            }
        }
    }
    
    func removeSortFromList(type: ButtonType, button: UIButton) {
        // 해당 타입과 버튼을 기준으로 정렬을 리스트에서 제거하는 로직을 작성해주세요.
        switch type {
        case .bodyPart:
            queryTuple.0 = nil
        case .equipmentType:
            queryTuple.1 = nil
        }
        
    }
    
    func updateButtonStyle(type: ButtonType, button: UIButton) {
        // 버튼의 배경색을 오렌지색으로 변경하는 로직을 작성해주세요.
        switch type {
        case .bodyPart:
            bodyPartButtons.dropFirst().forEach {
                $0.baseBackgroundColor(.clear)
                $0.baseForegroundColor(K.Color.Primary.Label)
                $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
            }
            button.baseBackgroundColor(K.Color.Primary.Orange)
            button.baseForegroundColor(.white)
            button.layer.borderColor = UIColor.clear.cgColor
        case .equipmentType:
            equipmentTypeButtons.forEach {
                $0.baseBackgroundColor(.clear)
                $0.baseForegroundColor(K.Color.Primary.Label)
                $0.layer.borderColor = K.Color.Grayscale.Tint.cgColor
            }
            button.baseBackgroundColor(K.Color.Primary.Orange)
            button.baseForegroundColor(.white)
            button.layer.borderColor = UIColor.clear.cgColor
        }
    }
}