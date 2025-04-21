//
//  Exercise.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import Foundation

struct Exercise: Identifiable, Codable {
    var id: String
    var title: String
    var date: TimeInterval  // Date for exercise
    var createdate: TimeInterval
    var exerciseType: String
    var duration: Int
    var isDone: Bool

    init(id: String = UUID().uuidString, title: String, date: TimeInterval, createdate: TimeInterval, exerciseType: String, duration: Int, isDone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.createdate = createdate
        self.exerciseType = exerciseType
        self.duration = duration
        self.isDone = isDone
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "date": date,
            "createdate": createdate,
            "exerciseType": exerciseType,
            "duration": duration,
            "isDone": isDone
        ]
    }
}
