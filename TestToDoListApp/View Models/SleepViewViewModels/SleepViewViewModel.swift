//
//  SleepViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import FirebaseFirestore
import Foundation

/// ViewModel for managing sleep data
class SleepViewViewModel: ObservableObject {
    @Published var newItemPresented: Bool = false {
        didSet {
            // When the NewSleepView sheet is dismissed, refresh the sleep entries.
            if newItemPresented == false {
                fetchSleepEntries()
            }
        }
    }
    @Published var sleepItems: [Sleep] = [] // All fetched sleep items
    @Published var filteredItems: [Sleep] = [] // Filtered items based on selected date

    private let userId: String
    private(set) var selectedDate: Date {
        didSet {
            filterItemsByDate()
        }
    }

    init(userId: String, selectedDate: Date) {
        self.userId = userId
        self.selectedDate = selectedDate
        fetchSleepEntries() // Fetch initial data
    }

    /// Fetch sleep entries from Firestore
    func fetchSleepEntries() {
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("sleep")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching sleep entries: \(error.localizedDescription)")
                    return
                }
                if let snapshot = snapshot {
                    self.sleepItems = snapshot.documents.compactMap { document in
                        try? document.data(as: Sleep.self)
                    }
                    self.filterItemsByDate()
                }
            }
    }

    /// Delete a sleep entry
    func delete(id: String) {
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("sleep")
            .document(id)
            .delete { [weak self] error in
                if let error = error {
                    print("Error deleting item: \(error.localizedDescription)")
                } else {
                    self?.sleepItems.removeAll { $0.id == id }
                    self?.filterItemsByDate()
                }
            }
    }

    /// Filter items based on the selected date
    private func filterItemsByDate() {
        let calendar = Calendar.current
        filteredItems = sleepItems.filter {
            calendar.isDate(Date(timeIntervalSince1970: $0.createdate), inSameDayAs: selectedDate)
        }
    }

    /// Update the selected date
    func updateSelectedDate(_ newDate: Date) {
        selectedDate = newDate
    }
}
