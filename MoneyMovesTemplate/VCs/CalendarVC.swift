//
//  CalendarVC.swift
//  MoneyMoves
//
//  Created by Sherron Thomas on 10/4/21.
//

import UIKit

class CalendarVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
