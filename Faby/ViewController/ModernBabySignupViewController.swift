import UIKit
import Supabase

class ModernBabySignupViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // Delegate to handle back navigation
    weak var delegate: BabySignupViewControllerDelegate?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let babyIconImageView = UIImageView()
    private let subtitleLabel = UILabel()
    
    // Removed back button from content area
    private let stepDotsView = UIView()
    private let firstDot = UIView()
    private let secondDot = UIView()
    
    private let babyNameLabel = UILabel()
    private let babyNameField = UITextField()
    
    private let ageLabel = UILabel()
    private let ageField = UITextField()
    
    private let genderLabel = UILabel()
    let genderTextField = UITextField() // Changed from private to internal for extension access
    // Modern dropdown used instead of UIPickerView
    let genderOptions = ["Boy", "Girl", "Other"] // Changed from private to internal for extension access
    
    private let completeButton = UIButton(type: .system)
    
    // MARK: - Properties
    var userEmail: String?
    var userName: String?
    var userRelationship: String?
    var userPassword: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        // Set up navigation bar with centered title
        navigationItem.title = "Create Account"
        
        // Disable large titles - we want a standard navigation bar
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // Add back button on left
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
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
    
    // MARK: - Setup Methods
    private func setupViews() {
        // Set up the scroll view and content view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Baby Icon - iOS native style
        if #available(iOS 13.0, *) {
            babyIconImageView.image = UIImage(systemName: "figure.and.child.holdinghands")
            babyIconImageView.tintColor = .systemBlue
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
            babyIconImageView.image = circleImage
        }
        babyIconImageView.contentMode = .scaleAspectFit
        babyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyIconImageView)
        
        // Subtitle Label - iOS native style
        subtitleLabel.text = "Enter your baby's details"
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
        
        // Back button removed - using navigation bar back button instead
        
        // Step indicator dots
        stepDotsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepDotsView)
        
        firstDot.translatesAutoresizingMaskIntoConstraints = false
        firstDot.backgroundColor = .systemGray
        firstDot.layer.cornerRadius = 4
        firstDot.clipsToBounds = true
        stepDotsView.addSubview(firstDot)
        
        secondDot.translatesAutoresizingMaskIntoConstraints = false
        secondDot.backgroundColor = .systemBlue
        secondDot.layer.cornerRadius = 4
        secondDot.clipsToBounds = true
        stepDotsView.addSubview(secondDot)
        
        // Baby name section
        babyNameLabel.text = "Baby's Name"
        babyNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        babyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyNameLabel)
        
        // Configure baby name field with consistent styling
        setupTextField(babyNameField, placeholder: "Enter baby's name")
        babyNameField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyNameField)
        
        // Age section
        ageLabel.text = "Age (months)"
        ageLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageLabel)
        
        // Configure age field with consistent styling
        setupTextField(ageField, placeholder: "Enter age in months", keyboardType: .numberPad)
        ageField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageField)
        
        // Gender section
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderLabel)
        
        // Setup gender dropdown field with consistent styling
        setupTextField(genderTextField, placeholder: "Select gender")
        genderTextField.tintColor = .clear // Hide cursor for dropdown
        
        // Add right chevron icon for dropdown appearance
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronImageView.tintColor = .systemGray
        chevronImageView.contentMode = .center
        chevronImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        genderTextField.rightView = chevronImageView
        genderTextField.rightViewMode = .always
        
        // Add padding to the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        genderTextField.leftView = paddingView
        genderTextField.leftViewMode = .always
        
        // Configure text field for dropdown
        genderTextField.inputView = UIView() // Prevent keyboard from showing
        genderTextField.tintColor = .clear // Hide cursor
        
        // Add toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        genderTextField.inputAccessoryView = toolbar
        
        // Add tap gesture to show picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showGenderPicker))
        genderTextField.addGestureRecognizer(tapGesture)
        genderTextField.isUserInteractionEnabled = true
        
        genderTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderTextField)
        
        // Pre-select Boy
        genderTextField.text = genderOptions[0]
        genderTextField.text = genderOptions[0]
        
        // Complete button
        completeButton.setTitle("Complete Signup", for: .normal)
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        completeButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Apple blue
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.layer.cornerRadius = 12
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeButton)
    }
    
    private func setupConstraints() {
        // Ensure all constraints are properly set up with views that have a common ancestor
        NSLayoutConstraint.activate([
            // Scroll view fills the view controller's view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view fills the scroll view and defines its content size
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            // Allow the content to scroll vertically if needed
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            // Baby Icon - iOS native style
            babyIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            babyIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            babyIconImageView.widthAnchor.constraint(equalToConstant: 80),
            babyIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Subtitle Label - iOS native style
            subtitleLabel.topAnchor.constraint(equalTo: babyIconImageView.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            
            // Back button constraints completely removed - using navigation bar back button instead
            
            // Step dots container
            stepDotsView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            stepDotsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stepDotsView.heightAnchor.constraint(equalToConstant: 8),
            stepDotsView.widthAnchor.constraint(equalToConstant: 24),
            
            // Individual dots
            firstDot.leftAnchor.constraint(equalTo: stepDotsView.leftAnchor),
            firstDot.centerYAnchor.constraint(equalTo: stepDotsView.centerYAnchor),
            firstDot.widthAnchor.constraint(equalToConstant: 8),
            firstDot.heightAnchor.constraint(equalToConstant: 8),
            
            secondDot.rightAnchor.constraint(equalTo: stepDotsView.rightAnchor),
            secondDot.centerYAnchor.constraint(equalTo: stepDotsView.centerYAnchor),
            secondDot.widthAnchor.constraint(equalToConstant: 8),
            secondDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Baby name section - positioned like user detail labels
            babyNameLabel.topAnchor.constraint(equalTo: stepDotsView.bottomAnchor, constant: 40),
            babyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            babyNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            babyNameField.topAnchor.constraint(equalTo: babyNameLabel.bottomAnchor, constant: 8),
            babyNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            babyNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            babyNameField.heightAnchor.constraint(equalToConstant: 50),
            
            // Age section - positioned like user detail labels
            ageLabel.topAnchor.constraint(equalTo: babyNameField.bottomAnchor, constant: 20),
            ageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            ageField.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 8),
            ageField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            ageField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            ageField.heightAnchor.constraint(equalToConstant: 50),
            // Gender section - positioned like user detail labels
            genderLabel.topAnchor.constraint(equalTo: ageField.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Gender dropdown field
            genderTextField.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            genderTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            genderTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Complete button
            completeButton.topAnchor.constraint(equalTo: genderTextField.bottomAnchor, constant: 40),
            completeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            completeButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 50),
            completeButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Picker Methods
    // showGenderPicker method moved to ModernBabySignupViewController+Dropdown.swift extension
    
    @objc private func dismissPicker() {
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
        // Animate the chevron rotation back
        if let chevron = genderTextField.rightView as? UIImageView {
            UIView.animate(withDuration: 0.3) {
                chevron.transform = .identity
            }
        }
        
        // No need to update text field - already handled in dropdown selection
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Force popover style even on iPhone
    }
    
    private func setupActions() {
        // Back button in navigation bar is already set up
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        // Use delegate to navigate back to the user details screen
        delegate?.didTapBackButton()
    }
    
    @objc private func completeButtonTapped() {
        // Validate inputs
        guard let babyName = babyNameField.text, !babyName.isEmpty,
              let ageText = ageField.text, !ageText.isEmpty,
              let age = Int(ageText),
              let email = userEmail,
              let password = userPassword,
              let name = userName,
              let relationship = userRelationship else {
            showAlert(title: "Missing Information", message: "Please fill in all required fields.")
            return
        }
        
        // Get selected gender from the text field
        guard let gender = genderTextField.text, !gender.isEmpty else {
            showAlert(title: "Missing Information", message: "Please select a gender.")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // Disable buttons during signup process
        completeButton.isEnabled = false
    
        
        // Create user account with Supabase
        Task {
            do {
                // First, sign up the user
                let _ = try await supabase.auth.signUp(email: email, password: password)
                
                // Then create the user profile
                try await supabase.database
                    .from("users")
                    .insert(
                        UserRow(
                            email: email,
                            name: name,
                            relationship: relationship
                        )
                    )
                    .execute()
                
                // Create the baby profile
                try await supabase.database
                    .from("babies")
                    .insert(
                        BabyRow(
                            name: babyName,
                            age: age,
                            gender: gender,
                            parentEmail: email
                        )
                    )
                    .execute()
                
                // Update UI on main thread
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    // Post notification that signup is complete
                    NotificationCenter.default.post(name: Notification.Name("SignupCompleted"), object: nil)
                }
            } catch {
                // Handle error on main thread
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    
                    // Re-enable button
                    self.completeButton.isEnabled = true
                    
                    // Show error alert
                    self.showAlert(title: "Signup Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
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
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// UIPickerViewDelegate & UIPickerViewDataSource implementation removed
// Replaced with ModernDropdownViewController

// MARK: - Models for Supabase
struct UserRow: Codable {
    let email: String
    let name: String
    let relationship: String
}

struct BabyRow: Codable {
    let name: String
    let age: Int
    let gender: String
    let parentEmail: String
}
