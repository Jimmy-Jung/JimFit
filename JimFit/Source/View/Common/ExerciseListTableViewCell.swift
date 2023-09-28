//
//  ExerciseListTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit

class ExerciseListTableViewCell: UITableViewCell {

    private let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
        .setBorder(color: K.Color.Grayscale.border_Thin, width: K.Size.border_Thin)
 
    let titleLabel = UILabel()
        .text("BarBell Bench Press as BarBell Bench Press")
        .font(K.Font.CellHeader)
        .numberOfLines(2)
        .textColor(K.Color.Primary.Label)
    
    let secondaryLabel = UILabel()
        .text("Chest")
        .font(K.Font.CellBody)
        .numberOfLines(2)
        .textColor(K.Color.Grayscale.Label)
    
    lazy var likeButton: UIButton = UIButton(configuration: .plain())
        .setImage(UIImage(systemName: "heart"), for: .normal)
        .setImage(UIImage(systemName: "heart.fill"), for: .selected)
        .baseForegroundColor(K.Color.Grayscale.border_Medium)
        .baseBackgroundColor(.clear)
        .addAction { [unowned self] in
            isChecked.toggle()
        }
    
   
    private lazy var titleStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fillProportionally)
        .addArrangedSubview(titleLabel)
        .addArrangedSubview(UIView())
        .addArrangedSubview(secondaryLabel)
        .addArrangedSubview(UIView())
    
   
    private lazy var horizontalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(titleStackView)
        .addArrangedSubview(likeButton)
    
    private var isChecked: Bool = false {
        didSet {
            UIView.transition(with: likeButton, duration: 0.15, options: [.transitionCrossDissolve, .curveEaseInOut]) {
                if self.isChecked {
                    self.likeButton.isSelected = true
                    self.likeButton.baseForegroundColor(.red)
                } else {
                    self.likeButton.isSelected = false
                    self.likeButton.baseForegroundColor(K.Color.Grayscale.border_Medium)
                }
            }
        }
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
            make.height.equalTo(60)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(50)
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
