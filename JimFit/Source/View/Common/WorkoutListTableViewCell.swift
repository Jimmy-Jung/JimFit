//
//  TodoListTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

final class WorkoutListTableViewCell: UITableViewCell {
    
    var workout: Workout? {
        didSet {
            guard let workout else { return }
            guard let exercise = workout.exercise else { return }
            let bodyPartList = exercise.bodyPart.map { $0.localized }
            let bodyPartString = bodyPartList.joined(separator: ", ")
            let equipmentTypeString = exercise.equipmentType.localized
            var secondaryString: String {
                if equipmentTypeString == "none" {
                    return bodyPartString
                } else {
                    return bodyPartString + " / " + equipmentTypeString
                }
            }
            let weightDouble = workout.exerciseSets
                .map { $0.weight * Double($0.repetitionCount)}
                .reduce(0.0,+)
            let setCount = workout.exerciseSets.count
            let setFinishedCount = workout.exerciseSets
                .filter { $0.isFinished }
                .count
            let progression = Double(setFinishedCount) / Double(setCount)
            titleLabel.text(exercise.exerciseName)
            secondaryLabel.text(secondaryString)
            weightLabel.text(String(format: "%.1f", weightDouble) + " kg")
            setLabel.text(String(describing: setCount))
            progressLabel.text(String(Int(progression * 100)) + "%")
            progressBar.snp.updateConstraints { make in
                make.width.equalTo(progressBar.frame.width * progression)
            }
        }
    }
    
    let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
    
    lazy var checkButton = UIButton(configuration: .plain())
        .setImage(K.Image.CheckBoxNormal, for: .normal)
        .setImage(K.Image.CheckBoxSelected, for: .selected)
        .tintColor(K.Color.Grayscale.Tint)
        .addAction { [unowned self] in
            isChecked.toggle()
        }
    
    let titleLabel = UILabel()
        .text("BarBell Bench Press as BarBell Bench Press")
        .font(K.Font.CellHeader)
        .numberOfLines(2)
        .textColor(K.Color.Primary.Label)
    
    let secondaryLabel = UILabel()
        .text("Chest")
        .font(K.Font.CellBody)
        .textColor(K.Color.Grayscale.Label)
    
    let weightImage = UIImageView()
        .image(UIImage(systemName: "dumbbell"))
        .tintColor(K.Color.Primary.Label)
    
    let weightLabel = UILabel()
        .text("1422 kg")
        .font(K.Font.CellBody)
        .textColor(K.Color.Primary.Label)
    
    let setImage = UIImageView()
        .image(UIImage(systemName: "bolt.fill"))
        .tintColor(K.Color.Primary.Yellow)
    
    let setLabel = UILabel()
        .text("222 set")
        .font(K.Font.CellBody)
        .textColor(K.Color.Primary.Label)
    
    let progressBarBorder = UIView()
        .setBorder(color: K.Color.Grayscale.border_Medium, width: K.Size.border_Medium)
        .cornerRadius(4)
    
    let progressBar = UIView()
        .backgroundColor(K.Color.Primary.Green)
        .cornerRadius(2)
    
    let progressLabel = UILabel()
        .text("75%")
        .textColor(K.Color.Grayscale.Label)
        .font(.systemFont(ofSize: 13, weight: .bold))
    
    lazy var titleStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(titleLabel)
        .addArrangedSubview(secondaryLabel)
    
    lazy var weightStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(weightImage)
        .addArrangedSubview(weightLabel)
    
    lazy var setStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(setImage)
        .addArrangedSubview(setLabel)
    
    lazy var infoStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(weightStackView)
        .addArrangedSubview(setStackView)
        .addArrangedSubview(UIView())
    
    lazy var horizontalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(titleStackView)
        .addArrangedSubview(infoStackView)
    
    var isChecked: Bool = false {
        didSet {
            UIView.transition(with: checkButton, duration: 0.15, options: [.transitionCrossDissolve, .curveEaseInOut]) {
                self.checkButton.isSelected = self.isChecked
                self.checkButton.tintColor(self.isChecked ? .clear : .systemGray3)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(borderView)
        borderView.addSubview(checkButton)
        borderView.addSubview(progressBarBorder)
        progressBarBorder.addSubView(progressBar)
        borderView.addSubview(progressLabel)
        borderView.addSubview(horizontalStackView)
        
        borderView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        checkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(0)
            make.size.equalTo(50)
        }
        
        weightLabel.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        weightImage.snp.makeConstraints { make in
            make.size.equalTo(18)
        }
        setLabel.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        setImage.snp.makeConstraints { make in
            make.size.equalTo(18)
        }
        
        horizontalStackView.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(0)
            make.top.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
        }
        
        progressBarBorder.snp.makeConstraints { make in
            make.top.equalTo(horizontalStackView.snp.bottom).offset(8)
            make.leading.equalTo(horizontalStackView)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(6)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressBarBorder).offset(-3)
            make.leading.equalTo(progressBarBorder.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(48)
        }
        
        progressBar.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(0)
        }
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            borderView.setBorder(color: K.Color.Primary.Label, width: K.Size.border_Medium)
        } else {
            borderView.setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if isSelected {
                borderView.setBorder(color: K.Color.Primary.Label, width: K.Size.border_Medium)
            } else {
                borderView.setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
            }
        }
    }

}
