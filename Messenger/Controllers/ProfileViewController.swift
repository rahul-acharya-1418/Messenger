//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    
    /// Log Out row in table view at Profile tab bar
    /// - Parameters:
    ///   - tableView: Profile table view
    ///   - indexPath: selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // MARK: - Simple Alert pop up UpSideDown
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        
        // MARK: - LogOut button action
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            // log out facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            
            // log out firebase
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to Log Out")
            }
        }))
        // Simple cancel button
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
        
    }
    
    
}
