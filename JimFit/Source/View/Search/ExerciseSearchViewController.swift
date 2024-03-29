//
//  ExerciseSearchViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit
import RealmSwift

final class ExerciseSearchViewController: UIViewController, ExerciseSearchTableViewCellDelegate {
    enum ButtonType {
        case bodyPart
        case equipmentType
    }
    private var date: String
    private lazy var searchView = ExerciseSearchView(frame: view.frame)
    private var oldRealm: Realm!
    private var list: Results<Exercise>!
    private lazy var bodyPartButtons = searchView.bodyPartStackView.subviews as! [UIButton]
    private lazy var equipmentTypeButtons = searchView.equipmentTypeStackView.subviews as! [UIButton]
    var bodyPartSelectedButton: UIButton?
    var equipmentTypeSelectedButton: UIButton?
    var isLikeButtonSelected: Bool = false
    
    var queryTuple: (NSPredicate?, NSPredicate?)
    weak var reloadDelegate: ReloadDelegate?
    private var selectedIndexes = Set<Int>()
    private let maxSelectionCount = 12
    
    init(date: String) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchView)
        fetchSearchList()
        configureTableView()
        configureButtons()
        configureSearchBar()
        updateLike()
        searchView.addListButton.addTarget(self, action: #selector(addListButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func addListButtonTapped(_ sender: UIButton) {
        HapticsManager.shared.vibrateForInteraction(style: .medium)
        guard let selectedCells = searchView.tableView.indexPathsForSelectedRows else { return }
        let workouts = selectedCells.map {
            return Workout(exerciseReference: list[$0.row].reference)
            
        }
        if let workout = oldRealm.object(ofType: WorkoutLog.self, forPrimaryKey: date) {
            try! oldRealm.write {
                workout.workouts.append(objectsIn: workouts)
            }
        } else {
            try! oldRealm.write {
                let workoutLog = WorkoutLog(workoutDate: date, workoutMemo: "")
                workoutLog.workouts.append(objectsIn: workouts)
                oldRealm.add(workoutLog)
            }
        }
        
        dismiss(animated: true)
        reloadDelegate?.reloadData()
    }
    
    func configureSearchBar() {
        searchView.searchBar.delegate = self
    }
    
    func updateLike() {
        let likeCount = oldRealm.objects(Exercise.self).where { $0.liked == true }.count
        searchView.likeCount =  String(likeCount)
        searchView.tableView.reloadData()
    }
    func configureTableView() {
        searchView.tableView.delegate = self
        searchView.tableView.dataSource = self
        searchView.tableView.register(ExerciseSearchTableViewCell.self, forCellReuseIdentifier: ExerciseSearchTableViewCell.identifier)
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
        HapticsManager.shared.vibrateForSelection()
        selectButton(type: .bodyPart, button: sender)
    }
    
    @objc func equipmentTypeButtonsTapped(_ sender: UIButton) {
        HapticsManager.shared.vibrateForSelection()
        selectButton(type: .equipmentType, button: sender)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        HapticsManager.shared.vibrateForSelection()
        isLikeButtonSelected.toggle()
        if isLikeButtonSelected {
            sender.baseBackgroundColor(K.Color.Primary.Blue)
            sender.baseForegroundColor(.white)
            sender.layer.borderColor = UIColor.clear.cgColor
        } else {
            sender.baseBackgroundColor(.clear)
            sender.baseForegroundColor(K.Color.Primary.Red)
            sender.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        }
        updateLocalizedList()
        searchView.tableView.reloadData()
    }
    private func fetchSearchList() {
        oldRealm = RealmManager.shared.oldRealm
        list = oldRealm.objects(Exercise.self)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ExerciseSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    /// 검색 버튼 클릭 시, 키보드를 내려준다.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    /// 취소 버튼 클릭 시, 키보드를 내리고 검색 결과 초기호
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        HapticsManager.shared.vibrateForSelection()
        searchBar.resignFirstResponder()
        searchBar.text = nil
        updateLocalizedList()
        searchView.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어가 비어있는 경우, API 호출을 하지 않는다.
        guard let term = searchBar.text, !term.isEmpty else { return }
        let separatedString = term.components(separatedBy: " ")
        // 검색어와 분류 정보를 전달하면서, API 호출을 한다.
        updateLocalizedList()
        separatedString.forEach { query in
            self.list = self.list
                .where {
                    $0.exerciseName.contains(query, options: .caseInsensitive)
                }
        }

        self.searchView.tableView.reloadData()
    }
    
    /// 엔터 눌렀을 때 검색
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // 검색어가 비어있는 경우, API 호출을 하지 않는다.
        guard let term = searchBar.text, !term.isEmpty else { return }
        let separatedString = term.components(separatedBy: " ")
        // 검색어와 분류 정보를 전달하면서, API 호출을 한다.
        updateLocalizedList()
        separatedString.forEach { query in
            self.list = self.list
                .where {
                    $0.exerciseName.contains(query, options: .caseInsensitive)
                }
        }
        
        self.searchView.tableView.reloadData()
    }
}

extension ExerciseSearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSearchTableViewCell.identifier, for: indexPath) as! ExerciseSearchTableViewCell
        cell.exercise = list[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        guard selectedIndexes.count < maxSelectionCount else {
            searchView.tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        selectedIndexes.insert(indexPath.row)
        searchView.addListButton.isEnabled(selectedIndexes.count > 0)
        searchView.selectedLabel.text("selection_list%@".localized("\(selectedIndexes.count)"))
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        selectedIndexes.remove(indexPath.row)
        guard selectedIndexes.count > 0 else {
            searchView.addListButton.isEnabled(false)
            searchView.selectedLabel.text("selection_list%@".localized("0"))
            return
        }
        searchView.selectedLabel.text("selection_list%@".localized("\(selectedIndexes.count)"))
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
        updateLocalizedList()
        searchBarTextDidEndEditing(searchView.searchBar)
        searchView.tableView.reloadData()
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
    
    func updateLocalizedList() {
        oldRealm = RealmManager.shared.oldRealm
        if isLikeButtonSelected {
            switch queryTuple {
            case (nil, nil):
                list = oldRealm.objects(Exercise.self)
                    .filter("liked == %@", true)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, nil):
                list = oldRealm.objects(Exercise.self)
                    .filter("liked == %@", true)
                    .filter(predicate1)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (nil, let predicate2?):
                list = oldRealm.objects(Exercise.self)
                    .filter("liked == %@", true)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, let predicate2?):
                list = oldRealm.objects(Exercise.self)
                    .filter("liked == %@", true)
                    .filter(predicate1)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            }
        } else {
            switch queryTuple {
            case (nil, nil):
                list = oldRealm.objects(Exercise.self)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, nil):
                list = oldRealm.objects(Exercise.self)
                    .filter(predicate1)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (nil, let predicate2?):
                list = oldRealm.objects(Exercise.self)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            case (let predicate1?, let predicate2?):
                list = oldRealm.objects(Exercise.self)
                    .filter(predicate1)
                    .filter(predicate2)
                    .sorted(byKeyPath: "reference", ascending: true)
            }
        }
        selectedIndexes.removeAll()
        searchView.selectedLabel.text("selection_list%@".localized("0"))
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
