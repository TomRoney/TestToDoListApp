//
//  UITextView.swift
//  TestToDoList
//
//  Created by Tom Roney on 07/02/2025.
//

import UIKit

extension UITextView {
    func toggleBold() {
        guard self.selectedRange.length > 0 else { return }
        let selectedRange = self.selectedRange
        let mutableAttr = NSMutableAttributedString(attributedString: self.attributedText)
        mutableAttr.enumerateAttributes(in: selectedRange, options: []) { attributes, range, _ in
            var newAttributes = attributes
            // Use the preferred body font.
            let currentFont = (attributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
            let isBold = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
            var newFont: UIFont
            if isBold {
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits.subtracting(.traitBold)) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            } else {
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits.union(.traitBold)) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            }
            newAttributes[.font] = newFont
            mutableAttr.setAttributes(newAttributes, range: range)
        }
        self.attributedText = mutableAttr
        self.selectedRange = selectedRange
        // Post a text–change notification so that observers update the binding.
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
    }
    
    func toggleItalics() {
        guard self.selectedRange.length > 0 else { return }
        let selectedRange = self.selectedRange
        let mutableAttr = NSMutableAttributedString(attributedString: self.attributedText)
        mutableAttr.enumerateAttributes(in: selectedRange, options: []) { attributes, range, _ in
            var newAttributes = attributes
            let currentFont = (attributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
            let isItalic = currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic)
            var newFont: UIFont
            if isItalic {
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits.subtracting(.traitItalic)) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            } else {
                if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(currentFont.fontDescriptor.symbolicTraits.union(.traitItalic)) {
                    newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
                } else {
                    newFont = currentFont
                }
            }
            newAttributes[.font] = newFont
            mutableAttr.setAttributes(newAttributes, range: range)
        }
        self.attributedText = mutableAttr
        self.selectedRange = selectedRange
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
    }
    
    func toggleUnderline() {
        guard self.selectedRange.length > 0 else { return }
        let selectedRange = self.selectedRange
        let mutableAttr = NSMutableAttributedString(attributedString: self.attributedText)
        mutableAttr.enumerateAttributes(in: selectedRange, options: []) { attributes, range, _ in
            var newAttributes = attributes
            let currentUnderline = (attributes[.underlineStyle] as? Int) ?? 0
            if currentUnderline == 0 {
                newAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            } else {
                newAttributes[.underlineStyle] = 0
            }
            mutableAttr.setAttributes(newAttributes, range: range)
        }
        self.attributedText = mutableAttr
        self.selectedRange = selectedRange
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
    }
    
    func toggleBullet() {
        let selectedRange = self.selectedRange
        let mutableAttr = NSMutableAttributedString(attributedString: self.attributedText)
        let textString = mutableAttr.string as NSString
        let paragraphRange = textString.paragraphRange(for: selectedRange)
        let paragraphText = textString.substring(with: paragraphRange)
        let bullet = "• "
        let lines = paragraphText.components(separatedBy: "\n")
        let newParagraph = lines.map { line -> String in
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(bullet) {
                return line
            } else {
                return bullet + line
            }
        }.joined(separator: "\n")
        mutableAttr.replaceCharacters(in: paragraphRange, with: newParagraph)
        self.attributedText = mutableAttr
        self.selectedRange = NSRange(location: paragraphRange.location, length: 0)
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
    }
}
