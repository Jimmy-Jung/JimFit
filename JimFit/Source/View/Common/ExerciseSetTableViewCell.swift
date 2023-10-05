//
//  ExerciseSetTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit

final class ExerciseSetTableViewCell: UITableViewCell {
    
    func configureCell(with exerciseSet: ExerciseSet, index: Int) {
        self.setNumberLabel.text("Set \(index + 1)")
        self.setNumberLabel.backgroundColor(exerciseSet.isFinished ? K.Color.Primary.Orange : K.Color.Grayscale.Tint)
        self.weighTextField.text(String(describing: exerciseSet.weight))
        self.repsTextField.text(String(describing: exerciseSet.repetitionCount))
    }
    
    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
    
    private let setNumberLabel = UILabel()
        .text("Set")
        .textAlignment(.center)
        .backgroundColor(K.Color.Grayscale.Tint)
        .textColor(.white)
        .font(K.Font.SubHeader)
        .cornerRadius(14)
        .clipsToBounds(true)
    
    func doneSet() {
        setNumberLabel.backgroundColor(K.Color.Primary.Orange)
    }
    
    private let weightLabel = UILabel()
        .text("kg")
        .font(K.Font.SubHeader)
    
    private let weighTextField = UITextField()
        .placeholder("0")
        .textAlignment(.right)
        .font(K.Font.SubHeader)
    
    private let repsLabel = UILabel()
        .text("reps")
        .font(K.Font.SubHeader)
    
    private let repsTextField = UITextField()
        .placeholder("0")
        .textAlignment(.right)
        .font(K.Font.SubHeader)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(53)
        }
        
        borderView.addSubview(setNumberLabel)
        setNumberLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalToSuperview().inset(4)
            make.height.equalTo(45)
            make.width.equalTo(75)
        }
        
        borderView.addSubview(weightLabel)
        weightLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.centerX.equalToSuperview().offset(16)
            make.height.equalTo(45)
        }
        
        borderView.addSubview(weighTextField)
        weighTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.height.equalTo(45)
//            make.leading.equalTo(setNumberLabel.snp.trailing).offset(8)
            make.trailing.equalTo(weightLabel.snp.leading).offset(-4)
        }
        
        borderView.addSubview(repsLabel)
        repsLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(45)
        }
        
        borderView.addSubview(repsTextField)
        repsTextField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.height.equalTo(45)
//            make.leading.equalTo(weightLabel.snp.trailing).offset(8)
            make.trailing.equalTo(repsLabel.snp.leading).offset(-4)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
