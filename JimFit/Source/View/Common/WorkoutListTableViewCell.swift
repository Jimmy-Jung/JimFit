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
            let weightFloat = workout.exerciseSets
                .filter {$0.isFinished}
                .map { $0.weight * $0.repetitionCount}
                .map { Float($0) }
                .reduce(0,+)
            let setCount = workout.exerciseSets.count
            let setFinishedCount = workout.exerciseSets
                .filter { $0.isFinished }
                .count
            let progression = Float(setFinishedCount) / Float(setCount)
            titleLabel.text(exercise.exerciseName.localized)
            titleLabel.sizeToFit()
            secondaryLabel.text(secondaryString)
            let weightInTons = weightFloat > 999 ? weightFloat / 1000 : weightFloat
            let weightUnit = weightFloat > 999 ? "ton" : "kg"
            weightLabel.text = String(format: "%.0f", weightInTons) + " " + weightUnit
            setLabel.text(String(describing: setCount) + " set")
            progressLabel.text(" " + String(Int(progression * 100)) + "%")
                DispatchQueue.main.async {
                    self.progressView.setProgress(progression, animated: true)
            }
        }
    }
    
    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .clipsToBounds(true)
    
    private let titleLabel = UILabel()
        .font(K.Font.CellHeader)
        .numberOfLines(2)
        .textColor(K.Color.Primary.Label)
    
    private let secondaryLabel = UILabel()
        .font(K.Font.CellBody)
        .textColor(K.Color.Grayscale.Label)
    
    let weightImage = UIImageView()
        .image(K.Image.Dumbbell)
        .contentMode(.scaleAspectFit)
        .tintColor(K.Color.Grayscale.border_Medium)
    
    private let weightLabel = UILabel()
        .font(K.Font.CellBody)
        .textColor(K.Color.Primary.Label)
    
    private let setImage = UIImageView()
        .image(K.Image.Bolt)
        .contentMode(.scaleAspectFit)
        .tintColor(K.Color.Primary.Yellow)
    
    private let setLabel = UILabel()
        .font(K.Font.CellBody)
        .textColor(K.Color.Primary.Label)
    
    private let progressView: UIProgressView = UIProgressView().then {
        $0.trackTintColor = K.Color.Grayscale.SecondaryFill
        $0.progressTintColor = K.Color.Primary.Green
        $0.progress = 0
    }
    
    private let progressLabel = UILabel()
        .textColor(K.Color.Grayscale.Label)
        .font(K.Font.CellBody)
    
    private lazy var titleStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(titleLabel)
        .addArrangedSubview(secondaryLabel)
        .addArrangedSubview(progressView)
    
    private lazy var weightStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(weightImage)
        .addArrangedSubview(weightLabel)
        
    
    private lazy var setStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(setImage)
        .addArrangedSubview(setLabel)
    
    private lazy var infoStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(weightStackView)
        .addArrangedSubview(setStackView)
        .addArrangedSubview(progressLabel)
        
    
    private lazy var horizontalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(titleStackView)
        .addArrangedSubview(infoStackView)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressView.setProgress(0, animated: true)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(borderView)
        
        borderView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        borderView.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(8)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.width.equalTo(94)
        }
        weightImage.snp.makeConstraints { make in
            make.width.equalTo(weightImage.snp.height)
        }
        setImage.snp.makeConstraints { make in
            make.width.equalTo(setImage.snp.height)
        }
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        progressView.snp.makeConstraints { make in
            make.height.equalTo(6)
        }
        // 코너 부드럽게
        borderView.layer.cornerCurve = .continuous
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
