//
//  TodoListTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit
import RealmSwift

final class WorkoutListTableViewCell: UITableViewCell {
    
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
    
    var workout: Workout? {
        didSet {
            guard let workout else { return }
            updateUI(with: workout)
        }
    }
    
    private func updateUI(with workout: Workout) {
        guard let exercise = RealmManager.shared
            .oldRealm
            .object(ofType: Exercise.self, forPrimaryKey: workout.exerciseReference) else { return }
        updateTitleLabel(with: exercise.exerciseName)
        updateSecondaryLabel(with: exercise.bodyPart, equipmentType: exercise.equipmentType)
        updateWeightLabel(with: workout.exerciseSets)
        updateSetLabel(with: workout.exerciseSets)
        updateProgress(with: workout.exerciseSets)
    }
    
    private func updateTitleLabel(with exerciseName: String) {
        titleLabel.text = exerciseName
        titleLabel.sizeToFit()
    }
    
    private func updateSecondaryLabel(with bodyPart: List<String>, equipmentType: String) {
        let bodyPartString = bodyPart.map { $0.localized }.joined(separator: ", ")
        var secondaryString: String {
            if equipmentType == "none" {
                return bodyPartString
            } else {
                return bodyPartString + " / " + equipmentType.localized
            }
        }
        secondaryLabel.text = secondaryString
    }
    
    private func updateWeightLabel(with exerciseSets: List<ExerciseSet>) {
        let weightFloat = exerciseSets
            .filter { $0.isFinished }
            .map { $0.weight * $0.repetitionCount }
            .map { Float($0) }
            .reduce(0, +)
        
        let weightInTons = weightFloat > 999 ? weightFloat / 1000 : weightFloat
        let weightUnit = weightFloat > 999 ? "ton" : "kg"
        weightLabel.text = String(format: "%.0f", weightInTons) + " " + weightUnit
    }
    
    private func updateSetLabel(with exerciseSets: List<ExerciseSet>) {
        let setCount = exerciseSets.count
        setLabel.text = String(describing: setCount) + " set"
    }
    
    private func updateProgress(with exerciseSets: List<ExerciseSet>) {
        let setCount = exerciseSets.count
        let setFinishedCount = exerciseSets.filter { $0.isFinished }.count
        let progression = Float(setFinishedCount) / Float(setCount)
        progressLabel.text = " " + String(Int(progression * 100)) + "%"
        DispatchQueue.main.async {
            self.progressView.setProgress(progression, animated: true)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressView.setProgress(0, animated: true)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    private func configureUI() {
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

extension WorkoutListTableViewCell {
    
}
