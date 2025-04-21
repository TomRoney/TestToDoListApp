//
//  RichTextView.swift
//  TestToDoList
//
//  Created by Tom Roney on 06/02/2025.
//

import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @Binding var attributedText: NSAttributedString
    @Binding var textView: UITextView?
    var wordLimit: Int  // New property to enforce the word count limit.
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.isEditable = true
        // Use the preferred body font.
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        // Set text color based on dark mode.
        tv.textColor = (colorScheme == .dark) ? UIColor.white : UIColor.black
        // Use a conditional background: black in dark mode, otherwise your asset.
        tv.backgroundColor = (colorScheme == .dark) ? UIColor.black : UIColor(named: "BackgroundBeige")
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.autocapitalizationType = .sentences
        
        // Do not attach an inputAccessoryView so our SwiftUI toolbar is used.
        context.coordinator.textView = tv
        DispatchQueue.main.async {
            self.textView = tv
        }
        
        // Add an observer for text changes so that even programmatic changes update the binding.
        NotificationCenter.default.addObserver(context.coordinator,
                                               selector: #selector(Coordinator.textDidChange(notification:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: tv)
        
        return tv
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update the text and appearance when the environment changes.
        uiView.attributedText = attributedText
        uiView.backgroundColor = (colorScheme == .dark) ? UIColor.black : UIColor(named: "BackgroundBeige")
        uiView.textColor = (colorScheme == .dark) ? UIColor.white : UIColor.black
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        weak var textView: UITextView?
        
        init(parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
        
        // This delegate method validates input against the word limit.
        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let textRange = Range(range, in: currentText) else { return true }
            let updatedText = currentText.replacingCharacters(in: textRange, with: text)
            let wordCount = updatedText.split { $0.isWhitespace || $0.isNewline }.count
            return wordCount <= parent.wordLimit
        }
        
        @objc func textDidChange(notification: Notification) {
            if let tv = notification.object as? UITextView {
                parent.attributedText = tv.attributedText
            }
        }
    }
}
