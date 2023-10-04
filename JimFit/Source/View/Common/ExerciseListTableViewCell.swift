//
//  ExerciseListTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit
import RealmSwift

class ExerciseListTableViewCell: UITableViewCell {
    
    var exercise: Exercise? {
        didSet {
            guard let exercise else { return }
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
            titleLabel.text(exercise.exerciseName)
            secondaryLabel.text(secondaryString)
            likeButton.isSelected = exercise.liked
            setupLikeButtonColor()
        }
    }
    
    weak var delegate: LikeUpdateDelegate?

    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
 
    let titleLabel = UILabel()
        .font(K.Font.CellHeader)
        .numberOfLines(2)
        .textColor(K.Color.Primary.Label)
    
    let secondaryLabel = UILabel()
        .font(K.Font.CellBody)
        .numberOfLines(2)
        .textColor(K.Color.Grayscale.Label)
    
    lazy var likeButton: UIButton = UIButton(configuration: .plain())
        .setImage(UIImage(systemName: "heart"), for: .normal)
        .setImage(UIImage(systemName: "heart.fill"), for: .selected)
        .baseForegroundColor(K.Color.Grayscale.border_Medium)
        .baseBackgroundColor(.clear)
        .addAction { [unowned self] in
            likeButtonTapped()
        }
    
   
    private lazy var titleStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(4)
        .addArrangedSubview(titleLabel)
        .addArrangedSubview(secondaryLabel)
    
   
    private lazy var horizontalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(titleStackView)
        .addArrangedSubview(likeButton)
    
    private func likeButtonTapped() {
        likeButton.isSelected.toggle()
        UIView.transition(with: likeButton, duration: 0.15, options: [.transitionCrossDissolve, .curveEaseInOut]) {
            self.setupLikeButtonColor()
        }
        let realm: Realm! = RealmManager.shared.realm
        let memoryRealm: Realm! = RealmManager.shared.memoryRealm
        guard let exercise else { return }
        if let update = realm.object(ofType: Exercise.self, forPrimaryKey: exercise.reference) {
            try! realm.write {
                update.liked = likeButton.isSelected
            }
        }
        if let update = memoryRealm.object(ofType: Exercise.self, forPrimaryKey: exercise.reference) {
            try! memoryRealm.write {
                update.liked = likeButton.isSelected
            }
        }
        delegate?.updateLike()
    }
    
    private func setupLikeButtonColor() {
        if self.likeButton.isSelected {
            self.likeButton.baseForegroundColor(.red)
        } else {
            self.likeButton.baseForegroundColor(K.Color.Grayscale.border_Medium)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text(nil)
        secondaryLabel.text(nil)
        likeButton.isSelected = false
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
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.equalTo(likeButton.snp.height)
        }

        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            borderView.backgroundColor(K.Color.Grayscale.Selected)
        } else {
            borderView.backgroundColor(.clear)
        }
    }


}
