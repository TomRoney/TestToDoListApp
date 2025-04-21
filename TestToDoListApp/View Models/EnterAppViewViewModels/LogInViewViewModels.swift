//
//  LogInViewViewModels.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import FirebaseAuth
import Foundation

class LogInViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Firebase error (wrong password, no such user, etc.)
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let user = authResult?.user else {
                    self?.errorMessage = "Unexpected error: no user returned."
                    return
                }
                
                // Check if the user has verified their email
                if user.isEmailVerified {
                    // Email is verified—clear any errors and proceed
                    self?.errorMessage = ""
                    // TODO: advance to the next screen, e.g. set your app state here
                } else {
                    // Email not verified—sign them back out and prompt
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        // ignore sign-out error
                    }
                    
                    // Optionally resend the verification email
                    user.sendEmailVerification { sendError in
                        // you might log sendError if you want
                    }
                    
                    self?.errorMessage = "Verify your email to Log In."
                }
            }
        }
    }
    
    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }
        
        return true
    }
}
