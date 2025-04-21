//
//  NewSleepViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewSleepViewViewModel: ObservableObject {
    @Published var title = ""
    @Published var selectedHours: String = "" // No default value to prevent prepopulation
    @Published var showAlert = false

    func save(for date: Date) {
        guard canSave else { return }

        // Get current user ID
        guard let uId = Auth.auth().currentUser?.uid else { return }

        // Create model
        let newId = UUID().uuidString
        let newItem = Sleep(
            id: newId,
            title: title,
            createdate: date.timeIntervalSince1970,
            isDone: false,
            hours: selectedHours
        )

        // Save model
        let db = Firestore.firestore()
        db.collection("users")
            .document(uId)
            .collection("sleep")
            .document(newId)
            .setData(newItem.asDictionary()) { error in
                if let error = error {
                    print("Error saving item: \(error.localizedDescription)")
                }
            }
    }

    var canSave: Bool {
        // Check that both `title` and `selectedHours` are non-empty
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !selectedHours.isEmpty
    }
}
