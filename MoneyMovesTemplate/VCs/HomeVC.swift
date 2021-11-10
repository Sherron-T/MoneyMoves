//
//  HomeVC.swift
//  MoneyMoves
//
//  Created by Sherron Thomas on 10/4/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class HomeVC: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.welcomeLabel.text = "Hi \(defaults.string(forKey: "userName") ?? "")"
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
