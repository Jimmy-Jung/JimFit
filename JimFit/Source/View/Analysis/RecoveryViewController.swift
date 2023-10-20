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
        recoveryView.collectionView.delegate = self
        recoveryView.collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.binding()
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
    }
    
}

extension RecoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecoveryCollectionViewCell.identifier, for: indexPath)
        return cell
    }
    
    
}
