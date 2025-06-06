//
//  ViewController.swift
//  FirebaseApp
//
//  Created by Mañanas on 2/6/25.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dignUp(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        Auth.auth().createUser(withEmail: username, password: password) { [unowned self] authResult, error in
        self
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth() .signIn(withEmail: username, password: password) { [unowned self] authResult, error in
        self
        }
    }
}

