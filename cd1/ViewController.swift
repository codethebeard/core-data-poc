//
//  ViewController.swift
//  cd1
//
//  Created by Michael VanDyke on 2/1/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }

    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
       
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text else { return }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(name: String) {
        // Get access to the persistent container source and derive it's managed context (viewContext)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Query the entity
        guard let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) else { return }
        
        // Get the managed object from the entity
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the value passed into this function to the managed object's attribute
        person.setValue(name, forKeyPath: "name")
        
        // Save the new value to the managed object and update the table's datasource.
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Unhandled error. \(error), \(error.userInfo)")
        }
    }
    
    private func fetchData() {
        // Get access to the persistent continer source and derive it's managed context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for the Person entity
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        // Make the request and set the in-memory datasource for the table
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Unhandled error. \(error), \(error.userInfo)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
}
