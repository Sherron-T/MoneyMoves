//
//  PreferencesVC.swift
//  MoneyMoves
//
//  Created by Sherron Thomas on 10/4/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UserNotifications

let defaults = UserDefaults.standard

class PreferencesVC: UIViewController, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var darkMode: UISwitch!
    @IBOutlet weak var soundEffects: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    
    let ref = Database.database().reference()
    let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        darkMode.setOn(defaults.bool(forKey: "darkMode"), animated: true)
        soundEffects.setOn(defaults.bool(forKey: "soundEffects"), animated: true)
        notificationSwitch.setOn(defaults.bool(forKey: "notifications"), animated: true)
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        if(defaults.string(forKey: "userImage")! == "placeholder"){
            self.profileImage.image = UIImage(named: "placeholder")
        }
        else{
            Storage.storage().reference(forURL: defaults.string(forKey: "userImage") ?? "").getData(maxSize: 1 * 5000 * 5000) { data, error in
                if error != nil {
                    print("Error: Image could not download!")
                } else {
                    self.profileImage.image = UIImage(data: data!)
                }
            }
        }
    }
    
    @IBAction func notificationsEnable(_ sender: Any) {
        if notificationSwitch.isOn {
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = "Use the MoneyMoves app to track your budget!"
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = 4
            dateComponents.hour = 12
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: dateComponents, repeats: true)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString,
                        content: content, trigger: trigger)
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
               if error != nil {
                   print("ERROR")
               }
            }
        }
        else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeDarkMode()
        nameLabel.text = defaults.string(forKey: "userName")
        budgetLabel.text = "$\(defaults.string(forKey: "userBudget")!)"
    }
    
    @IBAction func darkModeSwitch(_ sender: Any) {
        if darkMode.isOn {
            defaults.set(true, forKey: "darkMode")
        } else {
            defaults.set(false, forKey: "darkMode")
        }
        changeDarkMode()
    }
    
    @IBAction func soundEffectSwitch(_ sender: Any) {
        if soundEffects.isOn {
            defaults.set(true, forKey: "soundEffects")
        } else {
            defaults.set(false, forKey: "soundEffects")
        }
    }
    
    @IBAction func selectColorButton(_ sender: Any) {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.supportsAlpha = false
        present(colorPickerVC, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        defaults.set(color.cgColor.components!, forKey: "defaultColor")
        let alertController = UIAlertController(title: "Color Changed", message: "The accent color will be changed on next launch!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func changeDarkMode() {
        let darkModeSetting = defaults.bool(forKey: "darkMode")
        if darkModeSetting {
            self.overrideUserInterfaceStyle = .dark
        } else {
            self.overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func logOutbutton(_ sender: Any) {
        do
        {
            try Auth.auth().signOut()
            self.dismiss(animated:true, completion: nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func editNameButton(_ sender: Any) {
        let alert = UIAlertController(title: "Enter New Name",
                                      message: "Update your profile's name!",
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newName = alert.textFields![0].text!
            defaults.set(newName, forKey: "userName")
            self.ref.child(defaults.string(forKey: "userID") ?? "").child("name").setValue(newName)
            nameLabel.text = defaults.string(forKey: "userName")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField { textName in
            textName.placeholder = "New name"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setBudgetButton(_ sender: Any) {
        let alert = UIAlertController(title: "Enter New Budget",
                                      message: "Update your profile's budget!",
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newBudget = alert.textFields![0].text!
            defaults.set(newBudget, forKey: "userBudget")
            self.ref.child(defaults.string(forKey: "userID") ?? "").child("budget").setValue(newBudget)
            budgetLabel.text = "$\(defaults.string(forKey: "userBudget")!)"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField { textBudget in
            textBudget.placeholder = "New budget"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoButton(_ sender: Any) {
        let controller = UIAlertController(
            title: "Select an option",
            message: "upload a new photo!",
            preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(
            title: "Choose a Photo",
            style: .default,
            handler: {(action) in self.showImagePickerController(sourceType: .photoLibrary)}))
        controller.addAction(UIAlertAction(
            title: "Take a New Photo",
            style: .default,
            handler: {(action) in self.showImagePickerController(sourceType: .camera)}))
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        present(controller, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profileImage.image = editedImage.withRenderingMode(.alwaysOriginal)
        guard let imageData = editedImage.pngData() else {
            return
        }
        storage.child("images/\(defaults.string(forKey: "userID")!)").putData(imageData, metadata: nil, completion: { _, error in
            guard error == nil else {
                print("Failed to upload")
                return
            }
            self.storage.child("images/\(defaults.string(forKey: "userID")!)").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                defaults.set(urlString, forKey: "userImage")
                self.ref.child(Auth.auth().currentUser!.uid).child("picturePath").setValue(urlString)
            })
        })
        dismiss(animated: true, completion: nil)
    }
    
}
