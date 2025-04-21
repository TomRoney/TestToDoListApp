//
//  ProfilleAccountView.swift
//  TestToDoList
//
//  Created by Tom Roney on 07/01/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Profile Country Picker Component
struct ProfileCountryPicker: View {
    @Environment(\.colorScheme) var colorScheme
    let countries: [String]
    @Binding var selectedCountry: String
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool
    @State private var showSuggestions: Bool = false

    var filteredCountries: [String] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return countries
        } else {
            return countries.filter { $0.lowercased().contains(trimmed.lowercased()) }
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
                .onAppear {
                    searchText = selectedCountry
                }
                .onChange(of: selectedCountry) { newValue in
                    if searchText != newValue {
                        searchText = newValue
                    }
                }
                .onChange(of: searchText) { newValue in
                    if newValue.isEmpty {
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
                                    withAnimation {
                                        showSuggestions = false
                                    }
                                    isFocused = false
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        .onChange(of: isFocused) { focused in
            withAnimation {
                showSuggestions = focused
            }
        }
    }
}

// MARK: - ProfileAccountView
struct ProfileAccountView: View {
    var user: User
    @StateObject var viewModel: ProfileViewViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertTitle: String = "Profile Update"
    @State private var alertMessage = ""
    
    // Editable fields for user details.
    @State private var firstNameText: String = ""
    @State private var surnameText: String = ""
    @State private var dateOfBirthText: String = ""
    @State private var countryText: String = ""
    @State private var profileDOB: Date = Date()
    
    // Controls showing the overlay date picker (same style as RegisterView).
    @State private var showDatePicker = false
    
    // Duplicate the country list from RegisterView to keep data consistent.
    let countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola",
        "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria",
        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados",
        "Belarus", "Belgium", "Belize", "Benin", "Bhutan",
        "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei",
        "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia",
        "Cameroon", "Canada", "Central African Republic", "Chad", "Chile",
        "China", "Colombia", "Comoros", "Congo, Republic of the",
        "Congo, Democratic Republic of the", "Costa Rica", "Croatia", "Cyprus",
        "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic",
        "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea",
        "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland",
        "France", "Gabon", "Gambia", "Georgia", "Germany",
        "Ghana", "Greece", "Grenada", "Guatemala", "Guinea",
        "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary",
        "Iceland", "India", "Indonesia", "Iraq", "Ireland",
        "Israel", "Italy", "Jamaica", "Japan", "Jordan",
        "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan",
        "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia",
        "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar",
        "Malawi", "Malaysia", "Maldives", "Mali", "Malta",
        "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia",
        "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco",
        "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal",
        "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria",
        "North Macedonia", "Norway", "Oman", "Pakistan", "Palau",
        "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru",
        "Philippines", "Poland", "Portugal", "Qatar", "Romania",
        "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia",
        "Saint Vincent and the Grenadines", "Samoa", "San Marino",
        "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia",
        "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia",
        "Solomon Islands", "Somalia", "South Africa", "South Korea",
        "South Sudan", "Spain", "Sri Lanka", "Suriname", "Sweden",
        "Switzerland", "Taiwan", "Tajikistan", "Tanzania", "Thailand",
        "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia",
        "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine",
        "United Arab Emirates", "United Kingdom", "United States",
        "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela",
        "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    // Check if any field has changed from the original user data.
    private var hasChanges: Bool {
        return firstNameText != user.firstname ||
               surnameText != user.surname ||
               dateOfBirthText != user.dateOfBirth ||
               countryText != user.countryOfResidence
    }
    
    var body: some View {
        ZStack {
            // Main content.
            ScrollView {
                VStack(spacing: 20) {
                    headerSection()
                        .padding(.top, 30)
                        .padding(.horizontal)
                    
                    inputFields()
                    
                    // "Save Changes" button appears only if a change is detected.
                    if hasChanges {
                        Button(action: {
                            updateProfile()
                        }) {
                            Text("Save Changes")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("GreenButton"))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // "Change Password" button.
                    Button(action: {
                        sendPasswordResetEmail()
                    }) {
                        Text("Change Password")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("GreenButton"))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertTitle),
                              message: Text(alertMessage),
                              dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 50)
            }
            .onAppear {
                // Load user data into the editable fields.
                firstNameText = user.firstname
                surnameText = user.surname
                dateOfBirthText = user.dateOfBirth
                countryText = user.countryOfResidence
                
                // If user.dateOfBirth is in "dd/MM/yyyy" format & parseable, set it to profileDOB.
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                if let parsedDate = formatter.date(from: user.dateOfBirth) {
                    profileDOB = parsedDate
                }
            }
            .background(
                (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .edgesIgnoringSafeArea(.all)
            )
            .sheet(isPresented: $showImagePicker, onDismiss: {
                if let selectedImage = selectedImage {
                    viewModel.profileImage = selectedImage
                    viewModel.uploadProfileImage(selectedImage)
                    NotificationCenter.default.post(name: Notification.Name("ProfileImageUpdated"), object: nil)
                }
            }) {
                ImagePicker(selectedImage: $selectedImage)
            }
            
            // Overlay modal date picker (same style as in RegisterView).
            if showDatePicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack {
                    DatePicker("Select Date", selection: $profileDOB, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .accentColor(Color("GreenText"))
                        .padding()
                    
                    Button(action: {
                        dateOfBirthText = formatDate(profileDOB)
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
        .navigationBarTitle("", displayMode: .inline)
    }
    
    // MARK: - UI Sections
    
    private func headerSection() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            profileImageSection()
        }
    }
    
    private func profileImageSection() -> some View {
        VStack {
            if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            Button("Edit") {
                showImagePicker = true
            }
            .foregroundColor(Color("GreenText"))
            .padding(.top, 5)
        }
    }
    
    private func inputFields() -> some View {
        VStack(spacing: 16) {
            // Non-editable Email.
            TextField("Email", text: .constant(user.email))
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .disabled(true)
            
            // Editable First Name.
            TextField("First Name", text: $firstNameText)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color("GreenText"), lineWidth: 1))
                .foregroundColor(Color("GreenText"))
                .padding(.horizontal, 16)
            
            // Editable Surname.
            TextField("Surname", text: $surnameText)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color("GreenText"), lineWidth: 1))
                .foregroundColor(Color("GreenText"))
                .padding(.horizontal, 16)
            
            // Date of Birth field styled to match other input fields.
            Button(action: {
                showDatePicker = true
            }) {
                HStack {
                    Text(dateOfBirthText.isEmpty ? "Date of Birth" : dateOfBirthText)
                        .foregroundColor(dateOfBirthText.isEmpty ? .gray : Color("GreenText"))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color("GreenText"))
                        .padding(.trailing, 8) // Move chevron inward
                }
                .padding() // Matches internal padding of TextField
                .frame(height: 44)
                .background(colorScheme == .dark ? Color.black : Color("InputFieldBackground"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("GreenText"), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            
            // Country auto-complete picker.
            ProfileCountryPicker(countries: countries, selectedCountry: $countryText)
                .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Utility Functions
    
    private func sendPasswordResetEmail() {
        let email = user.email
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertTitle = "Profile Update"
                alertMessage = "Failed to send password reset email: \(error.localizedDescription)"
            } else {
                alertTitle = "Profile Update"
                alertMessage = "An email has been sent to \(email) to reset your password."
            }
            showAlert = true
        }
    }
    
    private func updateProfile() {
        viewModel.updateUserProfile(
            firstName: firstNameText,
            surname: surnameText,
            dateOfBirth: dateOfBirthText,
            country: countryText
        ) { success, error in
            if let error = error {
                alertTitle = "Profile Update"
                alertMessage = "Failed to update profile: \(error.localizedDescription)"
            } else {
                alertTitle = "Profile Updated"
                alertMessage = "Your Profile information has been saved successfully."
            }
            showAlert = true
        }
    }
    
    /// Formats a Date as "dd/MM/yyyy".
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
