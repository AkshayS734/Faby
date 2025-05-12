import UIKit
import Supabase

// Protocol for handling password reset completion
protocol CreateNewPasswordViewControllerDelegate: AnyObject {
    func didResetPassword()
    func didCancelPasswordReset()
}

class CreateNewPasswordViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let passwordLabel = UILabel()
    private let passwordTextField = UITextField()
    private let passwordVisibilityButton = UIButton(type: .system)
    
    private let confirmPasswordLabel = UILabel()
    private let confirmPasswordTextField = UITextField()
    private let confirmPasswordVisibilityButton = UIButton(type: .system)
    
    private let resetButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    var userEmail: String = ""
    var otpToken: String = ""
    private var isPasswordVisible = false
    private var isConfirmPasswordVisible = false
    
    weak var delegate: CreateNewPasswordViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        // Set up navigation bar with centered title
        navigationItem.title = "Create New Password"
        
        // Disable large titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
        }
        
        // Add back button
        let backButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(backButtonTapped))
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
        
        // Setup title
        titleLabel.text = "Create New Password"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Setup subtitle
        subtitleLabel.text = "Your identity has been verified. Please create a new password for your account."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Setup password label
        passwordLabel.text = "New Password"
        passwordLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordLabel)
        
        // Setup password text field
        passwordTextField.placeholder = "Enter new password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = .systemGray6
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        // Setup password visibility button
        passwordVisibilityButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordVisibilityButton.tintColor = .systemGray
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordVisibilityButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordVisibilityButton)
        
        // Setup confirm password label
        confirmPasswordLabel.text = "Confirm Password"
        confirmPasswordLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmPasswordLabel)
        
        // Setup confirm password text field
        confirmPasswordTextField.placeholder = "Confirm new password"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.borderStyle = .roundedRect
        confirmPasswordTextField.backgroundColor = .systemGray6
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmPasswordTextField)
        
        // Setup confirm password visibility button
        confirmPasswordVisibilityButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        confirmPasswordVisibilityButton.tintColor = .systemGray
        confirmPasswordVisibilityButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        confirmPasswordVisibilityButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmPasswordVisibilityButton)
        
        // Setup reset button
        resetButton.setTitle("Reset Password", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 25
        resetButton.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetButton)
        
        // Setup activity indicator
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        setupConstraints()
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
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Password label
            passwordLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Password text field
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password visibility button
            passwordVisibilityButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            passwordVisibilityButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -8),
            passwordVisibilityButton.widthAnchor.constraint(equalToConstant: 30),
            passwordVisibilityButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Confirm password label
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Confirm password text field
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Confirm password visibility button
            confirmPasswordVisibilityButton.centerYAnchor.constraint(equalTo: confirmPasswordTextField.centerYAnchor),
            confirmPasswordVisibilityButton.trailingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor, constant: -8),
            confirmPasswordVisibilityButton.widthAnchor.constraint(equalToConstant: 30),
            confirmPasswordVisibilityButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
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
        delegate?.didCancelPasswordReset()
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility() {
        isConfirmPasswordVisible.toggle()
        confirmPasswordTextField.isSecureTextEntry = !isConfirmPasswordVisible
        let imageName = isConfirmPasswordVisible ? "eye" : "eye.slash"
        confirmPasswordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func resetPasswordTapped() {
        guard let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter and confirm your new password.")
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            showAlert(title: "Passwords Don't Match", message: "Please make sure your passwords match.")
            return
        }
        
        // Check password strength
        guard isPasswordStrong(password) else {
            showAlert(title: "Weak Password", message: "Password must be at least 8 characters long and include a mix of uppercase, lowercase, numbers, and special characters.")
            return
        }
        
        // Show loading indicator
        activityIndicator.startAnimating()
        resetButton.isEnabled = false
        
        Task {
            do {
                // Check if we already have a valid session from the OTP verification
                if UserSessionManager.shared.supabaseSession == nil {
                    // If not, try to verify the OTP again to get a valid session
                    let response = try await supabase.auth.verifyOTP(
                        email: userEmail,
                        token: otpToken,
                        type: .email
                    )
                    
                    // Make sure we have a valid session
                    guard let session = response.session else {
                        // If direct verification fails, try using the stored OTP if available
                        if let storedOTP = UserDefaults.standard.string(forKey: "lastVerifiedOTP"),
                           let verificationTime = UserDefaults.standard.object(forKey: "otpVerificationTime") as? Double {
                            
                            // Check if the stored OTP is recent (within 5 minutes)
                            let currentTime = Date().timeIntervalSince1970
                            let timeDifference = currentTime - verificationTime
                            
                            if timeDifference < 300 { // 5 minutes in seconds
                                // Try with the stored OTP
                                let retryResponse = try await supabase.auth.verifyOTP(
                                    email: userEmail,
                                    token: storedOTP,
                                    type: .email
                                )
                                
                                if let retrySession = retryResponse.session {
                                    // Store the session token
                                    UserSessionManager.shared.supabaseSession = retrySession.accessToken
                                } else {
                                    throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to verify OTP token. Please try again."])
                                }
                            } else {
                                throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "OTP has expired. Please request a new verification code."])
                            }
                        } else {
                            throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to verify OTP token. Please try again."])
                        }
                        
                        // This ensures the guard body exits properly
                        return
                    }
                    
                    // Store the session token for future use
                    if UserSessionManager.shared.supabaseSession == nil, let accessToken = response.session?.accessToken {
                        UserSessionManager.shared.supabaseSession = accessToken
                    }
                }
                
                // Now use a direct API call to update the password
                // This is more reliable than other methods
                let url = URL(string: "https://tmnltannywgqrrxavoge.supabase.co/auth/v1/user")!
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                // Ensure we have a valid session token
                guard let sessionToken = UserSessionManager.shared.supabaseSession else {
                    throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "No valid session token found"])
                }
                request.setValue("Bearer " + sessionToken, forHTTPHeaderField: "Authorization")
                request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY", forHTTPHeaderField: "apikey")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Create the JSON payload with the new password
                let parameters: [String: Any] = ["password": password]
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                
                // Make the request
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Check if the request was successful
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to update password. No response received."])
                }
                
                // Check for token expiration or other errors
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    // Token expired or invalid, let's try to refresh the session
                    // First, try to verify the OTP again to get a fresh token
                    let refreshResponse = try await supabase.auth.verifyOTP(
                        email: userEmail,
                        token: otpToken,
                        type: .email
                    )
                    
                    if let newSession = refreshResponse.session {
                        // Store the new session token
                        UserSessionManager.shared.supabaseSession = newSession.accessToken
                        
                        // Update the request with the new token
                        request.setValue("Bearer " + newSession.accessToken, forHTTPHeaderField: "Authorization")
                        
                        // Try the request again
                        let (_, newResponse) = try await URLSession.shared.data(for: request)
                        
                        guard let newHttpResponse = newResponse as? HTTPURLResponse, 
                              newHttpResponse.statusCode >= 200 && newHttpResponse.statusCode < 300 else {
                            throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Failed to update password after token refresh."])
                        }
                    } else {
                        throw NSError(domain: "com.faby.error", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token has expired. Please try the password reset process again."])
                    }
                } else if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    // Handle other HTTP errors
                    var errorMessage = "Failed to update password. Please try again."
                    
                    // Try to extract error message from response if available
                    if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = responseData["message"] as? String {
                        errorMessage = message
                    }
                    
                    throw NSError(domain: "com.faby.error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    resetButton.isEnabled = true
                    
                    // Show success message
                    let alertController = UIAlertController(
                        title: "Password Reset Successful",
                        message: "Your password has been reset successfully. You can now sign in with your new password.",
                        preferredStyle: .alert
                    )
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.delegate?.didResetPassword()
                    })
                    
                    present(alertController, animated: true)
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    resetButton.isEnabled = true
                    showAlert(title: "Password Reset Failed", message: error.localizedDescription)
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
            
            // Scroll to make active text field visible
            if passwordTextField.isFirstResponder {
                let activeRect = passwordTextField.convert(passwordTextField.bounds, to: scrollView)
                scrollView.scrollRectToVisible(activeRect, animated: true)
            } else if confirmPasswordTextField.isFirstResponder {
                let activeRect = confirmPasswordTextField.convert(confirmPasswordTextField.bounds, to: scrollView)
                scrollView.scrollRectToVisible(activeRect, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Helper Methods
    private func isPasswordStrong(_ password: String) -> Bool {
        // Password must be at least 8 characters
        guard password.count >= 8 else { return false }
        
        // Check for uppercase, lowercase, number, and special character
        let uppercaseRegex = ".*[A-Z].*"
        let lowercaseRegex = ".*[a-z].*"
        let numberRegex = ".*[0-9].*"
        let specialCharRegex = ".*[^A-Za-z0-9].*"
        
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        let lowercasePredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        let specialCharPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharRegex)
        
        // For simplicity, we'll require at least 3 of the 4 criteria
        var criteriaCount = 0
        if uppercasePredicate.evaluate(with: password) { criteriaCount += 1 }
        if lowercasePredicate.evaluate(with: password) { criteriaCount += 1 }
        if numberPredicate.evaluate(with: password) { criteriaCount += 1 }
        if specialCharPredicate.evaluate(with: password) { criteriaCount += 1 }
        
        return criteriaCount >= 3
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
