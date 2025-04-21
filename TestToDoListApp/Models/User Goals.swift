//
//  User Goals.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/09/2024.
//

import Foundation
import FirebaseFirestore

struct UserGoal: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore auto-generated ID
    var title: String
    var startDate: Date
    var endDate: Date
    var progress: Int
    var currentValue: Int
    var targetValue: Int
    var keyActions: [GoalKeyAction]
    var goalType: String?  // optional (e.g. "Personal" or "Professional")
    
    // Custom initializer
    init(
        id: String? = nil,
        title: String,
        startDate: Date,
        endDate: Date,
        progress: Int = 0,
        currentValue: Int = 0,
        targetValue: Int = 100,
        keyActions: [GoalKeyAction] = [],
        goalType: String? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.progress = progress
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.keyActions = keyActions
        self.goalType = goalType
    }
}
