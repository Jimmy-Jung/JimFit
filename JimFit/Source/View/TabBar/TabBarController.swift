//
//  TabBarController.swift
//  JimFit
//
//  Created by 정준영 on 2023/09/27.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = K.Color.Primary.Label
        tabBar.backgroundColor(.systemBackground)
        configureTabBarController()
        setupTabBarController()
        configureTabBarShadow()
    }
    
    private func configureTabBarController() {
        let firstVC = WorkoutLogViewController()
        let firstNav = UINavigationController(rootViewController: firstVC)
        firstVC.title = "운동 기록"
        firstVC.tabBarItem.image = UIImage(systemName: "checklist.checked")
        firstVC.tabBarItem.title = "기록"
        let vc = UIViewController()
        vc.view.backgroundColor(.systemBackground)
        vc.title = "AS"
        let nav = UINavigationController(rootViewController: vc)
        
        setViewControllers([firstNav, nav], animated: true)
    }
    
    private func setupTabBarController() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance
    }
    
    private func configureTabBarShadow() {
        tabBar.layer.shadowColor = UIColor.label.cgColor
        tabBar.layer.shadowOffset = .init(width: 0, height: -1)
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowRadius = 4
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.layer.shadowColor = UIColor.label.cgColor
        }
    }

}
