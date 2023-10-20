//
//  UIViewController+Extension.swift
//  JimFit
//
//  Created by 정준영 on 2023/10/12.
//

import UIKit

extension UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        doneTitle: String? = "done".localized,
        cancelTitle: String? = "cancel".localized,
        doneHandler: ((UIAlertAction) -> Void)? = nil,
        cancelHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let doneAction = UIAlertAction(title: doneTitle, style: .destructive, handler: doneHandler)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: cancelHandler)
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func setNavigationBarAppearance(backgroundColor: UIColor = K.Color.Grayscale.SecondaryBackground) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = backgroundColor
        navigationBarAppearance.shadowColor = nil
        
        let attribute :[NSAttributedString.Key: Any] = [NSAttributedString.Key.font : K.Font.Header1]
        navigationBarAppearance.titleTextAttributes = attribute
        navigationController?.navigationBar.tintColor = .label
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
}
