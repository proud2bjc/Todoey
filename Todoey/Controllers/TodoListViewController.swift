//
//  ViewController.swift
//  Todoey
//
//  Created by Michelle on 2018-07-19.
//  Copyright © 2018 Michelle Chin. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
    }
    
    override func viewWillAppear (_ animated: Bool) {
        
        
        
            guard let colourHex = selectedCategory?.colour else { fatalError() }
            
            title = selectedCategory?.name
        
            updateNavBar(withHexCode: colourHex)
        
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        
        guard let originalColour = UIColor(hexString: "cfe2ea") else {fatalError()}
        
        updateNavBar(withHexCode: "cfe2ea")
      
    }
    
    //MARK - Nav Bar Setup Method
    func updateNavBar (withHexCode colourHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode)else { fatalError() }
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
    }
    
    // MARK - Tableview Datasource Methods
    
    //TODO: Declare numberOfRowsInSection here:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        return todoItems?.count ?? 1
            
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) {
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                }
                    
                //Ternary operator ==>
                // value = condition ? valueIfTrue : valueIfFalse
                cell.accessoryType = item.done ? .checkmark : .none
            
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //Mark - TableViewDelegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                //realm.delete(item)
                item.done = !item.done
                }
            } catch {
                print("Error saving checked state, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated:true)
        
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    //MARK: Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once user clicks add item on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
                } catch {
                print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
            alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
            alert.addAction(action)
            present (alert, animated: true, completion:nil)
    }
    
    //MARK = Model Manipulation Methods
    
  
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    //MARK - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

//MARK: Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS [cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
