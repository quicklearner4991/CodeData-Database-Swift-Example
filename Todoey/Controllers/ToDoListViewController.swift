//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var array :[ToDoItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Categories? {
        didSet {
            loadItems()
        }
    }
    
    // let userDefault = UserDefaults.standard
    @IBOutlet weak var searchBar: UISearchBar!
    //let commonRequest : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
    override func viewDidLoad() {
        super.viewDidLoad()
        // loadItems()
        searchBar.delegate = self
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist"))
        
        // long press listener for tableview
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        if Reachability.isConnectedToNetwork() {
            print(" Yes connected")
        }
        else{
            print(" Not connected")
        }
        
    }
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let alert = UIAlertController(title: "Alert", message: "Do you want to delete this item?", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Yes", style: .default) { (action) in
                    // do your functionality
                    self.context.delete(self.array[indexPath.row])
                    self.array.remove(at: indexPath.row)
                    self.saveItems()
                    alert.dismiss(animated: true, completion: nil)
                    
                }
                let actionDelete = UIAlertAction(title: "No", style: .default) { (action) in
                    // do your functionality
                    alert.dismiss(animated: true, completion: nil)
                    
                }
                
                alert.addAction(action)
                alert.addAction(actionDelete)
                self.present(alert, animated: true, completion: nil)
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let itemCell = array[indexPath.row]
        cell.textLabel?.text = itemCell.name
        //Ternary operator ==>
        //value = condition ? valueIfTrue: valueIfFalse
        cell.accessoryType = itemCell.isChecked ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        array[indexPath.row].isChecked = !array[indexPath.row].isChecked
        
        //to delete items do this
        //context.delete(array[indexPath.row])
        //array.remove(at: indexPath.row)
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addBarItemClicked(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // do your functionality
            let value = textField.text!
            let toDoItem = ToDoItem(context:self.context)
            toDoItem.name = value
            toDoItem.isChecked = false
            toDoItem.parentCategory = self.selectedCategory
            self.array.append(toDoItem)
            self.saveItems()
            self.loadItems()
            alert.dismiss(animated: true, completion: nil)
            
        }
        alert.addTextField { (textfield) in
            textfield.placeholder = "Create new item"
            textField = textfield
        }
        alert.addAction(action)
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    func saveItems(){
        do {
            try self.context.save()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    // after equals to it is a default value , if method is called without parameter it will be used at the default valur
    func loadItems(with request :NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest() , predicate : NSPredicate? = nil ){
        let categoryPredicate = NSPredicate(format: "parentCategory.catName MATCHES %@",selectedCategory!.catName!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }
        else
        {
            request.predicate = categoryPredicate
        }
        do {
            array = try context.fetch(request)
            tableView.reloadData()
            print(array)
        } catch {
            print(error)
        }
    }
}
//Mark: - Search bar methods

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearching()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearching()
    }
    func performSearching() {
        if searchBar.text! == "" {
            loadItems()
            DispatchQueue.main.async {
                // to remove focus from searchbar
                self.searchBar.resignFirstResponder()
            }
            return
        }
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadItems(with: request,predicate: predicate)
    }
}

