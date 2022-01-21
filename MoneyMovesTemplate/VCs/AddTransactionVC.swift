import CoreData
import UIKit
import AVFoundation
import AVKit

class AddTransactionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelField: UITextField!
    @IBOutlet weak var moneyField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    static let instance = AddTransactionVC()
    let kCategories = "categories"
    let defaults = UserDefaults.standard
    
    var defaultCategories: [String] = ["Food", "Utilities", "Shopping"]
    var category: String = ""
    var soundPlayer: AVAudioPlayer?
    var userCategories: [String] = []
    var amount: Int = 0
    
    func playSound() {
        let url = Bundle.main.url(forResource: "money", withExtension: ".mp3")
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url!)
            soundPlayer?.play()
        } catch let error {
            print("error playing sound. \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        moneyField.delegate = self
        moneyField.placeholder = updateAmount()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int (string) {
            amount = amount * 10 + digit
            moneyField.text = updateAmount()
        }
        if string == "" {
            amount = amount / 10
            moneyField.text = updateAmount()
        }
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amount/100) + Double(amount%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        picker.reloadAllComponents()
        let checkCategories = defaults.object(forKey: kCategories)
        if checkCategories == nil {
            defaults.set(defaultCategories,forKey: kCategories)
        }
        userCategories = defaults.object(forKey: kCategories) as! [String]
        self.tabBarController?.tabBar.isHidden = true
        category = userCategories[0]
        changeDarkMode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func pressedSubmit(_ sender: Any) {
        if labelField.text! == "" {
            let alert = UIAlertController(
              title: "Inavlid Entry",
              message: "Enter transaction label.",
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
        }
        else if moneyField.text! == "" {
            let alert = UIAlertController(
              title: "Inavlid Entry",
              message: "Enter cost of transaction.",
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
        }
        else if amount == 0 {
            let alert = UIAlertController(
              title: "Inavlid Entry",
              message: "Enter valid cost of transaction.",
              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style:.default))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let cost = Double(amount/100) + Double(amount%100)/100
            storeEntry(entryDate: datePicker.date, entryLabel: labelField.text!, entryCost: cost, entryCategory: category)
            if defaults.bool(forKey: "soundEffects") {
                AddTransactionVC.instance.playSound()
            }            
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }
    
    func storeEntry(entryDate: Date, entryLabel: String, entryCost: Double, entryCategory: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newEntry = NSEntityDescription.insertNewObject(
            forEntityName: "Transaction", into: context)
        newEntry.setValue(entryDate, forKey: "date")
        newEntry.setValue(entryLabel, forKey: "label")
        newEntry.setValue(entryCost, forKey: "money")
        newEntry.setValue(entryCategory, forKey: "category")
        
        do {
            try context.save()
        } catch {
            // If an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return userCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category = userCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.font = UIFont(name: "Avenair-Light", size: 16.0)
        label.text = userCategories[row]
        return label
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alert = UIAlertController(title: "Add Category",
                                      message: "Enter new category",
                                      preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) { [self] _ in
            let textCategory = alert.textFields![0].text!
            print(textCategory)
            userCategories.append(textCategory)
            defaults.set(userCategories,forKey: kCategories)
            userCategories = defaults.object(forKey: kCategories) as! [String]
            self.picker.reloadAllComponents()
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alert.addTextField { textCategory in
            textCategory.placeholder = "Category name"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
}
