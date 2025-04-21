//
//  GoalKeyAction.swift
//  TestToDoList
//
//  Created by Tom Roney on 04/10/2024.
//

import Foundation

struct GoalKeyAction: Identifiable, Codable {
    let id: UUID
    var description: String
    var actionType: String
    var currentValue: Int
    var targetValue: Int
    var isCompleted: Bool = false
    
    init(
        id: UUID = UUID(),
        description: String,
        actionType: String,
        currentValue: Int,
        targetValue: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.description = description
        self.actionType = actionType
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.isCompleted = isCompleted
    }
}
