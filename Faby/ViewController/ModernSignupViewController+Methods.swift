//
//  ModernSignupViewController+Methods.swift
//  Faby
//
//  Created for Faby App
//

import UIKit

// MARK: - Methods for ModernSignupViewController
extension ModernSignupViewController {
    
    // MARK: - Toggle Password Visibility
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        // Find the text field associated with this button
        if let textField = view.subviews.flatMap({ $0.subviews }).first(where: { ($0 as? UITextField)?.hash == sender.tag }) as? UITextField {
            // Toggle secure text entry
            textField.isSecureTextEntry.toggle()
            
            // Update the button image
            if textField.isSecureTextEntry {
                sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            } else {
                sender.setImage(UIImage(systemName: "eye"), for: .normal)
            }
            
            // Provide haptic feedback
            if #available(iOS 10.0, *) {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
        }
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Force popover style even on iPhone
    }
}
