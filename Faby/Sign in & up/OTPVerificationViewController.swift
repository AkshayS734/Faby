import UIKit
import Supabase

// Protocol for handling OTP verification completion
protocol OTPVerificationViewControllerDelegate: AnyObject {
    func didVerifyOTP(email: String, password: String, userInfo: [String: String])
    func didTapBackFromOTP()
}

class OTPVerificationViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let subtitleLabel = UILabel()
    private let instructionLabel = UILabel()
    
    // OTP Input Fields
    private let otpStackView = UIStackView()
    private var otpTextFields: [UITextField] = []
    
    // Resend and Verify buttons
    private let resendButton = UIButton(type: .system)
    private let verifyButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Timer for resend functionality
    private var resendTimer: Timer?
    private var remainingTime = 30 // 30 seconds cooldown for resend
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    var userEmail: String = ""
    var userPassword: String = ""
    var userInfo: [String: String] = [:]
    
    weak var delegate: OTPVerificationViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupKeyboardHandling()
        sendOTP()
    }
    
    deinit {
        resendTimer?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        // Set up navigation bar with centered title
        navigationItem.title = "Verification"
        
        // Disable large titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // Add back button
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        
        // Style navigation bar
        if #available(iOS 13.0, *) {
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.configureWithDefaultBackground()
            standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            let scrollEdgeAppearance = UINavigationBarAppearance()
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            navigationController?.navigationBar.standardAppearance = standardAppearance
            navigationController?.navigationBar.compactAppearance = standardAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup icon
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: "shield.lock.fill")
            iconImageView.tintColor = .systemBlue
        } else {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
            let circleImage = renderer.image { ctx in
                let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
                ctx.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
                ctx.cgContext.setLineWidth(2)
                ctx.cgContext.addEllipse(in: rect)
                ctx.cgContext.drawPath(using: .stroke)
            }
            iconImageView.image = circleImage
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        
        // Setup subtitle
        subtitleLabel.text = "Verify your identity"
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Setup instruction label
        instructionLabel.text = "Enter the 6-digit code sent to your email"
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        instructionLabel.textColor = .label
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(instructionLabel)
        
        // Setup OTP stack view
        otpStackView.axis = .horizontal
        otpStackView.distribution = .fillEqually
        otpStackView.spacing = 10
        otpStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(otpStackView)
        
        // Create OTP text fields
        for i in 0..<6 {
            let textField = createOTPTextField()
            textField.tag = i
            otpTextFields.append(textField)
            otpStackView.addArrangedSubview(textField)
        }
        
        // Setup resend button
        resendButton.setTitle("Resend code (30s)", for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        resendButton.setTitleColor(.systemBlue, for: .normal)
        resendButton.isEnabled = false
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        contentView.addSubview(resendButton)
        
        // Setup verify button
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        verifyButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Apple blue
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.layer.cornerRadius = 12
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        contentView.addSubview(verifyButton)
        
        // Setup activity indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        setupConstraints()
        startResendTimer()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Icon
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Instruction
            instructionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // OTP Stack
            otpStackView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            otpStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            otpStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            otpStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // Resend Button
            resendButton.topAnchor.constraint(equalTo: otpStackView.bottomAnchor, constant: 24),
            resendButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Verify Button
            verifyButton.topAnchor.constraint(equalTo: resendButton.bottomAnchor, constant: 40),
            verifyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            verifyButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func createOTPTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 8
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.84, alpha: 1.0).cgColor
        
        // Limit to one character
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return textField
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - OTP Handling
    private func sendOTP() {
        guard !userEmail.isEmpty else {
            showAlert(title: "Error", message: "Email address is missing")
            return
        }
        
        activityIndicator.startAnimating()
        
        // Use Supabase to send OTP to the user's email
        Task {
            do {
                // Send OTP using Supabase
                try await supabase.auth.signInWithOTP(
                    email: userEmail
                )
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    // Focus on first OTP field
                    otpTextFields.first?.becomeFirstResponder()
                    
                    // Show success message
                    showAlert(title: "Verification Code Sent",
                             message: "A 6-digit verification code has been sent to \(userEmail). Please check your inbox and spam folder.")
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    showAlert(title: "Error", message: "Failed to send verification code: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startResendTimer() {
        remainingTime = 30
        updateResendButtonTitle()
        
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                self.updateResendButtonTitle()
            } else {
                timer.invalidate()
                self.resendButton.isEnabled = true
                self.resendButton.setTitle("Resend code", for: .normal)
            }
        }
    }
    
    private func updateResendButtonTitle() {
        resendButton.setTitle("Resend code (\(remainingTime)s)", for: .normal)
    }
    
    private func getOTPCode() -> String {
        return otpTextFields.map { $0.text ?? "" }.joined()
    }
    
    private func verifyOTP() {
        let otp = getOTPCode()
        
        guard otp.count == 6 else {
            showAlert(title: "Incomplete Code", message: "Please enter the complete 6-digit code")
            return
        }
        
        verifyButton.isEnabled = false
        activityIndicator.startAnimating()
        
        // Verify OTP with Supabase
        Task {
            do {
                // Verify the OTP code with Supabase
                let response = try await supabase.auth.verifyOTP(
                    email: userEmail,
                    token: otp,
                    type: .email // Use .email for OTP verification
                )
                
                // Check if we have a valid session
                if response.session != nil {
                    // Get the authenticated user ID
                    let userId = response.user.id
                    
                    // Store parent details in the parents table
                    try await storeParentDetails(userId: userId)
                    
                    // Save session information for persistence
                    if let session = response.session {
                        // Store session data for persistence
                        UserSessionManager.shared.saveEmailVerifiedSession(
                            email: userEmail,
                            password: userPassword,
                            userInfo: userInfo,
                            session: "session-placeholder" // We'll use credentials-based auth instead
                        )
                        print("DEBUG: Session saved after OTP verification")
                    }
                    
                    await MainActor.run {
                        activityIndicator.stopAnimating()
                        verifyButton.isEnabled = true
                        
                        // Notify delegate of successful verification
                        delegate?.didVerifyOTP(email: userEmail, password: userPassword, userInfo: userInfo)
                    }
                } else {
                    throw NSError(domain: "VerificationError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid verification code"])
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    verifyButton.isEnabled = true
                    showAlert(title: "Verification Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    // Store parent details in the parents table
    private func storeParentDetails(userId: UUID) async throws {
        print("DEBUG: Storing parent details in parents table after OTP verification")
        
        // Extract parent details from userInfo
        guard let name = userInfo["name"], !name.isEmpty,
              let relationship = userInfo["relationship"], !relationship.isEmpty else {
            print("DEBUG: Missing required parent information")
            throw NSError(domain: "ParentInfoError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing parent information"])
        }
        
        // Create parent record with user ID
        struct ParentInsert: Encodable {
            let uid: String  // This is the primary key for the parent record
            let email: String
            let name: String
            let relationship: String
            let parentimage_url: String?
            let baby_uid: String?
            let post_id: String?
        }
        
        let parentUid = UUID()
        let parentInsert = ParentInsert(
            uid: userId.uuidString,  // Using the authenticated user's ID as the uid
            email: userEmail,
            name: name,
            relationship: relationship,
            parentimage_url: nil,
            baby_uid: nil,  // Will be updated later when baby is created
            post_id: nil
        )
        
        print("DEBUG: Parent data to insert after OTP verification: \(parentInsert)")
        
        try await supabase.database
            .from("parents")
            .insert(parentInsert)
            .execute()
        
        print("DEBUG: Parent profile created successfully after OTP verification")
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        delegate?.didTapBackFromOTP()
    }
    
    @objc private func resendButtonTapped() {
        resendButton.isEnabled = false
        sendOTP()
        startResendTimer()
    }
    
    @objc private func verifyButtonTapped() {
        verifyOTP()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Limit to one character
        if let text = textField.text, text.count > 1 {
            textField.text = String(text.prefix(1))
        }
        
        // If a digit was entered, move to next field
        if let text = textField.text, text.count == 1 {
            if textField.tag < otpTextFields.count - 1 {
                otpTextFields[textField.tag + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
                // Automatically verify if all fields are filled
                if getOTPCode().count == 6 {
                    verifyOTP()
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.scrollIndicatorInsets.bottom = keyboardSize.height
            
            // Scroll to make OTP fields visible
            let activeRect = otpStackView.convert(otpStackView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(activeRect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension OTPVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only digits
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        let isBackspace = (string.isEmpty && range.length == 1)
        
        // Handle backspace
        if isBackspace {
            // If deleting and field is empty, move to previous field
            if (textField.text?.isEmpty ?? true) && textField.tag > 0 {
                otpTextFields[textField.tag - 1].becomeFirstResponder()
                otpTextFields[textField.tag - 1].text = ""
            }
            return true
        }
        
        // Allow only one digit
        if textField.text?.count ?? 0 >= 1 && range.length == 0 {
            // If already has a digit and user types another, replace it
            textField.text = string
            
            // Move to next field if available
            if textField.tag < otpTextFields.count - 1 {
                otpTextFields[textField.tag + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            return false
        }
        
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
