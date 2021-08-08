//
//  CategoriesViewControllerTableViewController.swift
//  Todoey
//
//  Created by apple on 07/08/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {
    
    var catArray  = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate) .persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Inside CategoriesTableViewController")
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist"))
        loadItems()
    }
    func saveItems(){
        do {
            try context.save()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    // after equals to it is a default value , if method is called without parameter it will be used at the default valur
    func loadItems(with request :NSFetchRequest<Categories> = Categories.fetchRequest()){
        do {
            catArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ToDoListViewController
      if  let indexPath = tableView.indexPathForSelectedRow {
        destination.selectedCategory = catArray[indexPath.row]
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = catArray[indexPath.row]
        cell.textLabel?.text = category.catName
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        catArray.count
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        var alert = UIAlertController(title: "Add A New Category", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter here"
            alertTextField = textField
        }
        var alertAction = UIAlertAction(title: "Add Category", style: .default) { (handler) in
            let value = alertTextField.text!
            let category  = Categories(context:self.context)
            category.catName = value
            self.catArray.append(category)
            self.saveItems()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
