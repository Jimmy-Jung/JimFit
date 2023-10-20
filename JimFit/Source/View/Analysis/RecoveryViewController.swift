//
//  RecoveryViewController.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/19.
//

import UIKit
import RxSwift

final class RecoveryViewController: UIViewController {
    private let recoveryView = RecoveryView()
    private var viewModel = RecoveryViewModel()
    private let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.binding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recoveryView.progressBar.setProgress(1, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor(K.Color.Primary.Background)
        view.addSubview(recoveryView)
        recoveryView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        viewModel.frontImagePublisher
            .bind(to: recoveryView.frontImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.backImagePublisher
            .bind(to: recoveryView.backImageView.rx.image)
            .disposed(by: disposeBag)
        viewModel.targetImagesPublisher
            .bind(to: recoveryView.collectionView.rx.items(
                cellIdentifier: RecoveryCollectionViewCell.identifier,
                cellType: RecoveryCollectionViewCell.self
            )) { index, item, cell in
                cell.targetInfo = item
            }
            .disposed(by: disposeBag)
        
        viewModel.fatiguePublisher
            .subscribe(onNext: { [weak self] in
                self?.recoveryView.progressBar.setProgress($0, animated: true)
                self?.recoveryView.progressLabel.text(String(Int($0*100)) + "%")
            })
            .disposed(by: disposeBag)
    }
    
}
