//
//  LogInView.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

struct LogInView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = LogInViewViewModel() // Existing view model for email login
    @State private var showForgotPasswordModal = false
    @State private var resetEmail = ""
    @State private var resetAlertMessage = ""
    @State private var showResetAlert = false

    // State variable for Apple Sign In nonce
    @State private var currentNonce: String?

    var body: some View {
        NavigationView {
            ZStack {
                // Use black for Dark Mode, otherwise use the beige asset.
                (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HeaderView(title: "Develop Daily", subtitle: "Welcome!")
                        .foregroundColor(Color("GreenText"))
                        .padding(.bottom, 20)
                    
                    // Fields and Buttons
                    VStack(spacing: 16) {
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Email field
                        TextField("Email Address", text: $viewModel.email)
                            .padding()
                            .frame(maxWidth: 300)
                            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                            .foregroundColor(Color("GreenText"))
                        
                        // Password field
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .frame(maxWidth: 300)
                            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .foregroundColor(Color("GreenText"))
                        
                        // Log In Button for email/password authentication
                        TL_Button(title: "Log In",
                                  background: Color("GreenButton"),
                                  action: {
                            viewModel.login()
                        })
                        .frame(maxWidth: 300)
                        .padding(.top, 16)
                        
                        // --- Sign In with Apple Button ---
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: configureAppleSignIn,
                            onCompletion: handleAppleSignIn
                        )
                        .frame(width: 300, height: 45)
                        .cornerRadius(8)
                        .padding(.top, 10)
                        
                        // Forgotten Password link
                        Button("Forgotten Password?") {
                            showForgotPasswordModal = true
                        }
                        .foregroundColor(Color("GreenText"))
                        .padding(.top, 10)
                    }
                    
                    // "Create an Account" link
                    NavigationLink("Create an Account",
                                   destination: RegisterView())
                        .foregroundColor(Color("GreenText"))
                        .padding(.top, 20)
                }
                .padding()
                
                // Modal for Forgotten Password
                if showForgotPasswordModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Reset Password")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                .padding(.leading, 20)
                            
                            Spacer()
                            
                            Button(action: {
                                showForgotPasswordModal = false
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .padding(20)
                            }
                        }
                        
                        TextField("Enter your email", text: $resetEmail)
                            .padding(10)
                            .background(Color("BackgroundBeige"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenButton"), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .autocapitalization(.none)
                        
                        Button("Send Reset Email") {
                            sendPasswordResetEmail(email: resetEmail)
                            showForgotPasswordModal = false
                        }
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color("GreenButton"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        
                    }
                    .frame(width: 300, height: 180)
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .cornerRadius(12)
                    .shadow(radius: 20)
                }
            }
            .alert(isPresented: $showResetAlert) {
                Alert(title: Text("Password Reset"),
                      message: Text(resetAlertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func sendPasswordResetEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                resetAlertMessage = "Failed to send password reset email: \(error.localizedDescription)"
            } else {
                resetAlertMessage = "If the email \(email) has a registered account, an email has been sent to reset your password."
            }
            showResetAlert = true
        }
    }
    
    // MARK: - Apple Sign In Helpers

    /// Configures the Apple Sign In request by generating a nonce, setting its SHA256 hash, and requesting the user’s full name and email.
    private func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    /// Handles the Apple Sign In response.
    /// On the first sign in, it extracts the user’s first and last name (if available) and stores them in Firestore.
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: No login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to fetch identity token")
                    return
                }
                
                // Extract the first and last name from Apple credential (only available on the first sign in)
                let firstName = appleIDCredential.fullName?.givenName ?? ""
                let lastName = appleIDCredential.fullName?.familyName ?? ""
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign in error: \(error.localizedDescription)")
                        return
                    }
                    
                    print("User signed in with Apple!")
                    
                    // If this is the user's first sign in, update Firestore with first/last name details.
                    if let authResult = authResult, authResult.additionalUserInfo?.isNewUser == true {
                        let db = Firestore.firestore()
                        let userId = authResult.user.uid
                        let data: [String: Any] = [
                            "id": userId,
                            "firstname": firstName,
                            "surname": lastName,
                            "email": authResult.user.email ?? "",
                            "joined": Date().timeIntervalSince1970,
                            "subscriptionStatus": "basic", // Default subscription
                            "dateOfBirth": "",
                            "countryOfResidence": "",
                            "agreedToTerms": false,
                            "mailingList": false
                        ]
                        db.collection("users").document(userId).setData(data, merge: true) { error in
                            if let error = error {
                                print("Error updating user record: \(error.localizedDescription)")
                            } else {
                                print("User record updated successfully with name")
                            }
                        }
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple error: \(error.localizedDescription)")
        }
    }

    // MARK: - Nonce Generation Helpers

    /// Generates a random alphanumeric string used as a nonce.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    /// Returns the SHA256 hash of the given string.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
