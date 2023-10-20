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
        firstVC.title = "workout_log".localized
        firstVC.tabBarItem.image = K.Image.Calendar
        firstVC.tabBarItem.title = nil
        
        let secondVC = RecoveryViewController()
        let secondNav = UINavigationController(rootViewController: secondVC)
        secondVC.title = "analysis".localized
        secondVC.tabBarItem.image = K.Image.ChartPie
        secondVC.tabBarItem.title = nil
        setViewControllers([firstNav, secondNav], animated: true)
    }
    
    private func setupTabBarController() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance
    }
    
    private func configureTabBarShadow() {
        tabBar.layer.shadowColor = UIColor.label.cgColor
        tabBar.layer.shadowOffset = .init(width: 0, height: -0.5)
        tabBar.layer.shadowOpacity = 0.2
        tabBar.layer.shadowRadius = 0.5
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tabBar.layer.shadowColor = UIColor.label.cgColor
        }
    }

}
