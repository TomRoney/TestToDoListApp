//
//  HomeViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 24/08/2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class HomeViewViewModel: ObservableObject {
    @Published var currentUserId: String = ""            // Holds the current user ID
    @Published var profilePictureURL: String? = nil        // Holds the profile picture URL
    @Published var subscriptionStatus: String = ""         // Holds the subscription status (e.g., "premium" or "standard")
    @Published var userfirstname: String? = nil            // Holds the user's first name
    
    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for authentication state changes
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                
                if let userId = user?.uid {
                    // Fetch user profile when the user is authenticated
                    self?.fetchUserProfile(userId: userId)
                    self?.fetchSubscriptionStatus(userId: userId)
                }
            }
        }
    }
    
    // Determines if the user is signed in
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Fetches the user's profile information from Firestore
    private func fetchUserProfile(userId: String) {
        let db = Firestore.firestore()
        
        // Fetch the document for the current user from the "users" collection
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            
            // Parse the document data
            guard let data = snapshot?.data() else {
                print("No data found for user: \(userId)")
                return
            }
            
            DispatchQueue.main.async {
                // Update profilePictureURL with the URL from Firestore (if available)
                if let url = data["profilePictureUrl"] as? String {
                    self?.profilePictureURL = url
                } else {
                    print("No profile picture URL found for user: \(userId)")
                }
                
                // Update userfirstname with the first name from Firestore (if available)
                if let firstname = data["firstname"] as? String {
                    self?.userfirstname = firstname
                } else {
                    print("No first name found for user: \(userId)")
                }
            }
        }
    }
    
    /// Fetches the user's subscription status from Firestore
    private func fetchSubscriptionStatus(userId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching subscription status: \(error.localizedDescription)")
                return
            }
            
            // Parse the document data for subscription status
            guard let data = snapshot?.data() else {
                print("No data found for user: \(userId)")
                return
            }
            
            DispatchQueue.main.async {
                if let status = data["subscriptionStatus"] as? String {
                    self?.subscriptionStatus = status
                } else {
                    print("No subscription status found for user: \(userId)")
                    self?.subscriptionStatus = "standard" // Default to "standard" if no status found
                }
            }
        }
    }
    
    /// New public function to re-fetch the profile picture URL
    func fetchProfilePictureURL() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching profile picture URL: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                print("No data found for user: \(userId)")
                return
            }
            DispatchQueue.main.async {
                if let url = data["profilePictureUrl"] as? String {
                    self?.profilePictureURL = url
                }
            }
        }
    }
}
