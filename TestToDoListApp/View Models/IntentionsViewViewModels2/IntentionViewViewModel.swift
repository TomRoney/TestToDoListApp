//
//  IntentionViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/01/2025.
//

import FirebaseFirestore
import SwiftUI

// NEW: Define an error to indicate that the daily limit has been reached.
enum IntentionError: Error, LocalizedError {
    case dailyLimitReached

    var errorDescription: String? {
        switch self {
        case .dailyLimitReached:
            return "You have reached your daily limit of intentions for basic subscription users."
        }
    }
}

class IntentionViewViewModel: ObservableObject {
    @Published var intentions: [Intention] = [] // Active intentions
    @Published var completedIntentions: [Intention] = [] // Completed intentions
    @Published var showingNewIntentionView: Bool = false
    @Published var selectedDate: Date = Date() // Tracks the selected date
    @Published var allIntentions: [Intention] = [] // Store all intentions

    private var userId: String
    private var subscriptionStatus: String   // NEW: Holds the subscription status

    // Update initializer to receive subscriptionStatus.
    init(userId: String, subscriptionStatus: String) {
        self.userId = userId
        self.subscriptionStatus = subscriptionStatus
        fetchIntentions(for: selectedDate) // Fetch for the current date
    }

    // Fetch Intentions for a specific date
    func fetchIntentions(for selectedDate: Date, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        self.selectedDate = selectedDate // Ensure selected date is updated first

        Task {
            do {
                let fetchedIntentions = try await firestoreFetchIntentions()
                DispatchQueue.main.async {
                    self.allIntentions = fetchedIntentions
                    self.filterIntentionsByDate() // Ensure filtering runs after fetching
                    self.sortIntentionsByPriority() // Sort the intentions by priority
                    completion(.success(()))
                }
            } catch {
                print("Error fetching intentions: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Sort intentions based on priority (High -> Medium -> Low -> Default)
    private func sortIntentionsByPriority() {
        self.intentions.sort { first, second in
            let priorityOrder: [String: Int] = ["High": 0, "Medium": 1, "Low": 2]

            let firstPriority = priorityOrder[first.priority ?? ""] ?? 3 // Default to "No priority"
            let secondPriority = priorityOrder[second.priority ?? ""] ?? 3 // Default to "No priority"

            return firstPriority < secondPriority
        }

        self.completedIntentions.sort { first, second in
            let priorityOrder: [String: Int] = ["High": 0, "Medium": 1, "Low": 2]

            let firstPriority = priorityOrder[first.priority ?? ""] ?? 3 // Default to "No priority"
            let secondPriority = priorityOrder[second.priority ?? ""] ?? 3 // Default to "No priority"

            return firstPriority < secondPriority
        }
    }

    // Delete intention with completion handler
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("intention").document(id).delete { error in
            if let error = error {
                print("Error deleting intention: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                self.allIntentions.removeAll { $0.id == id }
                self.completedIntentions.removeAll { $0.id == id }
                self.filterIntentionsByDate() // Update UI after deletion
                completion(.success(()))
            }
        }
    }

    // Update intention with completion handler
    func updateIntention(_ intention: Intention, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(userId).collection("intention").document(intention.id).setData(from: intention) { error in
                if let error = error {
                    print("Error updating intention: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    if let index = self.allIntentions.firstIndex(where: { $0.id == intention.id }) {
                        self.allIntentions[index] = intention
                    }
                    self.filterIntentionsByDate() // Ensure UI updates correctly
                    self.sortIntentionsByPriority() // Sort by priority after update
                    completion(.success(()))
                }
            }
        } catch {
            print("Error serializing intention: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // Move intention to completed list (called when the intention is marked as done)
    func moveToCompleted(intention: Intention) {
        guard let index = intentions.firstIndex(where: { $0.id == intention.id }) else { return }

        // Mark intention as completed
        var updatedIntention = intention
        updatedIntention.isDone = true

        // Update Firestore
        updateIntention(updatedIntention) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.intentions.remove(at: index) // Remove from active list
                    self.completedIntentions.append(updatedIntention) // Add to completed list
                    self.filterIntentionsByDate()
                    self.sortIntentionsByPriority()
                }
            case .failure(let error):
                print("Error updating Firestore: \(error.localizedDescription)")
            }
        }
    }

    // Move intention back to main list (called when the intention is marked as not done)
    func moveBackToMainList(intention: Intention) {
        guard let index = completedIntentions.firstIndex(where: { $0.id == intention.id }) else { return }

        // Mark intention as not completed
        var updatedIntention = intention
        updatedIntention.isDone = false

        // Update Firestore
        updateIntention(updatedIntention) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.completedIntentions.remove(at: index) // Remove from completed list
                    self.intentions.append(updatedIntention) // Add back to active list
                    self.filterIntentionsByDate()
                    self.sortIntentionsByPriority()
                }
            case .failure(let error):
                print("Error updating Firestore: \(error.localizedDescription)")
            }
        }
    }

    // Filter intentions by selected date
    func filterIntentionsByDate() {
        let calendar = Calendar.current
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)

        print("Filtering Intentions for Date: \(normalizedSelectedDate)")

        self.intentions = allIntentions.filter { intention in
            let intentionDate = Date(timeIntervalSince1970: intention.date)
            let matches = calendar.isDate(intentionDate, inSameDayAs: normalizedSelectedDate) && !intention.isDone

            print("Checking Intention: \(intention.title), Date: \(intentionDate), Matches: \(matches)")
            return matches
        }

        self.completedIntentions = allIntentions.filter { intention in
            let intentionDate = Date(timeIntervalSince1970: intention.date)
            let matches = calendar.isDate(intentionDate, inSameDayAs: normalizedSelectedDate) && intention.isDone

            print("Checking Completed Intention: \(intention.title), Date: \(intentionDate), Matches: \(matches)")
            return matches
        }

        print("Filtered Intentions: \(self.intentions.map { $0.title })")
    }

    // Fetch intentions from Firestore
    private func firestoreFetchIntentions() async throws -> [Intention] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(userId).collection("intention").getDocuments()

        return snapshot.documents.compactMap { doc in
            do {
                let intention = try doc.data(as: Intention.self)
                print("Parsed Intention: \(intention)")
                return intention
            } catch {
                print("Failed to parse Intention for document: \(doc.data()), error: \(error)")
                return nil
            }
        }
    }

    // Add new intention and ensure UI updates correctly.
    // NEW: Before adding, check if a basic user has already created 4 intentions for the day.
    func addNewIntention(intention: Intention, completion: @escaping (Result<Void, Error>) -> Void) {
        if subscriptionStatus == "basic" {
            let calendar = Calendar.current
            let todayCount = allIntentions.filter { existingIntention in
                let intentionDate = Date(timeIntervalSince1970: existingIntention.date)
                return calendar.isDate(intentionDate, inSameDayAs: selectedDate)
            }.count
            
            if todayCount >= 4 {
                completion(.failure(IntentionError.dailyLimitReached))
                return
            }
        }
        
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(userId).collection("intention").document(intention.id).setData(from: intention) { error in
                if let error = error {
                    print("Error saving new intention: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.allIntentions.append(intention)
                        self.filterIntentionsByDate() // Immediately update the displayed list
                        self.sortIntentionsByPriority() // Sort intentions after adding new one
                        completion(.success(()))
                    }
                }
            }
        } catch {
            print("Error serializing new intention: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
