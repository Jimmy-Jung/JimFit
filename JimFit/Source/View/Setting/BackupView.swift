//
//  BackupView.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/25.
//

import UIKit

final class BackupView: UIView {
    private lazy var backupView: UIView = UIView()
        .backgroundColor(.secondarySystemGroupedBackground)
        .cornerRadius(K.Size.cellRadius)
    
    private lazy var backupImageBackView: UIView = UIView()
        .backgroundColor(K.Color.Primary.Mint)
        .cornerRadius(K.Size.cellRadius)
    
    private lazy var backupImage: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "arrow.counterclockwise.circle")?
            .renderingColor(.paletteColors([.white, .clear]))
            .font(.systemFont(ofSize: 80, weight: .regular))
        $0.transform = CGAffineTransform(rotationAngle: 3 * CGFloat.pi / 2)
        $0.tintColor(.white)
    }
    
    private let backupTitleLabel: UILabel = UILabel()
        .text("backup_title".localized)
        .font(K.Font.Header1)
        .textColor(K.Color.Primary.Label)
    
    private let backupMessageLabel: UILabel = UILabel()
        .text("backup_message".localized)
        .textAlignment(.center)
        .numberOfLines(0)
        .font(K.Font.Body2)
        .textColor(K.Color.Primary.Label)
    
    private lazy var descriptionStackView: UIStackView = UIStackView()
        .addArrangedSubview(backupImageBackView)
        .addArrangedSubview(backupTitleLabel)
        .addArrangedSubview(backupMessageLabel)
        .axis(.vertical)
        .spacing(10)
        .alignment(.center)
        .distribution(.fill)
    
    let backupButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .baseBackgroundColor(K.Color.Primary.Blue)
        .image(UIImage(systemName: "externaldrive.badge.plus"))
        .imagePlacement(.leading)
        .imagePadding(8)
        .titleWithFont(title: "backup".localized, font: K.Font.Header2)
        .cornerRadius(K.Size.cellRadius)
    
    let restoreButton = UIButton(configuration: .filled())
        .baseForegroundColor(K.Color.Primary.White)
        .baseBackgroundColor(K.Color.Primary.Green)
        .image(UIImage(systemName: "externaldrive.badge.timemachine"))
        .imagePlacement(.leading)
        .imagePadding(8)
        .titleWithFont(title: "restore".localized, font: K.Font.Header2)
        .cornerRadius(K.Size.cellRadius)
    
    private lazy var buttonStackView: UIStackView = UIStackView()
        .axis(.horizontal)
        .alignment(.fill)
        .distribution(.fill)
        .spacing(10)
        .addArrangedSubview(backupButton)
        .addArrangedSubview(restoreButton)
    
    lazy var noBackupView: UIView = UIView()
    
    private lazy var noBackupImage: UIImageView = UIImageView()
        .image(
            UIImage(systemName: "externaldrive.badge.questionmark")?
            .font(.systemFont(ofSize: 80, weight: .medium))
        )
        .tintColor(K.Color.Grayscale.Label)
    
    private let titleLabel: UILabel = UILabel()
        .text("no_backup".localized)
        .font(K.Font.Header1)
        .textColor(K.Color.Grayscale.Label)
    
    private lazy var noBackupStackView: UIStackView = UIStackView()
        .addArrangedSubview(noBackupImage)
        .addArrangedSubview(titleLabel)
        .axis(.vertical)
        .spacing(10)
        .alignment(.center)
        .distribution(.fill)
    
               
    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.sectionHeaderTopPadding = 0
        table.backgroundColor(.clear)
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.systemGroupedBackground)
        
        addSubView(backupView)
        backupView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        backupView.addSubView(descriptionStackView)
        descriptionStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        backupImageBackView.addSubView(backupImage)
        backupImage.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-18)
        }
        
        addSubView(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(backupView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        addSubView(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        tableView.addSubView(noBackupView)
        noBackupView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        noBackupView.addSubView(noBackupStackView)
        noBackupStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
