//
//  ProfileViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class ProfileViewViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var profileImage: UIImage? = nil // Store the profile image once fetched
    @Published var subscriptionViewModel = SubscriptionViewViewModel() // Add SubscriptionViewViewModel instance

    init() {
        Task {
            await fetchUser() // Fetch the user profile when the view model is initialized
        }
    }

    /// Fetches the user's profile details, including the profile picture URL.
    /// If no user document exists (e.g., when signing in with Apple), a default record is created.
    func fetchUser() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let documentRef = db.collection("users").document(userId)

        do {
            let snapshot = try await documentRef.getDocument()

            if !snapshot.exists || snapshot.data() == nil {
                // No user record exists in Firestore—create one using available Auth data and defaults.
                let authUser = Auth.auth().currentUser
                let userEmail = authUser?.email ?? ""
                
                // Get display name from Auth (Apple Sign In may provide it only on the first sign in)
                let displayName = authUser?.displayName ?? ""
                let firstname: String
                let surname: String
                if !displayName.isEmpty {
                    let nameComponents = displayName.split(separator: " ")
                    firstname = String(nameComponents.first ?? "")
                    surname = nameComponents.dropFirst().joined(separator: " ")
                } else {
                    // Use empty strings if no display name is provided.
                    firstname = ""
                    surname = ""
                }
                
                let newUserData: [String: Any] = [
                    "id": userId,
                    "firstname": firstname,
                    "surname": surname,
                    "email": userEmail,
                    "joined": Date().timeIntervalSince1970,
                    "subscriptionStatus": "basic", // Default subscription
                    "dateOfBirth": "",
                    "countryOfResidence": "",
                    "agreedToTerms": false,
                    "mailingList": false
                ]
                
                try await documentRef.setData(newUserData)
                
                user = User(
                    id: userId,
                    firstname: firstname,
                    surname: surname,
                    email: userEmail,
                    joined: Date().timeIntervalSince1970,
                    profilePictureUrl: nil,
                    subscriptionStatus: "basic",
                    dateOfBirth: "",
                    countryOfResidence: "",
                    agreedToTerms: false,
                    mailingList: false
                )
            } else {
                let data = snapshot.data()!
                user = User(
                    id: data["id"] as? String ?? "",
                    firstname: data["firstname"] as? String ?? "",
                    surname: data["surname"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    joined: data["joined"] as? Double ?? 0,
                    profilePictureUrl: data["profilePictureUrl"] as? String,
                    subscriptionStatus: data["subscriptionStatus"] as? String ?? "basic",
                    dateOfBirth: data["dateOfBirth"] as? String ?? "",
                    countryOfResidence: data["countryOfResidence"] as? String ?? "",
                    agreedToTerms: data["agreedToTerms"] as? Bool ?? false,
                    mailingList: data["mailingList"] as? Bool ?? false
                )
                
                // Fetch the profile image if the URL exists.
                if let profilePictureUrl = data["profilePictureUrl"] as? String {
                    await fetchProfileImage(urlString: profilePictureUrl)
                }
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }

    /// Updates the user's profile details in Firestore.
    /// - Parameters:
    ///   - firstName: The new first name.
    ///   - surname: The new surname.
    ///   - dateOfBirth: The new date of birth.
    ///   - country: The new country of residence.
    ///   - completion: Completion block indicating success or failure.
    func updateUserProfile(firstName: String, surname: String, dateOfBirth: String, country: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "firstname": firstName,
            "surname": surname,
            "dateOfBirth": dateOfBirth,
            "countryOfResidence": country
        ]
        
        db.collection("users").document(userId).updateData(data) { error in
            if let error = error {
                completion(false, error)
            } else {
                DispatchQueue.main.async {
                    self.user?.firstname = firstName
                    self.user?.surname = surname
                    self.user?.dateOfBirth = dateOfBirth
                    self.user?.countryOfResidence = country
                    completion(true, nil)
                }
            }
        }
    }

    /// Uploads the user's profile image to Firebase Storage and updates the profile picture URL in Firestore.
    func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard error == nil else {
                print("Failed to upload image: \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { [weak self] url, error in
                guard let downloadURL = url else {
                    print("Failed to retrieve download URL: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                let db = Firestore.firestore()
                db.collection("users").document(userId).updateData(["profilePictureUrl": downloadURL.absoluteString]) { error in
                    if let error = error {
                        print("Failed to update profile picture URL: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self?.user?.profilePictureUrl = downloadURL.absoluteString
                        }
                    }
                }
            }
        }
    }

    /// Fetches the profile image from the provided URL.
    private func fetchProfileImage(urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            profileImage = UIImage(data: data)
        } catch {
            print("Failed to fetch profile image: \(error.localizedDescription)")
        }
    }

    /// Logs the user out.
    func logOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            profileImage = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    /// Updates the user's subscription status in Firestore.
    func updateSubscriptionStatus(to status: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(["subscriptionStatus": status]) { error in
            if let error = error {
                print("Failed to update subscription status: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.user?.subscriptionStatus = status
                }
            }
        }
    }

    /// Deletes the user's account from Firestore and Firebase Authentication.
    func deleteAccount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user from database: \(error.localizedDescription)")
                return
            }
            Auth.auth().currentUser?.delete { authError in
                if let authError = authError {
                    print("Error deleting user account: \(authError.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.logOut()
                }
            }
        }
    }
}
