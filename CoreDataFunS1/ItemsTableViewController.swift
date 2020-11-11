//
//  ItemsViewController.swift
//  CoreDataFunS1
//
//  Created by Gina Sprint on 11/1/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//

import UIKit
import CoreData

class ItemsTableViewController: UITableViewController {
    
    // next: change itemArray to be an array of Item
    // add the context property
    // fix the build errors
    var category: Category? = nil {
        // Mark: lab #6
        didSet {
            loadItems()
        }
    }
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = category, let name = category.name {
            self.navigationItem.title = "\(name) Items"
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return itemArray.count
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)

        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: lab #7
            context.delete(itemArray[indexPath.row])
            // Delete the row from the data source
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveItems()
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = itemArray.remove(at: sourceIndexPath.row)
        itemArray.insert(item, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // this method executes when the user selects (taps) on a row
        let item = itemArray[indexPath.row]
        // toggle its done
        // UPDATE of CRUD
        item.done = !item.done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Create New Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name of Item"
            alertTextField = textField
        }
        
        let action = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let text = alertTextField.text!
            let newItem = Item(context: self.context)
            newItem.name = text
            newItem.parentCategory = self.category
            newItem.done = false
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - lab #5
    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("Error saving items \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - lab #6
    func loadItems(withPredicate predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        // predicates are used to filter objects
        // they represent logical conditions that evaluate to true or false
        
        // MARK: lab #14
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        request.sortDescriptors = [sortDescriptor]
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)
        
        // MARK: lab #11.b.
        if let pred = predicate {
            // need to combine categoryPredicate and pred into a compoud predicate
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, pred])
            request.predicate = compoundPredicate
        }
        else {
            // %@ is a placeholder for a value of any type
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error loading items \(error)")
        }
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar Delegate Method(s)

// MARK: lab #13
extension ItemsTableViewController: UISearchBarDelegate {
    // MARK: lab #10.b.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // called everytime the text changes in the search bar
        print(searchText)
        // MARK: lab #12
        if searchText != "" {
            performSearch(searchBar: searchBar)
        }
        else {
            // search bar is empty
            searchBar.resignFirstResponder()
            loadItems() // load all the items
        }
    }
    
    // MARK: lab #11
    func performSearch(searchBar: UISearchBar) {
        // grab the text from the search bar
        if let text = searchBar.text {
            // MARK: lab #11.a.
            // create a predicate to filter items
            // by text
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            loadItems(withPredicate: predicate)
        }
    }
}
