//
//  ExerciseViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import FirebaseFirestore
import SwiftUI

class ExerciseViewViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var showingNewExerciseView: Bool = false
    @Published var selectedDate: Date = Date() // Tracks the selected date
    @Published var allExercises: [Exercise] = [] // Store all exercises

    private var userId: String

    init(userId: String) {
        self.userId = userId
        fetchExercises(for: Date()) // Default fetch for current date
    }

    // Fetch Exercises with completion handler
    func fetchExercises(for selectedDate: Date, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        Task {
            do {
                let fetchedExercises = try await firestoreFetchExercises()
                DispatchQueue.main.async {
                    self.allExercises = fetchedExercises
                    self.selectedDate = selectedDate // Store the selected date
                    self.filterExercisesByDate() // Filter exercises by the selected date
                    completion(.success(())) // Call completion with success
                }
            } catch {
                print("Error fetching exercises: \(error.localizedDescription)")
                completion(.failure(error)) // Ensure completion is called with failure
            }
        }
    }

    // Delete exercise with completion handler
    func delete(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("exercise").document(id).delete { error in
            if let error = error {
                print("Error deleting exercise: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                self.exercises.removeAll { $0.id == id }
                completion(.success(()))
            }
        }
    }

    // Update exercise with completion handler
    func updateExercise(_ exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        do {
            try db.collection("users").document(userId).collection("exercise").document(exercise.id).setData(from: exercise) { error in
                if let error = error {
                    print("Error updating exercise: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    // Update the local list
                    if let index = self.exercises.firstIndex(where: { $0.id == exercise.id }) {
                        self.exercises[index] = exercise
                    }
                    completion(.success(()))
                }
            }
        } catch {
            print("Error serializing exercise: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // Move exercise to bottom and update Firestore
    func moveExerciseToBottom(exercise: Exercise, completion: @escaping () -> Void = {}) {
        guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        
        var updatedExercise = exercise
        updatedExercise.isDone = true // Ensure it's marked as done
        
        exercises.remove(at: index)
        exercises.append(updatedExercise) // Move to the bottom
        
        // Update Firestore and re-sort locally
        updateExercise(updatedExercise) { result in
            switch result {
            case .success:
                self.exercises.sort { !$0.isDone && $1.isDone }
                completion() // Notify when sorting is done
            case .failure:
                print("Error moving exercise to bottom.")
                completion() // Ensure completion is called even in case of failure
            }
        }
    }

    // Filter exercises by date
    func filterExercisesByDate() {
        exercises = allExercises.filter { exercise in
            let exerciseDate = Date(timeIntervalSince1970: exercise.date)
            return Calendar.current.isDate(exerciseDate, inSameDayAs: selectedDate)
        }
    }

    // Fetch exercises from Firestore
    private func firestoreFetchExercises() async throws -> [Exercise] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(userId).collection("exercise").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Exercise.self) }
    }

    // Add new exercise
    func addNewExercise(exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        do {
            // Save new exercise with the selected date
            try db.collection("users").document(userId).collection("exercise").document(exercise.id).setData(from: exercise) { error in
                if let error = error {
                    print("Error saving new exercise: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    self.allExercises.append(exercise)
                    self.filterExercisesByDate() // Update filtered exercises list
                    completion(.success(()))
                }
            }
        } catch {
            print("Error serializing new exercise: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
