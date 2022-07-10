//
//  TaskListTableViewController.swift
//  ToDoRealmApp
//
//  Created by Daniil Klimenko on 10.07.2022.
//

import RealmSwift
import SwiftUI

class TaskListTableViewController: UITableViewController {
    
    private var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        createTempData()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
         let taskList = taskLists[indexPath.row]
         cell.configure(with: taskList)
         
     return cell
     }
     
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = taskLists[indexPath.row]
        let deleteAction = UIContextualAction( style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList: currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction,editAction, deleteAction])
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        
        guard let tasksVC = segue.destination as? TaskTableViewController else { return }
        tasksVC.taskList = taskList
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortedList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
        ? taskLists.sorted(byKeyPath: "date")
        : taskLists.sorted(byKeyPath: "name")
        tableView.reloadData()
    }
    
    private func createTempData() {
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    }
    
}

extension TaskListTableViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (()-> Void)? = nil) {
        
        let title = taskList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What to do?")
        
        alert.action(with: taskList) {newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        let taskList = TaskList(value: [taskList])
        
        StorageManager.shared.save(taskList: taskList)
        let rowIndex = IndexPath.init(row: taskLists.count - 1, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
