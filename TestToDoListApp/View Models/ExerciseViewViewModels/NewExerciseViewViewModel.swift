//
//  NewExerciseViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import SwiftUI
import FirebaseFirestore

class NewExerciseViewViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var exerciseType: String? = nil
    @Published var duration: Int = 0
    @Published var isDone: Bool = false
    @Published var favouriteExerciseTypes: [String] = [] // Store favourites

    private var userId: String

    init(userId: String) {
        self.userId = userId
        fetchFavourites() // Fetch stored favourites on init
    }

    // Save a new exercise
    func saveExercise(for selectedDate: Date) {
        let newExercise = Exercise(
            id: UUID().uuidString,
            title: title,
            date: selectedDate.timeIntervalSince1970, // Convert Date to TimeInterval
            createdate: Date().timeIntervalSince1970,
            exerciseType: exerciseType ?? "Unknown",
            duration: duration,
            isDone: isDone
        )
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("exercise")
            .document(newExercise.id).setData(newExercise.asDictionary()) { error in
                if let error = error {
                    print("Error saving exercise: \(error)")
                } else {
                    print("Exercise saved successfully!")
                }
            }
    }
    
    // MARK: - Favourites Management
    
    // Fetch favourites from Firestore
    func fetchFavourites() {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching favourites: \(error)")
                return
            }
            
            if let data = document?.data(), let favourites = data["favourites"] as? [String] {
                self.favouriteExerciseTypes = favourites
            }
        }
    }

    // Toggle favourite exercise type
    func toggleFavourite(exerciseType: String) {
        if favouriteExerciseTypes.contains(exerciseType) {
            // Remove from favourites
            favouriteExerciseTypes.removeAll { $0 == exerciseType }
        } else {
            // Add to favourites
            favouriteExerciseTypes.append(exerciseType)
        }
        
        saveFavourites() // Persist changes
    }

    // Save favourites to Firestore
    func saveFavourites() {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "favourites": favouriteExerciseTypes
        ], merge: true) { error in
            if let error = error {
                print("Error saving favourites: \(error)")
            } else {
                print("Favourites updated successfully!")
            }
        }
    }

    // Helper to check if an exercise is favourited
    func isFavourite(exerciseType: String) -> Bool {
        return favouriteExerciseTypes.contains(exerciseType)
    }

    var isFormValid: Bool {
        return !title.isEmpty && exerciseType != nil && duration > 0
    }
}
