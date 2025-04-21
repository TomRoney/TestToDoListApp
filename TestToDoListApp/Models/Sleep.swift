//
//  Sleep.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import Foundation

struct Sleep: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let createdate: TimeInterval
    var isDone: Bool
    let hours: String // New field for hours

    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "createdate": createdate,
            "isDone": isDone,
            "hours": hours // Include hours in dictionary
        ]
    }
}
