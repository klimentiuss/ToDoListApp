//
//  TaskTableViewController.swift
//  ToDoRealmApp
//
//  Created by Daniil Klimenko on 10.07.2022.
//

import RealmSwift

class TaskTableViewController: UITableViewController {
    
    var taskList: TaskList!

    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = taskList.name
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current tasks" : "Completed tasks"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction( style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.deleteTask(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        let doneTitle = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitle) { _, _, isDone in
            StorageManager.shared.doneTask(task: task)
            
            let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)
            let indexPathForCompletedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)
            
            let destinationIndexRow = indexPath.section == 0
            ? indexPathForCompletedTask
            : indexPathForCurrentTask
            
            
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction,editAction, deleteAction])
    }
    
    
   @objc private func addButtonPressed() {
        showAlert()
    }
    
}

extension TaskTableViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil){
        
        let title = task != nil ? "Edit Task" : "New Task"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What to do?")
        
        alert.action(with: task) { newValue, note in
            
            if let task = task, let completion = completion {
                StorageManager.shared.editTask(task: task, name: newValue, note: note)
                completion()
            } else {
            self.saveTask(withName: newValue, andNote: note)
            }
        }
        present(alert, animated: true)
        
    }
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        
        StorageManager.shared.saveTask(task: task, in: taskList)
        let rowIndex = IndexPath(row: currentTasks.count - 1, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}

