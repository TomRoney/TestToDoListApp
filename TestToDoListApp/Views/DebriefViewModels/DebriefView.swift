//
//  DebriefView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/08/2024.
//

import SwiftUI
import UIKit

// Extension to end editing on the entire app.
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - NavigationConfigurator
// This view configures the hosting UINavigationController’s appearance, including the custom back indicator.
struct NavigationConfigurator: UIViewControllerRepresentable {
    var colorScheme: ColorScheme
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                // Set the background color to match your view.
                appearance.backgroundColor = (colorScheme == .dark ? UIColor.black : UIColor(named: "BackgroundBeige"))
                // Set the back indicator image using the provided method.
                appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left")!, transitionMaskImage: UIImage(systemName: "chevron.left")!)
                nav.navigationBar.standardAppearance = appearance
                nav.navigationBar.compactAppearance = appearance
                nav.navigationBar.scrollEdgeAppearance = appearance
            }
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let nav = uiViewController.navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = (colorScheme == .dark ? UIColor.black : UIColor(named: "BackgroundBeige"))
            appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left")!, transitionMaskImage: UIImage(systemName: "chevron.left")!)
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - KeyboardDismissHelper
// A helper class to handle taps outside the text view.
class KeyboardDismissHelper: NSObject {
    weak var textView: UITextView?
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let window = sender.view else { return }
        let location = sender.location(in: window)
        // If the tap is not within the textView, dismiss the keyboard.
        if let textView = textView {
            let textViewFrame = textView.convert(textView.bounds, to: window)
            if !textViewFrame.contains(location) {
                UIApplication.shared.endEditing()
            }
        } else {
            UIApplication.shared.endEditing()
        }
    }
}

struct DebriefView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DebriefViewViewModel
    // Holds a reference to the underlying UITextView from RichTextEditor.
    @State private var textView: UITextView? = nil
    
    // State for the word-limit alert and navigation.
    @State private var showWordLimitAlert: Bool = false
    @State private var navigateToSubscription: Bool = false
    @State private var coordinator: Coordinator? = nil
    
    // State for keyboard height.
    @State private var keyboardHeight: CGFloat = 0
    
    // State for the keyboard dismissal helper and its gesture.
    @State private var keyboardDismissHelper = KeyboardDismissHelper()
    @State private var dismissTapGesture: UITapGestureRecognizer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Header Title.
                Text("How was your day?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.top, 20)
                
                // Wrap the RichTextEditor and formatting toolbar in a ZStack.
                ZStack(alignment: .bottom) {
                    // Inner ZStack with the text field and counter.
                    ZStack(alignment: .bottomTrailing) {
                        RichTextEditor(
                            attributedText: $viewModel.attributedDebrief,
                            textView: $textView,
                            wordLimit: viewModel.isPremiumUser ? 300 : 150
                        )
                        .padding(10)
                        // Increased the minimum height from 400 to 500 for more text lines.
                        .frame(minHeight: 500)
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(10)
                        // For iOS 16+: hide the default scroll content background.
                        .scrollContentBackground(.hidden)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("GreenButton"), lineWidth: 2)
                        )
                        
                        // Word counter in the bottom right corner.
                        Text("\(viewModel.attributedDebrief.string.split { $0.isWhitespace || $0.isNewline }.count)/\(viewModel.isPremiumUser ? 300 : 150)")
                            .font(.caption)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(8)
                    }
                    .padding(.bottom, 50) // Leave space for the formatting toolbar.
                    
                    // Formatting toolbar.
                    HStack {
                        Button(action: { textView?.toggleBold() }) {
                            Image(systemName: "bold")
                        }
                        Spacer()
                        Button(action: { textView?.toggleItalics() }) {
                            Image(systemName: "italic")
                        }
                        Spacer()
                        Button(action: { textView?.toggleUnderline() }) {
                            Image(systemName: "underline")
                        }
                        Spacer()
                        Button(action: { textView?.toggleBullet() }) {
                            Image(systemName: "list.bullet")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .foregroundColor(.greenText)
                    .cornerRadius(10)
                    .padding(10)
                }
                
                Spacer()
            }
            .padding(20)
            .padding(.bottom, keyboardHeight)
        }
        .background((colorScheme == .dark ? Color.black : Color("BackgroundBeige")).ignoresSafeArea())
        // Attach NavigationConfigurator to set the custom back indicator.
        .background(NavigationConfigurator(colorScheme: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        // Use the system default back button so that swipe-to-go-back works.
        .onAppear {
            viewModel.loadDebrief()
            subscribeToKeyboardNotifications()
            // Add the tap gesture recognizer to the key window.
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                let tap = UITapGestureRecognizer(target: keyboardDismissHelper, action: #selector(KeyboardDismissHelper.handleTap(_:)))
                tap.cancelsTouchesInView = false
                window.addGestureRecognizer(tap)
                dismissTapGesture = tap
            }
        }
        .onDisappear {
            UIApplication.shared.endEditing()
            if let currentText = textView?.attributedText {
                viewModel.attributedDebrief = currentText
            }
            viewModel.saveDebrief()
            // Remove the tap gesture recognizer.
            if let tap = dismissTapGesture, let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.removeGestureRecognizer(tap)
            }
        }
        .onChange(of: textView) { newTextView in
            if let tv = newTextView, coordinator == nil {
                coordinator = Coordinator(showWordLimitAlert: $showWordLimitAlert, viewModel: viewModel)
                tv.delegate = coordinator
            }
            keyboardDismissHelper.textView = newTextView
        }
        // Hidden NavigationLink to trigger navigation to SubscriptionView when the user selects "Upgrade".
        .background(
            NavigationLink(destination: SubscriptionView(), isActive: $navigateToSubscription) {
                EmptyView()
            }
            .hidden()
        )
        // Alert to inform the user they've exceeded the word limit.
        .alert("Word Limit Exceeded", isPresented: $showWordLimitAlert) {
            if viewModel.isPremiumUser {
                Button("Ok", role: .cancel) { }
            } else {
                Button("Ok", role: .cancel) { }
                Button("Upgrade") { navigateToSubscription = true }
            }
        } message: {
            Text(viewModel.isPremiumUser ?
                 "Unfortunately you have exceeded the 300 word limit" :
                 "You have reached the maximum word limit for your subscription. Please upgrade to continue writing.")
        }
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil, queue: .main) { notification in
            if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation { keyboardHeight = value.height }
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil, queue: .main) { _ in
            withAnimation { keyboardHeight = 0 }
        }
    }
    
    // MARK: - Coordinator for UITextViewDelegate
    final class Coordinator: NSObject, UITextViewDelegate {
        var showWordLimitAlert: Binding<Bool>
        var viewModel: DebriefViewViewModel
        
        init(showWordLimitAlert: Binding<Bool>, viewModel: DebriefViewViewModel) {
            self.showWordLimitAlert = showWordLimitAlert
            self.viewModel = viewModel
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            if let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: text)
                let wordCount = updatedText.split { $0.isWhitespace || $0.isNewline }.count
                let limit = viewModel.isPremiumUser ? 300 : 150
                if wordCount > limit {
                    DispatchQueue.main.async {
                        self.showWordLimitAlert.wrappedValue = true
                    }
                    return false
                }
            }
            return true
        }
        
        @objc func textDidChange(notification: Notification) {
            if let tv = notification.object as? UITextView {
                viewModel.attributedDebrief = tv.attributedText
            }
        }
    }
}
