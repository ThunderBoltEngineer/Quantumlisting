//
//  MainTabBarController.swift
//  QuantumListing
//
//  Created by Paradise on 2018/08/19.
//  Copyright © 2018 lucky clover. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let viewControllers = viewControllers,
            let activeViewController = viewControllers[selectedIndex] as? UIViewController,
            let activeNavigationController = activeViewController as? UINavigationController {
            activeNavigationController.popToRootViewController(animated: false)
        }
    }
}
