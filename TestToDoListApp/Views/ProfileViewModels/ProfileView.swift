//
//  ProfileView.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    @State private var navigateToLogin = false
    @Environment(\.colorScheme) var colorScheme
    
    // Computed property for background color based on the current color scheme.
    var backgroundColor: Color {
        colorScheme == .dark ? .black : Color("BackgroundBeige")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection()
                        .padding(.top, 50)
                        .padding(.horizontal)
                    
                    if let user = viewModel.user {
                        VStack(spacing: 15) {
                            NavigationLink(destination: ProfileAccountView(user: user, viewModel: viewModel)) {
                                navigationButton(title: "Profile")
                            }
                            NavigationLink(destination: PreferencesView(viewModel: PreferencesViewViewModel(userID: user.id))) {
                                navigationButton(title: "Preferences")
                            }
                            NavigationLink(destination: SubscriptionView(viewModel: viewModel.subscriptionViewModel)) {
                                navigationButton(title: "Subscription")
                            }
                        }
                        .padding(.top, 20)
                    } else {
                        ProgressView("Loading profile...")
                    }
                    
                    logoutButton
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(backgroundColor)
            }
            .background(backgroundColor)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLogin) {
                LogInView()
            }
        }
        .background(backgroundColor)
        .onAppear {
            Task {
                await viewModel.fetchUser()
            }
        }
    }
    
    private func headerSection() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Account")
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
        }
    }
    
    private func navigationButton(title: String) -> some View {
        Text(title)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding()
            .background(Color("GreenButton"))
            .cornerRadius(10)
            .frame(width: 350)
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.logOut()
        }) {
            Text("Log Out")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding()
                .background(Color("GreenButton"))
                .cornerRadius(10)
                .frame(width: 350)
        }
    }
}
