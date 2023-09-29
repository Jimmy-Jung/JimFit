//
//  AddButtonTableViewCell.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

final class AddButtonTableViewCell: UITableViewCell {
    
    enum State {
        case addList
        case addSet
    }
    
    private lazy var addButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .cornerRadius(16)
        .isUserInteractionEnabled(false)
    
    func primaryButtonSet(state: State) {
        switch state {
        case .addList:
            addButton
                .baseBackgroundColor(K.Color.Primary.Orange)
                .titleWithFont(title: "+  운동 리스트 추가", font: K.Font.Header2)
        case .addSet:
            addButton
                .baseBackgroundColor(K.Color.Grayscale.Background)
                .titleWithFont(title: "+  운동 세트 추가", font: K.Font.Header2)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            self.addButton.isEnabled(!selected)
    }
    
}
