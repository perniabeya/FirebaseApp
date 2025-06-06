//
//  ViewController.swift
//  FirebaseApp
//
//  Created by Mañanas on 2/6/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: username, password: password) { [unowned self] authResult, error in
            if let error = error {
                // Hubo un error
                print(error)
                
                let alertController = UIAlertController(title: "Sign In", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
            } else {
                // Todo correcto
                print("User signs in successfully")
                
                goToHome()
            }
        }
    }
    
    @IBAction func signInGoogle(_ sender: Any) {
        // Configure Google SignIn with Firebase
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("Cannot get user token from Google")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [unowned self] result, error in
                if let error = error {
                    // Hubo un error
                    print(error)
                    
                    let alertController = UIAlertController(title: "Sign In", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Todo correcto
                    print("User signs in successfully")
                    
                    // At this point, our user is signed in
                    Task {
                        await self.createUser(googleUser: user)
                        
                        DispatchQueue.main.async {
                            self.goToHome()
                        }
                    }
                }
            }
        }
    }
    
    func createUser(googleUser: GIDGoogleUser) async {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if !document.exists {
                let username = googleUser.profile!.email
                let firstName = googleUser.profile!.givenName ?? googleUser.profile!.name
                let lastName = googleUser.profile!.familyName ?? ""
                //let birthday = nil
                let gender = Gender.unspecified
                let profileImageUrl = googleUser.profile!.hasImage ? googleUser.profile!.imageURL(withDimension: 200) : nil
                
                let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: nil, provider: .google, profileImageUrl: profileImageUrl?.absoluteString)
                
                do {
                    try db.collection("Users").document(userID).setData(from: user)
                } catch let error {
                    print("Error writing user to Firestore: \(error)")
                    
                    let alertController = UIAlertController(title: "Create user", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error getting document: \(error)")
            
            let alertController = UIAlertController(title: "Create user", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func goToHome() {
        self.performSegue(withIdentifier: "goToHome", sender: nil)
    }
}

