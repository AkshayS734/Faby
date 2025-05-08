import UIKit
import Supabase

// Extension to support font traits
extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

// Delegate protocol for signup completion
protocol ModernSignupViewControllerDelegate: AnyObject {
    func didFinishUserSignup(with userInfo: [String: String])
}

class ModernSignupViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let accountIconImageView = UIImageView()
    private let subtitleLabel = UILabel()
    private let stepsIndicatorView = UIView()
    
    // Field labels
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let relationshipLabel = UILabel()
    private let passwordLabel = UILabel()
    private let confirmPasswordLabel = UILabel()
    
    // Input fields
    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    let relationshipTextField = UITextField() // Changed from private to internal for extension access
    // Relationship options for dropdown
    let relationshipOptions = ["Father", "Mother", "Other"]
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    
    // Buttons and additional labels
    private let nextButton = UIButton(type: .system)
    private let signInButton = UIButton(type: .system)
    private let termsLabel = UILabel()
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
    )
    
    // Delegate for handling signup completion
    weak var delegate: ModernSignupViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupNavigationBar() {
        // Set up navigation bar with centered title
        navigationItem.title = "Create Account"
        
        // Disable large titles - we want a standard navigation bar
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // Add cancel button on left
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Style navigation bar - transparent initially, white when scrolling
        if #available(iOS 13.0, *) {
            // Standard appearance (when scrolling)
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithDefaultBackground()
            standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            // Scroll edge appearance (when at top)
            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            navigationController?.navigationBar.standardAppearance = standardAppearance
            navigationController?.navigationBar.compactAppearance = standardAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        } else {
            // For iOS 12 and below
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    @objc private func cancelButtonTapped() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Dismiss the view controller
        dismiss(animated: true)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Base setup
        view.backgroundColor = .systemBackground
        
        // ScrollView setup for iOS native scrolling
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // Content view setup
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Account Icon - iOS native style
        if #available(iOS 13.0, *) {
            accountIconImageView.image = UIImage(systemName: "person.crop.circle.badge.plus")
            accountIconImageView.tintColor = .systemBlue
        } else {
            // Fallback for iOS 12 and below - use a simple circle
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
            let circleImage = renderer.image { ctx in
                let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
                ctx.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
                ctx.cgContext.setLineWidth(2)
                ctx.cgContext.addEllipse(in: rect)
                ctx.cgContext.drawPath(using: .stroke)
            }
            accountIconImageView.image = circleImage
        }
        accountIconImageView.contentMode = .scaleAspectFit
        accountIconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(accountIconImageView)
        
        // Subtitle Label - iOS native style
        subtitleLabel.text = "Enter user details"
        if #available(iOS 13.0, *) {
            subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            subtitleLabel.textColor = .secondaryLabel
        } else {
            subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            subtitleLabel.textColor = .darkGray
        }
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Create name label
        nameLabel.text = "Full Name"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Create email label
        emailLabel.text = "Email"
        emailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        emailLabel.textColor = .label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        // Create password label
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        passwordLabel.textColor = .label
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordLabel)
        
        // Create confirm password label
        confirmPasswordLabel.text = "Confirm Password"
        confirmPasswordLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        confirmPasswordLabel.textColor = .label
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmPasswordLabel)
        
        // Create step indicator with dots
        let stepIndicatorContainer = UIView()
        stepIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepIndicatorContainer)
        
        // Create the dots
        let firstDot = UIView()
        firstDot.translatesAutoresizingMaskIntoConstraints = false
        firstDot.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Apple blue
        firstDot.layer.cornerRadius = 4
        stepIndicatorContainer.addSubview(firstDot)
        
        let secondDot = UIView()
        secondDot.translatesAutoresizingMaskIntoConstraints = false
        secondDot.backgroundColor = UIColor.lightGray
        secondDot.layer.cornerRadius = 4
        stepIndicatorContainer.addSubview(secondDot)
        
        // Text Fields setup
        setupTextField(
            nameTextField,
            placeholder: "Enter your full name",
            keyboardType: .default
        )
        contentView.addSubview(nameTextField)
        
        setupTextField(
            emailTextField,
            placeholder: "Enter your email address",
            keyboardType: .emailAddress
        )
        contentView.addSubview(emailTextField)
        
        // Relationship dropdown setup
        relationshipLabel.text = "Relationship with Baby"
        relationshipLabel.font = UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        relationshipLabel.textColor = .label
        relationshipLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(relationshipLabel)
        
        // Configure relationship text field with dropdown style
        setupTextField(
            relationshipTextField,
            placeholder: "Select relationship",
            keyboardType: .default,
            isSecure: false
        )
        relationshipTextField.text = relationshipOptions[0] // Default to "Father"
        
        // Add dropdown arrow indicator
        let chevronImage = UIImage(systemName: "chevron.down")
        let chevronImageView = UIImageView(image: chevronImage)
        chevronImageView.tintColor = .systemGray
        chevronImageView.contentMode = .scaleAspectFit
        
        // Configure the chevron as right view
        let chevronContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        chevronImageView.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        chevronContainer.addSubview(chevronImageView)
        relationshipTextField.rightView = chevronContainer
        relationshipTextField.rightViewMode = .always
        
        // Make the text field non-editable (will show dropdown instead)
        relationshipTextField.inputView = UIView()
        relationshipTextField.tintColor = .clear
        
        // Add tap gesture to show dropdown
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showRelationshipPicker))
        relationshipTextField.addGestureRecognizer(tapGesture)
        relationshipTextField.isUserInteractionEnabled = true
        
        contentView.addSubview(relationshipTextField)
        
        setupTextField(
            passwordTextField,
            placeholder: "Create password",
            keyboardType: .default,
            isSecure: true
        )
        contentView.addSubview(passwordTextField)
        
        setupTextField(
            confirmPasswordTextField,
            placeholder: "Confirm your password",
            keyboardType: .default,
            isSecure: true
        )
        contentView.addSubview(confirmPasswordTextField)
        
        // Next Button - iOS native style
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3).withTraits(.traitBold)
        nextButton.backgroundColor = UIColor.systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 12
        
        // Add subtle shadow for depth
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        nextButton.layer.shadowRadius = 4
        nextButton.layer.shadowOpacity = 0.1
        
        // Add haptic feedback on tap
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nextButton)
        
        // Already have an account label and sign in button - iOS native style
        let attributedString = NSMutableAttributedString(string: "Already have an account? ", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ])
        attributedString.append(NSAttributedString(string: "Sign in", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.preferredFont(forTextStyle: .subheadline).withTraits(.traitBold)
        ]))
        
        signInButton.setAttributedTitle(attributedString, for: .normal)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        // Add haptic feedback on tap
        if #available(iOS 10.0, *) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signInButtonTappedWithHaptic))
            signInButton.addGestureRecognizer(tapGesture)
        }
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(signInButton)
        
        // Terms and conditions - iOS native style
        termsLabel.text = "By signing up, you agree to our Terms of Service and Privacy Policy"
        termsLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        termsLabel.textColor = UIColor.secondaryLabel // iOS gray (#8E8E93)
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(termsLabel)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Account Icon - iOS native style
            accountIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            accountIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            accountIconImageView.widthAnchor.constraint(equalToConstant: 80),
            accountIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Subtitle Label - iOS native style
            subtitleLabel.topAnchor.constraint(equalTo: accountIconImageView.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Step indicators
            stepIndicatorContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            stepIndicatorContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stepIndicatorContainer.heightAnchor.constraint(equalToConstant: 8),
            stepIndicatorContainer.widthAnchor.constraint(equalToConstant: 24),
            
            firstDot.leadingAnchor.constraint(equalTo: stepIndicatorContainer.leadingAnchor),
            firstDot.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            firstDot.widthAnchor.constraint(equalToConstant: 8),
            firstDot.heightAnchor.constraint(equalToConstant: 8),
            
            secondDot.leadingAnchor.constraint(equalTo: firstDot.trailingAnchor, constant: 8),
            secondDot.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            secondDot.widthAnchor.constraint(equalToConstant: 8),
            secondDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: stepIndicatorContainer.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Name TextField
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Email label
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Relationship Label
            relationshipLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            relationshipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            relationshipLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Relationship TextField (Dropdown)
            relationshipTextField.topAnchor.constraint(equalTo: relationshipLabel.bottomAnchor, constant: 8),
            relationshipTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            relationshipTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            relationshipTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password label
            passwordLabel.topAnchor.constraint(equalTo: relationshipTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Confirm Password label
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Confirm Password TextField
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Next Button
            nextButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 32),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign In Button
            signInButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 16),
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Terms Label
            termsLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 24),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            termsLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType, isSecure: Bool = false) {
        // Set placeholder with callout style
        let placeholderAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout),
            NSAttributedString.Key.foregroundColor: UIColor.placeholderText
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        
        // Configure text field properties
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 8
        textField.font = UIFont.preferredFont(forTextStyle: .callout)
        textField.tintColor = UIColor.systemBlue // Cursor color
        
        // Add subtle border
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0).cgColor // #D1D1D6
        
        // Add padding to the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Auto-capitalize appropriately
        if keyboardType == .emailAddress {
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        } else if keyboardType == .default {
            textField.autocapitalizationType = .words
        }
        
        // Add eye icon for password fields with toggle functionality
        if isSecure {
            let rightButton = UIButton(type: .custom)
            rightButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            rightButton.tintColor = .systemGray
            rightButton.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
            rightButton.contentMode = .center
            rightButton.tag = textField.hash
            rightButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
            textField.rightView = rightButton
            textField.rightViewMode = .always
        }
        
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Validate inputs
        guard validateInputs() else {
            return
        }
        
        // Get user info and notify delegate
        let userInfo = getUserInfo()
        delegate?.didFinishUserSignup(with: userInfo)
    }
    
    // Public method to validate inputs for swipe navigation
    func validateInputs() -> Bool {
        // Check for empty fields
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields.")
            return false
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return false
        }
        
        // Validate password match
        if password != confirmPassword {
            showAlert(title: "Passwords Don't Match", message: "The passwords you entered don't match.")
            return false
        }
        
        return true
    }
    
    // Public method to get user info for swipe navigation
    func getUserInfo() -> [String: String] {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let relationship = relationshipTextField.text ?? relationshipOptions[0] // Use text from dropdown
        
        return [
            "name": name,
            "email": email,
            "relationship": relationship,
            "password": password
        ]
    }
    
    @objc private func signInButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func signInButtonTappedWithHaptic() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        // Call the original method
        signInButtonTapped()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Adjust content to ensure the active text field is visible
            if view.frame.origin.y == 0 {
                let activeTextField = findActiveTextField()
                if let activeField = activeTextField {
                    let textFieldFrame = activeField.convert(activeField.bounds, to: view)
                    let textFieldBottom = textFieldFrame.origin.y + textFieldFrame.size.height
                    let keyboardTop = view.frame.size.height - keyboardSize.height
                    
                    // If the bottom of the text field is below the top of the keyboard, adjust the view
                    if textFieldBottom > keyboardTop {
                        view.frame.origin.y = keyboardTop - textFieldBottom - 20 // Extra space for padding
                    }
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset the view position
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: - Helper Methods
    private func findActiveTextField() -> UITextField? {
        let textFields = [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        return textFields.first(where: { $0.isFirstResponder })
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension ModernSignupViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Add subtle parallax effect to title and subtitle
        let offset = scrollView.contentOffset.y
        
        // Only apply effects when scrolling down
        if offset > 0 {
            // Fade out title and subtitle gradually as user scrolls
            let alpha = max(0, 1 - (offset / 100))
            titleLabel.alpha = alpha
            subtitleLabel.alpha = alpha
            
            // Subtle scale effect
            let scale = max(0.8, 1 - (offset / 200))
            titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
            subtitleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            // Reset when at top or pulled down (bounce effect)
            titleLabel.alpha = 1.0
            subtitleLabel.alpha = 1.0
            titleLabel.transform = .identity
            subtitleLabel.transform = .identity
        }
    }
}

// MARK: - UITextFieldDelegate
extension ModernSignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            nextButtonTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
