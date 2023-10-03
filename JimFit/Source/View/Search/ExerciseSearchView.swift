//
//  ExerciseSearchView.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit

final class ExerciseSearchView: UIView {
    
    var bodyPartList: [BodyPart] = BodyPart.allCases
    var equipmentTypeList: [EquipmentType] = EquipmentType.allCases
    
    private lazy var likeButton: UIButton = makeButton(name: "0")
        .setImage(K.Image.Like, for: .normal)
        .baseForegroundColor(.systemRed)
        .imagePadding(4)
    
    var likeCount: String = "0" {
        didSet {
            likeButton.titleWithFont(title: likeCount, font: K.Font.SubHeader)
        }
    }
    
    private let grabberView = UIView()
        .cornerRadius(2)
        .backgroundColor(K.Color.Grayscale.border_Medium)
    
    /// UISearchBar 인스턴스 생성
    let searchBar: UISearchBar = UISearchBar().then {
        $0.placeholder = "searchBar_placeholder".localized// 플레이스홀더 지정
        $0.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        $0.setValue("cancel".localized, forKey: "cancelButtonText") // 취소 버튼 이름 변경
        $0.setShowsCancelButton(true, animated: true)
        $0.tintColor = .label // 커서 색상 지정
        $0.autocapitalizationType = .none
    }
    
    private let bodyPartScrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    let bodyPartStackView = UIStackView()
        .axis(.horizontal)
        .spacing(12)
        .alignment(.fill)
        .distribution(.fillProportionally)
    
    private let equipmentTypeScrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    let equipmentTypeStackView = UIStackView()
        .axis(.horizontal)
        .spacing(12)
        .alignment(.fill)
        .distribution(.fillProportionally)
    
    let selectedLabel = UILabel()
        .text("선택항목 0/12")
        .font(K.Font.SubHeader)
        .numberOfLines(2)
    
    let tableView: UITableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.allowsMultipleSelection = true
        $0.keyboardDismissMode = .onDrag
    }
    
    let addListButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .baseBackgroundColor(K.Color.Primary.Orange)
        .titleWithFont(title: "+  추가 완료", font: K.Font.Header2)
        .cornerRadius(16)
        .isEnabled(false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.systemBackground)
        configureLayout()
        configureButton()
    }

    private func configureLayout() {
        addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
        }
        
        addSubView(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
        }
        addSubView(bodyPartScrollView)
        bodyPartScrollView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        bodyPartScrollView.addSubview(bodyPartStackView)
        bodyPartStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubView(equipmentTypeScrollView)
        equipmentTypeScrollView.snp.makeConstraints { make in
            make.top.equalTo(bodyPartScrollView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        equipmentTypeScrollView.addSubview(equipmentTypeStackView)
        equipmentTypeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubView(selectedLabel)
        selectedLabel.snp.makeConstraints { make in
            make.top.equalTo(equipmentTypeScrollView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        addSubView(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(selectedLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        
        addSubView(addListButton)
        addListButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(70)
            make.height.equalTo(50)
        }
    }
    
    private func makeButton(name: String) -> UIButton {
        let button: UIButton = UIButton(configuration: .filled())
            .baseBackgroundColor(.clear)
            .baseForegroundColor(K.Color.Primary.Label)
            .titleWithFont(title: name, font: K.Font.SubHeader)
            .cornerStyle(.capsule)
        
        button.layer.borderColor = K.Color.Grayscale.Tint.cgColor
        button.layer.borderWidth = K.Size.border_Medium
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }
    
    private func configureButton() {
        
        bodyPartStackView.addArrangedSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.greaterThanOrEqualTo(40)
        }
        
        for (index, bodyPart) in bodyPartList.enumerated() {
            let button = makeButton(name: bodyPart.rawValue.localized)
            button.tag = index
            bodyPartStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.width.greaterThanOrEqualTo(40)
            }
        }
        
        for (index, equipmentType) in equipmentTypeList.enumerated() {
            let button = makeButton(name: equipmentType.rawValue.localized)
            button.tag = index
            equipmentTypeStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(40)
                make.width.greaterThanOrEqualTo(40)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
