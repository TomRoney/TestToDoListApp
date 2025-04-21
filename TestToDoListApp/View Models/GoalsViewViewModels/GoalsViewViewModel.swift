//
//  GoalsViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/09/2024.
//

import SwiftUI
import FirebaseFirestore

class GoalsViewModel: ObservableObject {
    @Published var goals: [UserGoal] = []
    @Published var isLoadingGoals: Bool = false
    @Published var subscriptionType: String = "essential" // Example subscription type
    
    private var db = Firestore.firestore()
    private var userId: String
    private var goalListener: ListenerRegistration?
    
    init(userId: String) {
        self.userId = userId
        loadGoalsFromFirestore()
    }
    
    // MARK: - Add a Goal to Firestore
    func addGoal(_ newGoal: UserGoal) {
        let userDocRef = db.collection("users").document(userId)
        do {
            var goalToAdd = newGoal
            let ref = userDocRef.collection("goals").document()
            goalToAdd.id = ref.documentID
            
            try ref.setData(from: goalToAdd) { error in
                if let error = error {
                    print("Error adding goal: \(error.localizedDescription)")
                } else {
                    print("Goal successfully added!")
                }
            }
        } catch {
            print("Error writing goal to Firestore: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Goals from Firestore (Real-time listener)
    func loadGoalsFromFirestore() {
        guard !isLoadingGoals else { return } // Prevent duplicate loading
        isLoadingGoals = true
        
        let userDocRef = db.collection("users").document(userId)
        goalListener = userDocRef.collection("goals").addSnapshotListener { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoadingGoals = false
                    print("Error loading goals: \(error.localizedDescription)")
                }
                return
            }
            
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    self.isLoadingGoals = false
                }
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let parsedGoals = snapshot.documents.compactMap { document in
                    try? document.data(as: UserGoal.self)
                }
                
                DispatchQueue.main.async {
                    self.goals = parsedGoals
                    self.isLoadingGoals = false
                }
            }
        }
    }
    
    // MARK: - Update a Goal
    func updateGoal(_ updatedGoal: UserGoal) {
        guard let goalId = updatedGoal.id else { return }
        let userDocRef = db.collection("users").document(userId)
        do {
            try userDocRef.collection("goals").document(goalId).setData(from: updatedGoal) { error in
                if let error = error {
                    print("Error updating goal: \(error.localizedDescription)")
                } else {
                    print("Goal successfully updated!")
                }
            }
        } catch {
            print("Error writing goal to Firestore: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete a Goal
    func deleteGoal(_ goalToDelete: UserGoal) {
        guard let goalId = goalToDelete.id else { return }
        let userDocRef = db.collection("users").document(userId)
        userDocRef.collection("goals").document(goalId).delete { error in
            if let error = error {
                print("Error deleting goal: \(error.localizedDescription)")
            } else {
                print("Goal successfully deleted!")
            }
        }
    }
}
