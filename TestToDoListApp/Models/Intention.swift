//
//  Intention.swift
//  TestToDoList
//
//  Created by Tom Roney on 12/10/2024.
//

import Foundation

struct Intention: Identifiable, Codable {
    var id: String
    var title: String
    var date: TimeInterval  // Date for exercise
    var createdate: TimeInterval
    var intentionType: String
    var priority: String
    var isDone: Bool

    init(id: String = "", title: String, date: TimeInterval, createdate: TimeInterval, intentionType: String, priority: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.createdate = createdate
        self.intentionType = intentionType
        self.priority = priority
        self.isDone = isDone
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "date": date,
            "createdate": createdate,
            "exerciseType": intentionType, // Correct key for Firestore
            "priority": priority,
            "isDone": isDone
        ]
    }

    // Map Firestore keys to model properties
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case createdate
        case intentionType = "exerciseType" // Map exerciseType to intentionType
        case priority
        case isDone
    }
}
