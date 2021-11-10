//
//  TabBarController.swift
//  MoneyMoves
//
//  Created by Sherron Thomas on 10/4/21.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDarkMode()
    }
    
    func changeDarkMode() {
        let darkModeSetting = defaults.bool(forKey: "darkMode")
        if darkModeSetting {
            self.overrideUserInterfaceStyle = .dark
        } else {
            self.overrideUserInterfaceStyle = .light
        }
    }
}
