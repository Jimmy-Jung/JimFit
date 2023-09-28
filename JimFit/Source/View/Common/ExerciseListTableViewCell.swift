//
//  ExerciseListTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/28.
//

import UIKit

class ExerciseListTableViewCell: UITableViewCell {

    let borderView = UIView()
        .cornerRadius(K.Size.cellRadius)
 
    let titleLabel = UILabel()
        .text("BarBell Bench Press as BarBell Bench Press")
        .font(K.Font.CellHeader)
        .numberOfLines(2)
        .textColor(K.Color.Primary.Label)
    
    let bodyPartLabel = UILabel()
        .text("Chest")
        .font(K.Font.CellBody)
        .textColor(K.Color.Grayscale.Label)
    
    lazy var likeButton: UIButton = UIButton(configuration: .plain())
        .setImage(UIImage(systemName: "heart")?.renderingColor(.monochrome), for: .normal)
        .setImage(UIImage(systemName: "heart.fill")?.renderingColor(.monochrome), for: .selected)
        .tintColor(K.Color.Grayscale.border_Medium)
        .addAction { [unowned self] in
            isChecked.toggle()
        }
    
   
    lazy var titleStackView: UIStackView = UIStackView()
        .axis(.vertical)
        .alignment(.fill)
        .distribution(.fill)
        .addArrangedSubview(titleLabel)
        .addArrangedSubview(bodyPartLabel)
    
   
    lazy var horizontalStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(8)
        .addArrangedSubview(titleStackView)
        .addArrangedSubview(likeButton)
    
    var isChecked: Bool = false {
        didSet {
            UIView.transition(with: likeButton, duration: 0.15, options: [.transitionCrossDissolve, .curveEaseInOut]) {
                if self.isChecked {
                    self.likeButton.tintColor(.red)
                } else {
                    self.likeButton.tintColor(K.Color.Grayscale.border_Medium)
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
        
    }

}
