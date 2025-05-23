import UIKit
import Supabase

// Delegate protocol for baby signup completion
protocol ModernBabySignupViewControllerDelegate: AnyObject {
    func didTapBackButton()
    func didCompleteBabySignup()
}

class ModernBabySignupViewController: UIViewController {
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let backButton = UIButton(type: .system)
    private let stepsIndicatorView = UIView()
    
    // Labels for fields
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()
    private let genderLabel = UILabel()
    
    // Input fields
    private let nameTextField = UITextField()
    private let ageTextField = UITextField()
    private let genderSegmentedControl = UISegmentedControl(items: ["Boy", "Girl"])
    
    // Signup button
    private let completeSignupButton = UIButton(type: .system)
    
    // MARK: - Properties
    var userEmail: String?
    var userName: String?
    var userRelationship: String?
    var userPassword: String?
    
    weak var delegate: ModernBabySignupViewControllerDelegate?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Setup back button
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backButton)
        
        // Setup step indicators
        let stepIndicatorContainer = UIView()
        stepIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepIndicatorContainer)
        
        // Create dots for step indicator
        let firstDot = UIView()
        firstDot.translatesAutoresizingMaskIntoConstraints = false
        firstDot.backgroundColor = UIColor.lightGray
        firstDot.layer.cornerRadius = 4
        stepIndicatorContainer.addSubview(firstDot)
        
        let secondDot = UIView()
        secondDot.translatesAutoresizingMaskIntoConstraints = false
        secondDot.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Apple blue
        secondDot.layer.cornerRadius = 4
        stepIndicatorContainer.addSubview(secondDot)
        
        // Setup labels
        nameLabel.text = "Baby's Name"
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        ageLabel.text = "Age (months)"
        ageLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        ageLabel.textColor = .label
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageLabel)
        
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        genderLabel.textColor = .label
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderLabel)
        
        // Setup text fields
        setupTextField(nameTextField, placeholder: "Enter baby's name", keyboardType: .default)
        contentView.addSubview(nameTextField)
        
        setupTextField(ageTextField, placeholder: "Enter age in months", keyboardType: .numberPad)
        contentView.addSubview(ageTextField)
        
        // Setup gender segmented control
        genderSegmentedControl.selectedSegmentIndex = 0 // Default to Boy
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderSegmentedControl)
        
        // Complete signup button
        completeSignupButton.setTitle("Complete Signup", for: .normal)
        completeSignupButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        completeSignupButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Apple blue
        completeSignupButton.setTitleColor(.white, for: .normal)
        completeSignupButton.layer.cornerRadius = 10
        completeSignupButton.addTarget(self, action: #selector(completeSignupButtonTapped), for: .touchUpInside)
        completeSignupButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(completeSignupButton)
        
        // Setup constraints - making sure all elements are properly anchored
        NSLayoutConstraint.activate([
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Back Button
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Step Indicator Container
            stepIndicatorContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stepIndicatorContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stepIndicatorContainer.widthAnchor.constraint(equalToConstant: 30),
            stepIndicatorContainer.heightAnchor.constraint(equalToConstant: 20),
            
            // Dots
            firstDot.leadingAnchor.constraint(equalTo: stepIndicatorContainer.leadingAnchor),
            firstDot.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            firstDot.widthAnchor.constraint(equalToConstant: 8),
            firstDot.heightAnchor.constraint(equalToConstant: 8),
            
            secondDot.leadingAnchor.constraint(equalTo: firstDot.trailingAnchor, constant: 8),
            secondDot.centerYAnchor.constraint(equalTo: stepIndicatorContainer.centerYAnchor),
            secondDot.widthAnchor.constraint(equalToConstant: 8),
            secondDot.heightAnchor.constraint(equalToConstant: 8),
            
            // Baby name label
            nameLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Baby name text field
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Age label
            ageLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            ageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Age text field
            ageTextField.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 8),
            ageTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ageTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ageTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Gender label
            genderLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Gender segmented control
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Complete signup button
            completeSignupButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 40),
            completeSignupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completeSignupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            completeSignupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType) {
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.delegate = self
        
        // Add padding to text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Add bottom border
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 1, width: textField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.systemGray4.cgColor
        textField.layer.addSublayer(bottomLine)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    @objc private func completeSignupButtonTapped() {
        // Validate inputs
        guard let babyName = nameTextField.text, !babyName.isEmpty,
              let ageText = ageTextField.text, !ageText.isEmpty,
              let age = Int(ageText),
              let email = userEmail, !email.isEmpty,
              let name = userName, !name.isEmpty,
              let relationship = userRelationship, !relationship.isEmpty,
              let password = userPassword, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields")
            return
        }
        
        // Get gender
        let genderOptions = ["Boy", "Girl"]
        let gender = genderOptions[genderSegmentedControl.selectedSegmentIndex]
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // Disable buttons during signup process
        completeSignupButton.isEnabled = false
        backButton.isEnabled = false
        
        Task {
            do {
                print("DEBUG: Starting baby signup process")
                
                // Check if user is already authenticated (from OTP verification)
                print("DEBUG: Checking for existing authenticated user")
                let session = try? await supabase.auth.session
                
                // Get the user ID - either from existing session or by signing up
                let userId: UUID
                let userIdString: String
                
                if let existingSession = session {
                    // User is already authenticated from OTP verification
                    userId = existingSession.user.id
                    userIdString = userId.uuidString
                    print("DEBUG: Using existing authenticated user. User ID: \(userId) (String: \(userIdString))")
                } else {
                    // User is not authenticated, sign them up
                    print("DEBUG: No existing session found. Signing up user with email: \(email)")
                    let signUpResponse = try await supabase.auth.signUp(email: email, password: password)
                    userId = signUpResponse.user.id
                    userIdString = userId.uuidString
                    print("DEBUG: User signup successful. User ID: \(userId) (String: \(userIdString))")
                }
                
                // First check if parent record exists and create it if needed
                print("DEBUG: Checking if parent profile exists in 'parents' table")
                
                // Query to find parent by user ID
                let parentQuery = try await supabase.database
                    .from("parents")
                    .select()
                    .eq("uid", value: userIdString)
                    .execute()
                
                // Parse the response to check if parent exists
                struct ParentRecord: Decodable {
                    let uid: String
                }
                
                let decoder = JSONDecoder()
                let parentRecords = try decoder.decode([ParentRecord].self, from: parentQuery.data)
                
                if parentRecords.isEmpty {
                    // Parent record doesn't exist, create it
                    print("DEBUG: No parent record found, creating new parent profile")
                    
                    // Create parent record with user ID as the uid
                    struct ParentInsert: Encodable {
                        let uid: String
                        let email: String
                        let name: String
                        let relationship: String
                        let parentimage_url: String?
                    }
                    
                    let parentInsert = ParentInsert(
                        uid: userIdString,  // Use the authenticated user's ID as the uid
                        email: email,
                        name: name,
                        relationship: relationship,
                        parentimage_url: nil
                    )
                    
                    print("DEBUG: Parent data to insert: \(parentInsert)")
                    
                    try await supabase.database
                        .from("parents")
                        .insert(parentInsert)
                        .execute()
                    
                    print("DEBUG: Parent profile created successfully")
                } else {
                    print("DEBUG: Parent record already exists, proceeding with baby creation")
                }
                
                // Now create the baby profile in the 'baby' table
                print("DEBUG: Creating baby profile")
                
                // Convert age to DOB string
                let dobString = formatDOBFromAge(age)
                
                // Map gender to database format
                let dbGender = mapGenderForDatabase(gender)
                
                // Create baby record with reference to parent
                struct BabyInsert: Encodable {
                    let name: String
                    let dob: String
                    let gender: String
                    let image_url: String?
                    let region: String?
                    let user_id: String
                }
                
                let babyInsert = BabyInsert(
                    name: babyName,
                    dob: dobString,
                    gender: dbGender,
                    image_url: nil,
                    region: nil,
                    user_id: userIdString  // Link baby to the same user ID
                )
                
                print("DEBUG: Baby data to insert: \(babyInsert)")
                
                try await supabase.database
                    .from("baby")
                    .insert(babyInsert)
                    .execute()
                
                print("DEBUG: Baby profile created successfully")
                
                // Update parent record with baby reference if needed
                // This step might be handled by database triggers or RLS policies
                
                // Update session state to completed
                UserSessionManager.shared.completeSignup()
                
                // Update UI on main thread
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    
                    // Re-enable buttons
                    completeSignupButton.isEnabled = true
                    backButton.isEnabled = true
                    
                    print("DEBUG: Signup process completed successfully")
                    
                    // Post notification that signup is complete
                    NotificationCenter.default.post(name: Notification.Name("SignupCompleted"), object: nil)
                    
                    // Notify delegate that signup is complete
                    delegate?.didCompleteBabySignup()
                }
            } catch {
                // Handle error on main thread
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    
                    // Re-enable buttons
                    completeSignupButton.isEnabled = true
                    backButton.isEnabled = true
                    
                    print("DEBUG: Signup failed with error: \(error)")
                    
                    // Show error alert
                    showAlert(title: "Signup Failed", message: "\(error.localizedDescription)")
                }
            }
        }
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
        let textFields = [nameTextField, ageTextField]
        return textFields.first(where: { $0.isFirstResponder })
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    // Helper function to convert age in months to a date string (DDMMYYYY format)
    private func formatDOBFromAge(_ ageInMonths: Int) -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Calculate birth date by subtracting months from current date
        if let birthDate = calendar.date(byAdding: .month, value: -ageInMonths, to: currentDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ddMMyyyy"
            return dateFormatter.string(from: birthDate)
        }
        
        // Fallback to current date if calculation fails
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    // Helper function to map UI gender values to database-compatible values
    private func mapGenderForDatabase(_ uiGender: String) -> String {
        // Map UI gender values to database values based on the check constraint
        switch uiGender {
        case "Boy":
            return "male" // Lowercase for database
        case "Girl":
            return "female" // Lowercase for database
        default:
            return "other" // Default fallback
        }
    }
}

// MARK: - UITextFieldDelegate
extension ModernBabySignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            ageTextField.becomeFirstResponder()
        case ageTextField:
            dismissKeyboard()
            completeSignupButtonTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
