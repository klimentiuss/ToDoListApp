//
//  Extention + UITableViewCell.swift
//  ToDoRealmApp
//
//  Created by Daniil Klimenko on 10.07.2022.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList){
        let currentTasks = taskList.tasks.filter("isComplete = false")
        let completedTasks = taskList.tasks.filter("isComplete = true")
        
        var content = defaultContentConfiguration()
        
        content.text = taskList.name
        
        if !currentTasks.isEmpty {
            content.secondaryText = "\(currentTasks.count)"
            accessoryType = .none
        } else if !completedTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            accessoryType = .none
            content.secondaryText = "0"
        }
        
        contentConfiguration = content
    }
}
