//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Rakesh Kumar on 19/11/24.
//

import UIKit

class ViewController: UIViewController {
    
    var personTitle: [Person]?
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var nameTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate).withTintColor(.white)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(plusButtonTapped))
        view.addSubview(nameTableView)
        nameTableView.delegate = self
        nameTableView.dataSource = self
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameTableView.frame = view.bounds
    }
    
    private func fetchData() {
        do{
            let data = try context.fetch(Person.fetchRequest())
            self.personTitle = data
            
            DispatchQueue.main.async {
                self.nameTableView.reloadData()
            }
            
        }catch{
            
        }
    }
    
    @objc func plusButtonTapped() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Person", message: "Enter the name of the person", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { alertAction in
            let newPerson = Person(context: self.context)
            newPerson.name = textField.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            do {
                try self.context.save()
            }catch{
                
            }
            
            self.fetchData()
            print(textField.text ?? "")
        }
        
        alert.addTextField { text in
            text.placeholder = "Enter name"
            textField = text
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personTitle?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = personTitle![indexPath.row]
        cell.textLabel?.text = data.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            // MARK: - which person to remove
            let personToRemove = self.personTitle![indexPath.row]
            
            // MARK: - Remove the person
            self.context.delete(personToRemove)
            
            // MARK: - Save the Data
            
            do{
                try self.context.save()
            }catch{
                
            }
            
            // MARK: - Re-fetch The data
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
