//
//  ModernSignupViewController+Dropdown.swift
//  Faby
//
//  Created for Faby App
//

import UIKit

// MARK: - Dropdown Methods
extension ModernSignupViewController {
    
    @objc func showRelationshipPicker() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }
        
        // Create a modern iOS-style dropdown with blur effect
        let dropdownVC = ModernDropdownViewController(options: relationshipOptions, selectedIndex: relationshipOptions.firstIndex(of: relationshipTextField.text ?? "") ?? 0)
        dropdownVC.modalPresentationStyle = .popover
        dropdownVC.preferredContentSize = CGSize(width: relationshipTextField.frame.width, height: 180)
        
        // Configure the popover presentation
        if let popover = dropdownVC.popoverPresentationController {
            popover.sourceView = relationshipTextField
            popover.sourceRect = relationshipTextField.bounds
            popover.permittedArrowDirections = [UIPopoverArrowDirection.up, UIPopoverArrowDirection.down]
            popover.backgroundColor = UIColor.clear
            popover.delegate = self
        }
        
        // Set the selection handler
        dropdownVC.onSelection = { [weak self] (selectedIndex: Int) in
            guard let self = self else { return }
            self.relationshipTextField.text = self.relationshipOptions[selectedIndex]
            
            // Provide haptic feedback on selection
            if #available(iOS 10.0, *) {
                let feedbackGenerator = UISelectionFeedbackGenerator()
                feedbackGenerator.prepare()
                feedbackGenerator.selectionChanged()
            }
            
            // Animate the chevron rotation back
            if let chevron = self.relationshipTextField.rightView?.subviews.first as? UIImageView {
                UIView.animate(withDuration: 0.3) {
                    chevron.transform = .identity
                }
            }
        }
        
        // Animate the chevron rotation
        if let chevron = relationshipTextField.rightView?.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.3) {
                chevron.transform = CGAffineTransform(rotationAngle: .pi)
            }
        }
        
        present(dropdownVC, animated: true)
    }
}
