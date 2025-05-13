//
//  ModernBabySignupViewController+Dropdown.swift
//  Faby
//
//  Created for Faby App
//

import UIKit

// MARK: - Dropdown Methods
extension ModernBabySignupViewController {
    
    @objc func showGenderPicker() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
        }
        
        // Create a modern iOS-style dropdown with blur effect
        let dropdownVC = ModernDropdownViewController(options: genderOptions, selectedIndex: genderOptions.firstIndex(of: genderTextField.text ?? "") ?? 0)
        dropdownVC.modalPresentationStyle = .popover
        dropdownVC.preferredContentSize = CGSize(width: genderTextField.frame.width, height: 180)
        
        // Configure the popover presentation
        if let popover = dropdownVC.popoverPresentationController {
            popover.sourceView = genderTextField
            popover.sourceRect = genderTextField.bounds
            popover.permittedArrowDirections = [UIPopoverArrowDirection.up, UIPopoverArrowDirection.down]
            popover.backgroundColor = UIColor.clear
            popover.delegate = self
        }
        
        // Set the selection handler
        dropdownVC.onSelection = { [weak self] (selectedIndex: Int) in
            guard let self = self else { return }
            self.genderTextField.text = self.genderOptions[selectedIndex]
            
            // Provide haptic feedback on selection
            if #available(iOS 10.0, *) {
                let feedbackGenerator = UISelectionFeedbackGenerator()
                feedbackGenerator.prepare()
                feedbackGenerator.selectionChanged()
            }
            
            // Animate the chevron rotation back
            if let chevron = self.genderTextField.rightView?.subviews.first as? UIImageView {
                UIView.animate(withDuration: 0.3) {
                    chevron.transform = .identity
                }
            }
        }
        
        // Animate the chevron rotation
        if let chevron = genderTextField.rightView?.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.3) {
                chevron.transform = CGAffineTransform(rotationAngle: .pi)
            }
        }
        
        present(dropdownVC, animated: true)
    }
}
