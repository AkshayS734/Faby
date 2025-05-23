import UIKit
import Supabase

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let resetButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Configure view with light blue background tint
        view.backgroundColor = UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0) // Very light blue tint
        
        // Content view setup
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 10
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Title label
        titleLabel.text = "Forgot Password"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Subtitle label
        subtitleLabel.text = "Enter your email address and we'll send you a link to reset your password."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Email label
        emailLabel.text = "Email"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        // Email text field
        setupTextField(emailTextField, placeholder: "Enter your email address", keyboardType: .emailAddress)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        // Reset button
        resetButton.setTitle("Reset Password", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 12
        resetButton.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetButton)
        
        // Close button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray3
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        // Set placeholder with callout style
        let placeholderAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout),
            NSAttributedString.Key.foregroundColor: UIColor.placeholderText
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: placeholderAttributes)
        
        // Configure text field properties
        textField.keyboardType = keyboardType
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content view constraints - centered with padding
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Close button - positioned at top right
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Email label
            emailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Email text field
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24),
            resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            resetButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions
    @objc private func resetPasswordTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Email Required", message: "Please enter your email address to reset your password.")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // Disable reset button during request
        resetButton.isEnabled = false
        
        // Instead of just sending a reset email, we'll now present the OTP verification screen
        presentOTPVerification(email: email)
        
        // Hide loading indicator and re-enable button
        loadingIndicator.stopAnimating()
        resetButton.isEnabled = true
    }
    
    private func presentOTPVerification(email: String) {
        let otpVC = ForgotPasswordOTPViewController()
        otpVC.userEmail = email
        otpVC.delegate = self
        
        let navController = UINavigationController(rootViewController: otpVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func presentCreateNewPasswordScreen(email: String, token: String) {
        let createPasswordVC = CreateNewPasswordViewController()
        createPasswordVC.userEmail = email
        createPasswordVC.otpToken = token
        createPasswordVC.delegate = self
        
        // Replace the current view controller with the new one
        if let navigationController = self.presentedViewController as? UINavigationController {
            navigationController.pushViewController(createPasswordVC, animated: true)
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
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

// MARK: - ForgotPasswordOTPViewControllerDelegate
extension ForgotPasswordViewController: ForgotPasswordOTPViewControllerDelegate {
    func didVerifyForgotPasswordOTP(email: String, token: String) {
        // Present the create new password screen
        presentCreateNewPasswordScreen(email: email, token: token)
    }
    
    func didCancelForgotPasswordOTP() {
        // Dismiss the OTP verification screen
        dismiss(animated: true)
    }
}

// MARK: - CreateNewPasswordViewControllerDelegate
extension ForgotPasswordViewController: CreateNewPasswordViewControllerDelegate {
    func didResetPassword() {
        // Dismiss all screens and return to the auth screen
        dismiss(animated: true)
        
        // Show success message on the auth screen
        let alertController = UIAlertController(
            title: "Password Reset Successful",
            message: "Your password has been reset successfully. You can now sign in with your new password.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let presentingVC = presentingViewController {
            presentingVC.present(alertController, animated: true)
        }
    }
    
    func didCancelPasswordReset() {
        // Dismiss all screens and return to the auth screen
        dismiss(animated: true)
    }
}
