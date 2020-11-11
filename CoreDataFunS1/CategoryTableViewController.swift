//
//  ViewController.swift
//  CoreDataFunS1
//
//  Created by Gina Sprint on 11/1/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Core Data
// we've made a DataModel that abstracts a SQLite database
// there is some Core Data jargon to learn
// Core Data Entity <-> Swift Type <-> database table
// Core Data Attribute <-> Swift property <-> database field
// therefore a row in a table is like an object of a type
// all of the underlying data store queries and methods are managed through an interface of type NSPersistentContainer
// NSPersistentContainer has a NSManagedObjectContext which is like an intelligent scratchpad
// think of the context like the staging area of a git repo
// saving the context is like committing in git, its when our changes are actually written to disk (the db)

// MARK: - CRUD: Common Database Operations
// a persistent container abstracts a data store for us
// by default the data store is a SQLite database
// we work with a persistent container's context instead of with the persistent container directly
// we will use the context for commont DB operations
// CRUD: create, retrieve/read, update, delete
// let's start with the C

class CategoryTableViewController: UITableViewController {
    
    //var categoryArray = ["Home", "Work", "Family"]
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // print out the documents directory so we can see our database in Finder
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        
        loadCategories()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categoryArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: lab #15
            // PSEUDOCODE SOLUTION
            // fetch all of the items that have this
            // category as their parent
            // delete those items
            // then delete the category
            // write your code here to do this
            
            // we want to delete the Category add indexPath.row
            // from the context first... then later we want to
            // save the context so the delete persists
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // persist the deletion by saving the context
            saveCategories()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categoryArray.remove(at: sourceIndexPath.row)
        categoryArray.insert(category, at: destinationIndexPath.row)
        tableView.reloadData()
    }

    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Create New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name of Category"
            alertTextField = textField
        }
        
        let action = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let text = alertTextField.text!
            // CREATE (C of CRUD)
            let newCategory = Category(context: self.context)
            newCategory.name = text
            self.categoryArray.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "ShowItemsSegue"  {
            
            guard let itemsTableVC = segue.destination as? ItemsTableViewController else {
                return
            }
        
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            let category = categoryArray[selectedIndexPath.row]
            itemsTableVC.category = category
        }
    }
    
    func saveCategories() {
        // we want to save the context "to disk" (db)
        do {
            try context.save() // like git commit
        }
        catch {
            print("Error saving categories \(error)")
        }
        tableView.reloadData()
    }
    
    // READ of CRUD
    func loadCategories() {
        // we need to make a "request" to get the Category objects
        // via the persistent container
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        // with a sql SELECT statement we usually specify a WHERE clause if we want to filter rows from the table we are selecting from
        // if we want to filter, we need to add a "predicate" to our request... we will do this later for Items
        do {
            categoryArray = try context.fetch(request)
        }
        catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}


