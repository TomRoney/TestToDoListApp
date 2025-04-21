//
//  PreferencesView.swift
//  TestToDoList
//
//  Created by Tom Roney on 07/01/2025.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject var viewModel: PreferencesViewViewModel
    @State private var showDeleteConfirmation = false
    
    // Environment property to detect dark or light mode.
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background color changes based on the color scheme.
            (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                .ignoresSafeArea()

            // Main content
            VStack {
                headerSection()
                    .padding(.top, 10)
                    .padding(.leading, 10)

                VStack(spacing: 15) {
                    // Mailing List Button
                    Button(action: {
                        viewModel.showMailingListPopup = true
                    }) {
                        Text("Mailing list")
                            .foregroundColor(.white)
                            .frame(maxWidth: 350, minHeight: 44)
                            .background(Color("GreenButton"))
                            .cornerRadius(10)
                    }

                    // Notifications Button
                    Button(action: {
                        openNotificationSettings()
                    }) {
                        Text("Notifications")
                            .foregroundColor(.white)
                            .frame(maxWidth: 350, minHeight: 44)
                            .background(Color("GreenButton"))
                            .cornerRadius(10)
                    }

                    // Delete Account Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: 350, minHeight: 44)
                            .background(Color("GreenButton"))
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(
                            title: Text("Are you sure you want to delete your account?"),
                            message: Text("If you delete the account, then all your data will be deleted and your account will not be restorable."),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.deleteAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding(.top, 50)

                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear {
                viewModel.fetchProfileData()
            }

            // Custom modal overlay
            if viewModel.showMailingListPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                MailingListPopupView(viewModel: viewModel)
                    .frame(width: 300, height: 180)
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }

    private func headerSection() -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Preferences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black) // Adjust title color based on mode
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
            } else if let profileImageURL = viewModel.profileImageURL {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
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

    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
