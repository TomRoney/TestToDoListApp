//
//  DebriefViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import FirebaseFirestore
import Foundation
import Combine
import UIKit

class DebriefViewViewModel: ObservableObject {
    // Store the debrief as an attributed string.
    @Published var attributedDebrief: NSAttributedString = NSAttributedString(string: "")
    
    var selectedDate: Date
    private var documentId: String?
    private var db = Firestore.firestore()
    @Published var isPremiumUser: Bool  // Made Published for dynamic updates.
    private let currentUserId: String
    private var cancellables = Set<AnyCancellable>()
    
    private var wordLimit: Int {
        return isPremiumUser ? 300 : 150
    }
    
    init(currentUserId: String, selectedDate: Date, isPremiumUser: Bool) {
        self.currentUserId = currentUserId
        self.selectedDate = selectedDate
        self.isPremiumUser = isPremiumUser
        
        // Auto-save when the attributedDebrief changes (even if the plain text is the same)
        $attributedDebrief
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveDebrief()
            }
            .store(in: &cancellables)
    }
    
    // When fetching debriefs for a new date, clear the documentId so that we don’t
    // mistakenly update a document from another date.
    func fetchDebriefs(for date: Date) {
        self.selectedDate = date
        self.documentId = nil  // <<-- Reset documentId for the new date.
        loadDebrief()
    }
    
    func loadDebrief() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        db.collection("users")
            .document(currentUserId)
            .collection("debrief")
            .whereField("date", isEqualTo: formattedDate)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching debrief: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                if let document = documents.first {
                    self.documentId = document.documentID
                    if let data = document.data() as? [String: Any],
                       let archivedString = data["text"] as? String,
                       let archivedData = Data(base64Encoded: archivedString) {
                        // Unarchive the NSAttributedString (including styling)
                        if let attrStr = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: archivedData) {
                            DispatchQueue.main.async {
                                self.attributedDebrief = attrStr
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.attributedDebrief = NSAttributedString(string: "")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.attributedDebrief = NSAttributedString(string: "")
                        }
                    }
                } else {
                    // If no document exists for this date, ensure documentId is nil.
                    self.documentId = nil  // <<-- Clear documentId if no document is found.
                    DispatchQueue.main.async {
                        self.attributedDebrief = NSAttributedString(string: "")
                    }
                }
            }
    }
    
    func saveDebrief() {
        let plainText = attributedDebrief.string
        let wordCount = plainText.split { $0.isWhitespace || $0.isNewline }.count
        if wordCount > wordLimit {
            print("Word count exceeds limit.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        // Archive the entire NSAttributedString (including styling)
        var archivedString = plainText
        if let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: attributedDebrief, requiringSecureCoding: false) {
            archivedString = archivedData.base64EncodedString()
        }
        
        let debriefData: [String: Any] = [
            "title": generateTitle(from: plainText),
            "text": archivedString,
            "timestamp": Date(),
            "userId": currentUserId,
            "date": formattedDate
        ]
        
        if let documentId = documentId {
            db.collection("users")
                .document(currentUserId)
                .collection("debrief")
                .document(documentId)
                .setData(debriefData, merge: true) { error in
                    if let error = error {
                        print("Error updating debrief: \(error.localizedDescription)")
                    }
                }
        } else {
            let docRef = db.collection("users")
                .document(currentUserId)
                .collection("debrief")
                .addDocument(data: debriefData) { error in
                    if let error = error {
                        print("Error saving debrief: \(error.localizedDescription)")
                    }
                }
            self.documentId = docRef.documentID
        }
    }
    
    private func generateTitle(from text: String) -> String {
        let words = text.split(separator: " ").prefix(5).joined(separator: " ")
        return words.isEmpty ? "Untitled" : words
    }
}
