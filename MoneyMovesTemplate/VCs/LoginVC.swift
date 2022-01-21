import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginVC: UIViewController {
    
    @IBOutlet weak var pngegg: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1,
                              delay: 0.2,
                            options: [.repeat, .autoreverse, .curveEaseInOut],
                       animations: { self.pngegg.transform = self.pngegg.transform.translatedBy(x: 50, y: 0)},
                       completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeDarkMode()
        Auth.auth().addStateDidChangeListener() {
          auth, user in
          if user != nil {
              self.emailField.text = nil
              self.passwordField.text = nil
              self.ref.child(Auth.auth().currentUser!.uid).child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                  defaults.set(snapshot.value, forKey: "userName")
                  defaults.set(Auth.auth().currentUser!.uid, forKey: "userID")
              })
              self.ref.child(Auth.auth().currentUser!.uid).child("budget").observeSingleEvent(of: .value, with: { (snapshot) in
                  defaults.set(snapshot.value, forKey: "userBudget")
              })
              self.ref.child(Auth.auth().currentUser!.uid).child("picturePath").observeSingleEvent(of: .value, with: { (snapshot) in
                  defaults.set(snapshot.value, forKey: "userImage")
              })
              self.performSegue(withIdentifier: "loginSegue", sender: nil)
          }
        }
    }
    
    @IBAction func pressedLogin(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text,
              email.count > 0,
              password.count > 0
        else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {
          user, error in
          if let error = error, user == nil {
                let alert = UIAlertController(
                  title: "Sign in failed",
                  message: error.localizedDescription,
                  preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            }
        }
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
