//
//  ExerciseSetTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/03.
//

import UIKit

final class ExerciseSetTableViewCell: UITableViewCell {
    
    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
    
    private let setNumberLabel = UILabel()
        .text("Set")
        .textAlignment(.center)
        .backgroundColor(K.Color.Grayscale.Tint)
        .textColor(.white)
        .font(K.Font.SubHeader)
        .cornerRadius(16)
        .clipsToBounds(true)
    
    private let kgLabel = UILabel()
        .text("kg")
        .font(K.Font.SubHeader)
    
    private let repsLabel = UILabel()
        .text("reps")
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
        
        borderView.addSubview(kgLabel)
        kgLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.centerX.equalToSuperview().offset(18)
            make.height.equalTo(45)
//            make.width.equalTo(75)
        }
        
        borderView.addSubview(repsLabel)
        repsLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(45)
//            make.width.equalTo(75)
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
