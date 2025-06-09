//
//  ProfileViewController.swift
//  FirebaseApp
//
//  Created by Mañanas on 6/6/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    
    // MARK: Properties
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserData()
    }
    
    func getUserData() {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        
        let docRef = db.collection("Users").document(userID)

        Task {
            do {
                user = try await docRef.getDocument(as: User.self)
                
                DispatchQueue.main.async {
                    self.firstNameTextField.text = self.user.firstName
                    self.lastNameTextField.text = self.user.lastName
                    self.usernameTextField.text = self.user.username
                    self.birthdayDatePicker.date = self.user.birthday ?? Date()
                    self.genderSegmentedControl.selectedSegmentIndex = switch self.user.gender {
                    case .male: 0
                    case .female: 1
                    default: 2
                    }
                }
            } catch {
                print("Error decoding user: \(error)")
            }
        }
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
        return true
    }
    
    func showValidationError(_ error: String) {
        let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateUser(_ sender: Any) {
        if (validate()) {
            let userID = Auth.auth().currentUser!.uid
            user.firstName = firstNameTextField.text!
            user.lastName = lastNameTextField.text!
            user.birthday = birthdayDatePicker.date
            user.gender = switch genderSegmentedControl.selectedSegmentIndex {
            case 0:
                Gender.male
            case 1:
                Gender.female
            default:
                Gender.other
            }
            
            do {
                let db = Firestore.firestore()
                
                try db.collection("Users").document(userID).setData(from: user)
                
                let alertController = UIAlertController(title: "Update profile", message: "Profile updated successfully", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
            } catch let error {
                print("Error writing user to Firestore: \(error)")
                
                let alertController = UIAlertController(title: "Update profile", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
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
