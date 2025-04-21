//
//  PreferencesViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 14/01/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class PreferencesViewViewModel: ObservableObject {
    @Published var isSubscribedToMailingList = false
    @Published var showMailingListPopup = false
    @Published var profileImage: UIImage?
    @Published var profileImageURL: String?

    private let userID: String
    private let db = Firestore.firestore()

    init(userID: String) {
        self.userID = userID
        fetchProfileData() // Fetch profile data when the view model is initialized
    }

    /// Fetches the user's profile data, including the profile picture URL
    func fetchProfileData() {
        let userDoc = db.collection("users").document(userID)
        userDoc.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.isSubscribedToMailingList = data?["mailingList"] as? Bool ?? false
                self.profileImageURL = data?["profilePictureUrl"] as? String

                // Fetch the profile image if the URL exists
                if let profileImageURL = self.profileImageURL {
                    self.fetchProfileImage(urlString: profileImageURL)
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    /// Fetches the profile image from the provided URL
    private func fetchProfileImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to fetch profile image: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
        task.resume()
    }

    func updateMailingListPreference() {
        let userDoc = db.collection("users").document(userID)
        userDoc.updateData(["mailingList": isSubscribedToMailingList]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    func deleteAccount() {
        let userDoc = db.collection("users").document(userID)
        userDoc.delete { error in
            if let error = error {
                print("Error deleting user from database: \(error)")
                return
            }
            Auth.auth().currentUser?.delete { authError in
                if let authError = authError {
                    print("Error deleting user account: \(authError)")
                    return
                }
                print("Account successfully deleted.")
                
                // Log the user out after account deletion
                do {
                    try Auth.auth().signOut()
                    print("User successfully logged out.")
                } catch let signOutError {
                    print("Error signing out: \(signOutError)")
                }
            }
        }
    }
}
