//
//  LoginViewController.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD()
        spinner.textLabel.text = "Loading"
        spinner.detailTextLabel.text = "Please Wait"
        return spinner
    }()
    
    /// ScrollView
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    /// APP Logo Image View
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// Email Text Field
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    /// Password Text Field
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    /// Login Button
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleLogInButton = GIDSignInButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(didTapRegister))
        // Login Button Action
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        // Text Field Delegate Methods
        emailField.delegate = self
        passwordField.delegate = self
        // FaceBook Delegate Methods
        facebookLoginButton.delegate = self
        // Add subView
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLogInButton)
        googleLogInButton.addTarget(self, action: #selector(handleSignInWithGoogle), for: .touchUpInside)
        
        
        
    }
    
    
    /// LayOut of all views in Screen
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        // General Size
        let size = scrollView.width/3
        // App Logo Image View LayOut
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        // Email Text Field View LayOut
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+50,
                                  width: scrollView.width-60,
                                  height: 52)
        // Password Text Field View LayOut
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        // Login Button View Layout
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        // FaceBook Sign-In Button View Layout
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+10,
                                           width: scrollView.width-60,
                                           height: 52)
        //        facebookLoginButton.frame.origin.y = loginButton.bottom+20
        googleLogInButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-60,
                                         height: 52)
        
    }
    
    /// Login Button OBJC #SELECTOR method to Check email and password exist in FireBase database
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with Email: \(email)")
                return
            }
            let user = result.user
            print("Logged in User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    /// alert Function for Empty Text Fields
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to log in...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    /// Navigation Right side button (Register) #Selector Method
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        print("test")
    }
    
}

// Text Field Delegate Extension
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

// MARK: - Google Sign in 
extension LoginViewController {
    @objc fileprivate func handleSignInWithGoogle() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { gidUser, error in
            if let error = error {
                print("Sign In Error \(String(describing: error))")
                return
            }
            guard let authentication = gidUser?.user.idToken?.tokenString, let accesstoken = gidUser?.user.accessToken.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: authentication, accessToken: accesstoken)
            
            
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                guard let user = authResult?.user, error == nil else { return }
                print("emailID: \(String(describing: user.email))")
                print("DisplayName: \(String(describing: user.displayName))")
                
                guard let email = user.email,let userName = user.displayName else { return }
                
                let nameComponent = userName.components(separatedBy: " ")
                
                let firstName = nameComponent[0]
                let secondName = nameComponent[1]
                
                DatabaseManager.shared.userExists(with: email) { exists in
                    if !exists {
                        let chatUser = ChatAppUser(firstName: firstName,
                                                   lastName: secondName,
                                                   emailAddress: email)
                        DatabaseManager.shared.insertUser(with: chatUser) { success in
                            if success {
                                // upload image
                                
                                
                                if ((gidUser?.user.profile?.hasImage) != nil) {
                                    guard let url = gidUser?.user.profile?.imageURL(withDimension: 200) else {
                                        return
                                    }
                                    
                                    URLSession.shared.dataTask(with: url) { data, _, _ in
                                        
                                        guard let data = data else {
                                            return
                                        }
                                        let filename = chatUser.profilePictureFileName
                                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { results in
                                            switch results {
                                            case .success(let downloadUrl):
                                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                                print(downloadUrl)
                                            case .failure(let error):
                                                print("Storage Manager Error \(error)")
                                            }
                                            
                                        })
                                    }.resume()
                                }
                            }
                        }
                    }
                }
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
}

// FaceBook Login Button Extension
extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no Operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields":
                                                                        "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil, httpMethod: .get)
        
        facebookRequest.start { _, result, error in
            guard let safeResult = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request \(String(describing: error))")
                return
            }
            print("\(safeResult)")
            
            guard let firstName = safeResult["first_name"] as? String,
                  let lastName = safeResult["last_name"] as? String,
                  let email = safeResult["email"] as? String,
                  let picture = safeResult["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                      print("Failed to get email and name from fb results")
                      return
                  }
            
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading Data from Facebook Image")
                            
                            URLSession.shared.dataTask(with: url) { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                print("Got data from fb, uploading")
                                // upload image
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { results in
                                    switch results {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage Manager Error \(error)")
                                    }
                                })
                            }.resume()
                        }
                    }
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    print("FaceBook Credential login Failed, MFA may be needed and Error is--> \(String(describing: error))")
                    return
                }
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
            
            
        }
    }
}
