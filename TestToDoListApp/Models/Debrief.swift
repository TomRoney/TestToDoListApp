//
//  Debrief.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import Foundation
import FirebaseFirestore

struct Debrief: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore document ID
    var title: String            // Title of the debrief
    var text: String             // Content of the debrief
    var userId: String           // The user who created the debrief
    var timestamp: Date          // Timestamp when the debrief was created
    var date: String             // Date for the debrief in string format

    init(id: String? = nil, title: String, text: String, userId: String, timestamp: Date, date: String) {
        self.id = id
        self.title = title
        self.text = text
        self.userId = userId
        self.timestamp = timestamp
        self.date = date
    }
}
