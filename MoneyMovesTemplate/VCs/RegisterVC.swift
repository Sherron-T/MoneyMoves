import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class RegisterVC: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeDarkMode()
    }
    
    @IBAction func pressedRegister(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmField.text,
              let name = nameField.text,
              email.count > 0,
              password.count > 0,
              confirmPassword.count > 0,
              name.count > 0,
              passwordField.text! == confirmField.text!
        else {
            if (passwordField.text! != confirmField.text!){
                let alert = UIAlertController(
                  title: "Sign Up failed",
                  message: "Passwords do not match.",
                  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(
                  title: "Sign Up failed",
                  message: "Please fill all fields.",
                  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(
                  title: "Sign Up failed",
                  message: error.localizedDescription,
                  preferredStyle: .alert)
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                let newEntry: [String: String] = ["user": self.emailField.text!, "name": self.nameField.text!, "budget": "1000", "picturePath": "placeholder"]
                self.ref.child(user!.user.uid).setValue(newEntry)
                self.emailField.text = nil
                self.passwordField.text = nil
                self.confirmField.text = nil
                self.nameField.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelRegister(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
