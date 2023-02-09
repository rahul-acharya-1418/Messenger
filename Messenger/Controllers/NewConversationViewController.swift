//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> Void)?
    
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search For Users..."
        return search
    }()
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        spinner.textLabel.text = "Loading"
        spinner.style = .dark
        spinner.detailTextLabel.text = "Please Wait"
        return spinner
    }()
    
    private var users: [[String: String]] = []
    private var results: [[String: String]] = []
    
    private var hasFetched: Bool = false
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Result"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        searchBar.becomeFirstResponder()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
    


}


// MARK: - TableView Extension
extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start Conversation
        let tarGetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(tarGetUserData)
        } 
    }
    
    
}


// MARK: - SearchBar Extension
extension NewConversationViewController: UISearchBarDelegate {
    
   
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              !text.replacingOccurrences(of: " ", with: "").isEmpty else {
                  return
              }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        self.spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        } else {
            // if not fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
            
        }
        
        
        
    }
    
    func filterUsers(with term: String) {
        
        // update the UI: either show results or show no results label
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter{
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        
        self.results = results
        
        updateUI()
        
    }
    
    
    func updateUI() {
        if results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        }else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
