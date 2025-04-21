//
//  RegisterView.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
         Button(action: {
             configuration.isOn.toggle()
         }) {
             HStack {
                 Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                     .foregroundColor(Color("GreenText"))
                 configuration.label
                     .foregroundColor(Color("GreenText"))
             }
         }
         .buttonStyle(PlainButtonStyle())
    }
}

// New Autocomplete Country Picker using FocusState and ScrollView for suggestions
struct AutocompleteCountryPicker: View {
    @Environment(\.colorScheme) var colorScheme
    let countries: [String]
    @Binding var selectedCountry: String
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showSuggestions: Bool = false

    // If searchText is empty, show all countries.
    var filteredCountries: [String] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return countries
        } else {
            return countries.filter { $0.lowercased().contains(text.lowercased()) }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Select your country", text: $searchText)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("GreenText"), lineWidth: 1)
                )
                .foregroundColor(Color("GreenText"))
                .accentColor(Color("GreenText"))
                .autocorrectionDisabled()
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    withAnimation { showSuggestions = focused }
                }
                .onChange(of: searchText) { newValue in
                    if newValue != selectedCountry {
                        selectedCountry = ""
                    }
                }
            
            if showSuggestions && !filteredCountries.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredCountries, id: \.self) { country in
                            Text(country)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("GreenText"))
                                .background(Color.clear)
                                .onTapGesture {
                                    searchText = country
                                    selectedCountry = country
                                    withAnimation { showSuggestions = false }
                                    isFocused = false
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil
                                    )
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("GreenText"), lineWidth: 1)
                )
            }
        }
    }
}

struct RegisterView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = RegisterViewViewModels()
    @State private var selectedCountry = ""
    @State private var dateOfBirth: Date = Date()
    @State private var dateOfBirthSelected: Bool = false
    @State private var showTermsView = false
    @State private var showPrivacyView = false
    @State private var isRegistering = false
    @State private var errorMessage: String? = nil
    @State private var isSubscribedToMailingList = false
    @State private var confirmPassword: String = ""
    @State private var showVerificationAlert: Bool = false
    @State private var showDatePicker = false

    // ← NEW: navigate back to login on alert dismissal
    @State private var navigateToLogin = false

    let countries = ["Afghanistan", "Albania", "Algeria", /* … etc … */ "Zambia", "Zimbabwe"]

    var body: some View {
        ZStack {
            // ← hidden link to trigger navigation
            NavigationLink(
                destination: LogInView(),
                isActive: $navigateToLogin,
                label: { EmptyView() }
            )

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("GreenText"))
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer().frame(height: 10)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        TextField("First Name", text: $viewModel.firstname)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .autocorrectionDisabled()
                            .foregroundColor(Color("GreenText"))
                            .accentColor(Color("GreenText"))
                        
                        TextField("Surname", text: $viewModel.surname)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .autocorrectionDisabled()
                            .foregroundColor(Color("GreenText"))
                            .accentColor(Color("GreenText"))
                        
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Text(dateOfBirthSelected ? formatDate(dateOfBirth) : "Date of Birth")
                                    .foregroundColor(dateOfBirthSelected ? Color("GreenText") : .gray)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color("GreenText"))
                            }
                            .padding(.horizontal)
                            .frame(height: 44)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                        }
                        
                        AutocompleteCountryPicker(countries: countries, selectedCountry: $selectedCountry)
                        
                        TextField("Email Address", text: $viewModel.email)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .foregroundColor(Color("GreenText"))
                            .accentColor(Color("GreenText"))
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .foregroundColor(Color("GreenText"))
                            .accentColor(Color("GreenText"))
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenText"), lineWidth: 1)
                            )
                            .foregroundColor(Color("GreenText"))
                            .accentColor(Color("GreenText"))
                        
                        if !confirmPassword.isEmpty && viewModel.password != confirmPassword {
                            Text("Your password does not match, please try again")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Toggle(isOn: $isSubscribedToMailingList) {
                            Text("Sign up for our mailing list")
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    Button(action: register) {
                        Text(isRegistering ? "Registering..." : "Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color("GreenButton") : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid || isRegistering)
                    
                    Spacer().frame(height: 15)
                    
                    Text("By creating an account, you agree to our")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 5)
                    
                    HStack(spacing: 5) {
                        NavigationLink(destination: TermsView()) {
                            Text("Terms of Service")
                                .font(.footnote)
                                .foregroundColor(Color("GreenText"))
                        }
                        Text("and")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        NavigationLink(destination: PrivacyView()) {
                            Text("Privacy Policy")
                                .font(.footnote)
                                .foregroundColor(Color("GreenText"))
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 0)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .background((colorScheme == .dark ? Color.black : Color("BackgroundBeige")).ignoresSafeArea())
            .navigationBarTitle("", displayMode: .inline)
            
            if showDatePicker {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack {
                    DatePicker("Select Date", selection: $dateOfBirth, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .accentColor(Color("GreenText"))
                        .padding()
                    Button(action: {
                        dateOfBirthSelected = true
                        showDatePicker = false
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("GreenButton"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                .cornerRadius(12)
                .padding()
                .shadow(radius: 20)
            }
        }
        .alert(isPresented: $showVerificationAlert) {
            Alert(
                title: Text("Verification Email Sent"),
                message: Text("A verification email has been sent to \(viewModel.email). Please verify your email before logging in."),
                dismissButton: .default(Text("OK"), action: {
                    navigateToLogin = true
                })
            )
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private var isFormValid: Bool {
        !viewModel.firstname.isEmpty &&
        !viewModel.surname.isEmpty &&
        dateOfBirthSelected &&
        !selectedCountry.isEmpty &&
        !viewModel.email.isEmpty &&
        !viewModel.password.isEmpty &&
        !confirmPassword.isEmpty &&
        viewModel.password == confirmPassword
    }
    
    private func register() {
        // Password match check
        if viewModel.password != confirmPassword {
            errorMessage = "Your password does not match, please try again"
            return
        }
        guard isFormValid else {
            errorMessage = "Please enter all fields correctly."
            return
        }

        isRegistering = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: viewModel.email, password: viewModel.password) { result, error in
            if let error = error {
                self.isRegistering = false
                self.errorMessage = "Error: \(error.localizedDescription)"
                return
            }
            guard let user = result?.user else {
                self.isRegistering = false
                return
            }

            // Immediately sign out so the user isn't left logged in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out after createUser: \(error.localizedDescription)")
            }

            // Send verification email
            user.sendEmailVerification { error in
                if let error = error {
                    self.errorMessage = "Error sending verification email: \(error.localizedDescription)"
                } else {
                    // Save user data & show alert
                    self.saveUserData(userId: user.uid)
                    self.showVerificationAlert = true
                }
                self.isRegistering = false
            }
        }
    }
    
    private func saveUserData(userId: String) {
        let formattedDOB = formatDate(dateOfBirth)
        let newUser = User(
            id: userId,
            firstname: viewModel.firstname,
            surname: viewModel.surname,
            email: viewModel.email,
            joined: Date().timeIntervalSince1970,
            profilePictureUrl: nil,
            subscriptionStatus: "basic",
            dateOfBirth: formattedDOB,
            countryOfResidence: selectedCountry,
            agreedToTerms: true,
            mailingList: isSubscribedToMailingList
        )
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(newUser.asDictionary()) { error in
            if let error = error {
                self.isRegistering = false
                self.errorMessage = "Error saving user data: \(error.localizedDescription)"
            } else {
                print("User data saved successfully!")
            }
        }
    }
}
