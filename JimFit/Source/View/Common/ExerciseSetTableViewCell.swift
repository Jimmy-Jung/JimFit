//
//  ExerciseSetTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit
import RealmSwift

final class ExerciseSetTableViewCell: UITableViewCell {
    let realm = RealmManager.shared.realm
    private var exerciseSet: ExerciseSet!
    func configureCell(with exerciseSet: ExerciseSet, index: Int) {
        self.exerciseSet = exerciseSet
        self.setButton.isSelected = exerciseSet.isFinished
        setButton.baseBackgroundColor(setButton.isSelected ? K.Color.Primary.Orange : K.Color.Grayscale.Tint)
        self.setButton.titleWithFont(title: "Set \(index + 1)", font: K.Font.SubHeader)
        self.weighTextField.text(String(describing: exerciseSet.weight))
        self.repsTextField.text(String(describing: exerciseSet.repetitionCount))
    }
    
    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
    
    lazy var setButton = UIButton(configuration: .filled())
        .baseForegroundColor(.white)
        .baseBackgroundColor(K.Color.Grayscale.Tint)
        .cornerRadius(14)
        .addAction { [unowned self] in
            setButtonTapped()
        }
    
    func setButtonTapped() {
        setButton.isSelected.toggle()
        setButton.baseBackgroundColor(setButton.isSelected ? K.Color.Primary.Orange : K.Color.Grayscale.Tint)
        try! realm.write {
            exerciseSet.isFinished = setButton.isSelected
        }
    }
    func doneSet() {
        setButton.backgroundColor(K.Color.Primary.Orange)
    }
    
    private let weightLabel = UILabel()
        .text("kg")
        .font(K.Font.SubHeader)
    
    lazy var weighTextField = UITextField()
        .placeholder("0")
        .textAlignment(.right)
        .font(K.Font.SubHeader)
        .keyboardType(.numberPad)
        .autocapitalizationType(.none)
        .delegate(self)
    
    private let repsLabel = UILabel()
        .text("reps")
        .font(K.Font.SubHeader)
    
    lazy var repsTextField = UITextField()
        .placeholder("0")
        .textAlignment(.right)
        .font(K.Font.SubHeader)
        .keyboardType(.numberPad)
        .autocapitalizationType(.none)
        .delegate(self)
        

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(53)
        }
        
        borderView.addSubview(setButton)
        setButton.snp.makeConstraints { make in
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
            make.trailing.equalTo(weightLabel.snp.leading).offset(-4)
            make.width.greaterThanOrEqualTo(80)
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
            make.trailing.equalTo(repsLabel.snp.leading).offset(-4)
            make.width.greaterThanOrEqualTo(80)
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

extension ExerciseSetTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty, let numberText = Int(text) else { return }
        if textField == weighTextField {
            try! realm.write {
                exerciseSet.weight = numberText
            }
        } else {
            try! realm.write {
                exerciseSet.repetitionCount = numberText
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only digits from 0 to 9
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        let input = (textField.text as NSString?) ?? ""
        let newString = input.replacingCharacters(in: range, with: string)
        let intValue = Int(newString) ?? 0
        
        // 999보다 크면 안됨
        if textField == weighTextField {
            if intValue > 999 {
                textField.text = "999"
                return false
            }
        } else { // 100보다 크면 안됨
            if intValue > 100 {
                textField.text = "100"
                return false
            }
        }
        
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
