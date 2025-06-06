//
//  SignUpViewController.swift
//  FirebaseApp
//
//  Created by Mañanas on 4/6/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var conditionsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        birthdayDatePicker.maximumDate = maxDate
    }
    
    func validate() -> Bool {
        if firstNameTextField.text?.isEmpty ?? true {
            showValidationError("First name cannot be empty!")
            return false
        }
        if lastNameTextField.text?.isEmpty ?? true {
            showValidationError("Last name cannot be empty!")
            return false
        }
        if usernameTextField.text?.isEmpty ?? true {
            showValidationError("Username cannot be empty!")
            return false
        }
        if (passwordTextField.text?.count ?? 0) < 6 {
            showValidationError("Pasword must have 6 or more characters!")
            return false
        }
        if (passwordTextField.text != repeatPasswordTextField.text) {
            showValidationError("Repeat password must match password!")
            return false
        }
        return true
    }
    
    func showValidationError(_ error: String) {
        let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func signUp(_ sender: Any) {
        if (validate()) {
            let username = usernameTextField.text ?? ""
            let password = passwordTextField.text ?? ""
            
            Auth.auth().createUser(withEmail: username, password: password) { [unowned self] authResult, error in
                if let error = error {
                    // Hubo un error
                    print(error)
                    
                    let alertController = UIAlertController(title: "Create user", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Todo correcto
                    print("User signs up successfully")
                    
                    createUser()
                }
            }
        }
    }
    
    func createUser() {
        let userID = Auth.auth().currentUser!.uid
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthday = birthdayDatePicker.date
        let gender = switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            Gender.male
        case 1:
            Gender.female
        default:
            Gender.other
        }
        
        let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: birthday, provider: .basic)
        
        do {
            let db = Firestore.firestore()
            
            try db.collection("Users").document(userID).setData(from: user)
            
            let alertController = UIAlertController(title: "Create user", message: "User signs up successfully", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
            
            let alertController = UIAlertController(title: "Create user", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func genderSegmentedControl(_ sender: Any) {
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            genderImageView.image = UIImage(named: "genderIcon-male")
        case 1:
            genderImageView.image = UIImage(named: "genderIcon-female")
        default:
            genderImageView.image = UIImage(named: "genderIcon-other")
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
