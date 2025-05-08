import UIKit

class SubmitFeedbackViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    private let headerLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let feedbackTypeSegmentedControl = UISegmentedControl(items: ["Suggestion", "Bug Report", "Praise"])
    private let feedbackTextView = UITextView()
    private let characterCountLabel = UILabel()
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let ratingLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let submitButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let maxCharacterCount = 500
    private var selectedRating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Submit Feedback"
        view.backgroundColor = .systemBackground
        setupUI()
        setupKeyboardDismissal()
    }
    
    private func setupUI() {
        // Setup ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Header Label
        headerLabel.text = "We value your feedback"
        headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)
        
        // Description Label
        descriptionLabel.text = "Your feedback helps us improve the app for everyone"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Feedback Type Segmented Control
        feedbackTypeSegmentedControl.selectedSegmentIndex = 0
        feedbackTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(feedbackTypeSegmentedControl)
        
        // Feedback Text View
        feedbackTextView.font = UIFont.systemFont(ofSize: 16)
        feedbackTextView.layer.borderColor = UIColor.systemGray4.cgColor
        feedbackTextView.layer.borderWidth = 1.0
        feedbackTextView.layer.cornerRadius = 8.0
        feedbackTextView.delegate = self
        feedbackTextView.translatesAutoresizingMaskIntoConstraints = false
        feedbackTextView.text = "Tell us what you think..."
        feedbackTextView.textColor = .placeholderText
        contentView.addSubview(feedbackTextView)
        
        // Character Count Label
        characterCountLabel.text = "0/\(maxCharacterCount)"
        characterCountLabel.font = UIFont.systemFont(ofSize: 12)
        characterCountLabel.textColor = .systemGray
        characterCountLabel.textAlignment = .right
        characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(characterCountLabel)
        
        // Email Label
        emailLabel.text = "Your email (optional)"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        // Email Text Field
        emailTextField.placeholder = "email@example.com"
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.delegate = self
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        // Rating Label
        ratingLabel.text = "Rate your experience (optional)"
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingLabel)
        
        // Rating Stack View
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .equalSpacing
        ratingStackView.alignment = .center
        ratingStackView.spacing = 10
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingStackView)
        
        // Add star buttons to rating stack view
        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemYellow
            button.tag = i
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
            ratingStackView.addArrangedSubview(button)
        }
        
        // Submit Button
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(submitButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            feedbackTypeSegmentedControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            feedbackTypeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackTypeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            feedbackTextView.topAnchor.constraint(equalTo: feedbackTypeSegmentedControl.bottomAnchor, constant: 24),
            feedbackTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            feedbackTextView.heightAnchor.constraint(equalToConstant: 150),
            
            characterCountLabel.topAnchor.constraint(equalTo: feedbackTextView.bottomAnchor, constant: 8),
            characterCountLabel.trailingAnchor.constraint(equalTo: feedbackTextView.trailingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 24),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            ratingLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 16),
            ratingStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: 44),
            
            submitButton.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UITextViewDelegate & UITextFieldDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
        
        // Scroll to make the text view visible
        scrollView.scrollRectToVisible(textView.frame, animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us what you think..."
            textView.textColor = .placeholderText
            characterCountLabel.text = "0/\(maxCharacterCount)"
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Scroll to make the text field visible
        scrollView.scrollRectToVisible(textField.frame, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        characterCountLabel.text = "\(count)/\(maxCharacterCount)"
        
        // Change color if approaching limit
        if count > maxCharacterCount - 50 && count <= maxCharacterCount {
            characterCountLabel.textColor = .systemOrange
        } else if count > maxCharacterCount {
            characterCountLabel.textColor = .systemRed
            // Trim text if exceeds limit
            textView.text = String(textView.text.prefix(maxCharacterCount))
            characterCountLabel.text = "\(maxCharacterCount)/\(maxCharacterCount)"
        } else {
            characterCountLabel.textColor = .systemGray
        }
    }
    
    // MARK: - Actions
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        
        // Update star appearance
        for i in 0..<ratingStackView.arrangedSubviews.count {
            if let button = ratingStackView.arrangedSubviews[i] as? UIButton {
                let imageName = i < selectedRating ? "star.fill" : "star"
                button.setImage(UIImage(systemName: imageName), for: .normal)
            }
        }
    }
    
    @objc private func submitButtonTapped() {
        guard feedbackTextView.textColor != .placeholderText && !feedbackTextView.text.isEmpty else {
            showAlert(title: "Empty Feedback", message: "Please enter your feedback before submitting.")
            return
        }
        
        // Validate email if provided
        if let email = emailTextField.text, !email.isEmpty {
            if !isValidEmail(email) {
                showAlert(title: "Invalid Email", message: "Please enter a valid email address or leave it blank.")
                return
            }
        }
        
        // Get the feedback type
        let feedbackType = ["Suggestion", "Bug Report", "Praise"][feedbackTypeSegmentedControl.selectedSegmentIndex]
        
        // In a real app, this would send the feedback to a server
        // For now, we'll just show a success message
        
        // Save feedback to local database
        saveFeedbackToDatabase(type: feedbackType, content: feedbackTextView.text, email: emailTextField.text, rating: selectedRating)
        
        // Create a thank you message that includes details of what was submitted
        var confirmationMessage = "Your \(feedbackType.lowercased()) has been submitted successfully."
        
        if selectedRating > 0 {
            confirmationMessage += "\n\nYou rated us \(selectedRating)/5 stars."
        }
        
        if let email = emailTextField.text, !email.isEmpty {
            confirmationMessage += "\n\nWe'll respond to you at \(email) if needed."
        }
        
        confirmationMessage += "\n\nThank you for helping us improve the Faby app!"
        
        showAlert(title: "Thank You!", message: confirmationMessage) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func saveFeedbackToDatabase(type: String, content: String, email: String?, rating: Int) {
        // In a real app, this would save to a local database or send to a server
        // For demonstration purposes, we'll just print to console
        print("Saving feedback - Type: \(type), Content: \(content), Email: \(email ?? "Not provided"), Rating: \(rating > 0 ? "\(rating)/5" : "Not provided")")
        
        // This is where you would implement your database logic
        // Example:
        // let feedback = Feedback(
        //     type: type,
        //     content: content,
        //     email: email,
        //     rating: rating > 0 ? rating : nil,
        //     timestamp: Date()
        // )
        // DatabaseManager.shared.saveFeedback(feedback)
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alertController, animated: true)
    }
}
