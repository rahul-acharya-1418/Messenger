//
//  AppDelegate.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // FireBase Configure
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                 // Show the app's signed-out state.
//                GIDSignIn.sharedInstance.signOut()
               } else {
                   guard let auth = user?.idToken?.tokenString, let accessToken = user?.accessToken.tokenString else { return }
                   let credential = GoogleAuthProvider.credential(withIDToken: auth, accessToken: accessToken)
                   
               }
        }
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return GIDSignIn.sharedInstance.handle(url)
    }
}



