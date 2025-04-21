//
//  RegisterViewViewModels.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class RegisterViewViewModels: ObservableObject {
    @Published var firstname = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var password = ""
    @Published var dateOfBirth = ""
    @Published var selectedCountry = ""
    @Published var mailingList = false // Track mailing list subscription

    init() {}

    func register() {
        guard validate() else {
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }

            self?.insertUserRecord(Id: userId)
        }
    }

    private func insertUserRecord(Id: String) {
        let newUser = User(
            id: Id,
            firstname: firstname,
            surname: surname,
            email: email,
            joined: Date().timeIntervalSince1970,
            profilePictureUrl: nil,
            subscriptionStatus: "basic",
            dateOfBirth: dateOfBirth,
            countryOfResidence: selectedCountry,
            agreedToTerms: true, // Always true
            mailingList: mailingList
        )

        let db = Firestore.firestore()

        db.collection("users")
            .document(Id)
            .setData(newUser.asDictionary()) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data saved successfully!")
                }
            }
    }

    private func validate() -> Bool {
        guard !firstname.trimmingCharacters(in: .whitespaces).isEmpty,
              !surname.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !dateOfBirth.isEmpty,
              !selectedCountry.isEmpty else {
            return false
        }

        guard email.contains("@") && email.contains(".") else {
            return false
        }

        guard password.count >= 6 else {
            return false
        }

        return true
    }
}
