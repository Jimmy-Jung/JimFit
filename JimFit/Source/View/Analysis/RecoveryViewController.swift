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
    
    private func setupUI() {
        view.backgroundColor(.systemBackground)
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
//        viewModel.frontImagePublisher
//            .subscribe(onNext: { [weak self] image in
//                print(image)
//                self?.recoveryView.frontImageView.image = image
//            })
//            .disposed(by: disposeBag)
        
        viewModel.loadingProgressStatePublisher
            .subscribe(onNext: { [weak self] state in
                print(state)
                if state {
                    self?.recoveryView.loadingProgressView.startAnimating()
                } else {
                    self?.recoveryView.loadingProgressView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
}
