import UIKit
import Supabase

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signInWithAppleButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let registerNowButton = UIButton(type: .system)
    private let orLabel = UILabel()
    
    // MARK: - Supabase Client
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content view setup
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.text = "Sign In"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = UIColor.systemGray6
        emailTextField.layer.cornerRadius = 8
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .none
        passwordTextField.backgroundColor = UIColor.systemGray6
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        
        // Add eye button for password visibility
        let eyeButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            eyeButton.tintColor = .systemGray
        }
        eyeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        let eyeContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        eyeButton.center = eyeContainerView.center
        eyeContainerView.addSubview(eyeButton)
        
        passwordTextField.rightView = eyeContainerView
        passwordTextField.rightViewMode = .always
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        // Forgot Password Button
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.systemPurple, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgotPasswordButton.contentHorizontalAlignment = .right
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(forgotPasswordButton)
        
        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        loginButton.backgroundColor = .systemPurple
        loginButton.layer.cornerRadius = 12
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loginButton)
        
        // Or Label
        orLabel.text = "Or"
        orLabel.textColor = .secondaryLabel
        orLabel.font = UIFont.systemFont(ofSize: 14)
        orLabel.textAlignment = .center
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orLabel)
        
        // Sign in with Apple Button
        signInWithAppleButton.setTitle("Sign in with Apple", for: .normal)
        signInWithAppleButton.setTitleColor(.white, for: .normal)
        signInWithAppleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        signInWithAppleButton.backgroundColor = .darkGray
        signInWithAppleButton.layer.cornerRadius = 12
        
        // Add Apple logo
        if #available(iOS 13.0, *) {
            let appleImage = UIImage(systemName: "applelogo")
            signInWithAppleButton.setImage(appleImage, for: .normal)
            signInWithAppleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            signInWithAppleButton.tintColor = .white
        }
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(signInWithAppleButton)
        
        // Register Now Button
        let attributedString = NSMutableAttributedString(string: "Don't have an account? ", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 14)
        ])
        attributedString.append(NSAttributedString(string: "Register Now", attributes: [
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        
        registerNowButton.setAttributedTitle(attributedString, for: .normal)
        registerNowButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(registerNowButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view fills the view controller's view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view fills the scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            // Title Label - positioned at the top left
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Forgot Password Button
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Or Label
            orLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Sign in with Apple Button
            signInWithAppleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Register Now Button
            registerNowButton.topAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: 24),
            registerNowButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerNowButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        signInWithAppleButton.addTarget(self, action: #selector(signInWithAppleTapped), for: .touchUpInside)
        registerNowButton.addTarget(self, action: #selector(registerNowTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        
        if #available(iOS 13.0, *) {
            let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Sign in failed", message: "Please enter email and password")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // Disable login button during sign-in process
        loginButton.isEnabled = false
        
        Task {
            do {
                let session = try await supabase.auth.signIn(email: email, password: password)
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    navigateToHome()
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loginButton.isEnabled = true
                    showAlert(title: "Login failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func forgotPasswordTapped() {
        // Implement forgot password functionality
        let alertController = UIAlertController(title: "Reset Password", message: "Enter your email to receive a password reset link", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            guard let email = alertController.textFields?.first?.text, !email.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter a valid email")
                return
            }
            
            // Send password reset email
            Task {
                do {
                    try await self?.supabase.auth.resetPasswordForEmail(email)
                    await MainActor.run {
                        self?.showAlert(title: "Success", message: "Password reset link sent to your email")
                    }
                } catch {
                    await MainActor.run {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(resetAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func signInWithAppleTapped() {
        // Implement Sign in with Apple
        showAlert(title: "Coming Soon", message: "Sign in with Apple will be available soon!")
    }
    
    @objc private func registerNowTapped() {
        // Navigate to registration screen
        let signupVC = SignupContainerViewController()
        signupVC.modalPresentationStyle = .fullScreen
        present(signupVC, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToHome() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            if let navigationController = self.navigationController {
                navigationController.setViewControllers([homeVC], animated: true)
            } else {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let navController = UINavigationController(rootViewController: homeVC)
                    sceneDelegate.window?.rootViewController = navController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
