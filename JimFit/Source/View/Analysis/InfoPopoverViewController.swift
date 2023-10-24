//
//  InfoPopoverViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/23.
//

import UIKit

final class InfoPopoverViewController: UIViewController {
    private let scrollView: UIScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.cornerRadius(K.Size.cellRadius)
        $0.clipsToBounds(true)
        $0.backgroundColor(K.Color.Grayscale.Background)
    }
    private lazy var dismissButton: UIButton = UIButton(configuration: .plain())
        .image(K.Image.Xmark)
        .baseForegroundColor(.white)
        .addAction { [weak self] in
            HapticsManager.shared.vibrateForSelection()
            self?.dismiss(animated: true, completion: nil)
        }
     
    private let contentView: UIView = UIView()
    
    private let titleLabel: UILabel = UILabel()
        .font(K.Font.Header1)
        .numberOfLines(2)
        .text("recovery_info_title".localized)
    
    private let messageLabel: UILabel = UILabel()
        .font(K.Font.Body1)
        .numberOfLines(0)
        .text("recovery_info_message".localized)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        view.addSubview(dismissButton)
        
        scrollView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview().inset(40)
            make.height.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(-16)
            make.trailing.equalTo(scrollView).offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(scrollView).inset(20)
            make.centerX.equalTo(view)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.width.equalTo(scrollView).inset(20)
            make.centerX.equalTo(view)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
