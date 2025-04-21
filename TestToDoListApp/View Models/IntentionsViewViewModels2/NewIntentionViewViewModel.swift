//
//  NewIntentionViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/01/2025.
//

import SwiftUI
import FirebaseFirestore

class NewIntentionViewViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var intentionType: String? = nil
    @Published var priority: String? = nil  // New priority field
    @Published var isDone: Bool = false

    private var userId: String

    init(userId: String) {
        self.userId = userId
    }

    // Save a new intention
    func saveIntention(for selectedDate: Date) {
        let newIntention = Intention(
            id: UUID().uuidString,
            title: title,
            date: selectedDate.timeIntervalSince1970, // Convert Date to TimeInterval
            createdate: Date().timeIntervalSince1970,
            intentionType: intentionType ?? "Unknown",
            priority: priority ?? "Medium", // Default to "Medium" if no priority is selected
            isDone: isDone
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("intention")
            .document(newIntention.id).setData(newIntention.asDictionary()) { error in
                if let error = error {
                    print("Error saving intention: \(error)")
                } else {
                    print("Intention saved successfully!")
                }
            }
    }

    var isFormValid: Bool {
        return !title.isEmpty
    }
}
