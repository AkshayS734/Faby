import UIKit
import Supabase

class AuthViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let personIconView = UIImageView() // Person icon for iOS-native appearance
    private let titleLabel = UILabel()
    private let emailLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordLabel = UILabel()
    private let passwordTextField = UITextField()
    private let forgotPasswordButton = UIButton(type: .system)
    private let signInButton = UIButton(type: .system)
    private let signInLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let orLabel = UILabel()
    private let appleSignInButton = UIButton(type: .system)
    private let accountLabel = UILabel() // Label for 'Don't have an account?'
    private let createAccountButton = UIButton(type: .system)
    private let passwordVisibilityButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
    )
    
    private var isPasswordVisible = false

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupKeyboardObservers()
        setupTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupScrollView() {
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false  // Disable scrolling
        scrollView.alwaysBounceVertical = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Set up constraints for scroll view and content view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupGradientBackground() {
        // Configure gradient layer with light blue gradient like Apple Health app
        gradientLayer.colors = [
            UIColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,  // Light blue at top
            UIColor.white.cgColor  // White at bottom
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.3)  // Gradient fades to white faster
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupNavigationBar() {
        // Add back button to navigation bar with smooth appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemBlue
        
        // Configure navigation bar to be transparent initially
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        // Add a scroll edge appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    @objc private func backButtonTapped() {
        // Smooth transition back to walkthrough
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0.8
        }, completion: { _ in
            self.dismiss(animated: true)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        setupScrollView()
        setupGradientBackground()
        setupNavigationBar()
        
        // Sign In title - iOS native style (without icon)
        titleLabel.text = "Sign In"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Email label
        emailLabel.text = "Email"
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .label
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)
        
        // Email text field with white background (iOS-native style)
        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = .white
        emailTextField.layer.cornerRadius = 12
        emailTextField.layer.masksToBounds = false // Allow shadow
        // Add shadow to text field for depth
        emailTextField.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailTextField.layer.shadowRadius = 4
        emailTextField.layer.shadowOpacity = 1
        // Add padding inside text field
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: emailTextField.frame.height))
        emailTextField.rightView = paddingView
        emailTextField.rightViewMode = .unlessEditing
        // Style placeholder text
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3]
        )
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        // Password label
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        passwordLabel.textColor = .label
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordLabel)
        
        // Password text field with white background (iOS-native style)
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.borderStyle = .none
        passwordTextField.backgroundColor = .white
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.layer.masksToBounds = false // Allow shadow
        // Add shadow to text field for depth
        passwordTextField.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        passwordTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordTextField.layer.shadowRadius = 4
        passwordTextField.layer.shadowOpacity = 1
        passwordTextField.isSecureTextEntry = true
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
        // Add padding inside text field
        let passwordPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: passwordTextField.frame.height))
        passwordTextField.rightView = passwordPaddingView
        passwordTextField.rightViewMode = .unlessEditing
        passwordTextField.returnKeyType = .done
        // Style placeholder text
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3]
        )
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        // Password visibility button
        passwordVisibilityButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordVisibilityButton.tintColor = .systemGray
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordVisibilityButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordVisibilityButton)
        
        // Forgot password button
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(forgotPasswordButton)
        
        // Sign In button - Blue color (original style)
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        signInButton.backgroundColor = .systemBlue // Original blue color
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.layer.cornerRadius = 25
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup loading indicator
        signInLoadingIndicator.color = .white
        signInLoadingIndicator.hidesWhenStopped = true
        signInButton.addSubview(signInLoadingIndicator)
        signInLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInLoadingIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor),
            signInLoadingIndicator.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor, constant: -16)
        ])
        contentView.addSubview(signInButton)
        
        // Or label with lines on both sides
        orLabel.text = "Or"
        orLabel.font = UIFont.systemFont(ofSize: 14)
        orLabel.textColor = .secondaryLabel
        orLabel.textAlignment = .center
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orLabel)
        
        // Add left line view
        let leftLineView = UIView()
        leftLineView.backgroundColor = .systemGray4
        leftLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftLineView)
        
        // Add right line view
        let rightLineView = UIView()
        rightLineView.backgroundColor = .systemGray4
        rightLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightLineView)
        
        // Add constraints for the lines
        NSLayoutConstraint.activate([
            leftLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            leftLineView.trailingAnchor.constraint(equalTo: orLabel.leadingAnchor, constant: -16),
            leftLineView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            leftLineView.heightAnchor.constraint(equalToConstant: 1),
            
            rightLineView.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: 16),
            rightLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            rightLineView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Apple sign in button
        appleSignInButton.setTitle("Sign in with Apple", for: .normal)
        appleSignInButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        appleSignInButton.backgroundColor = .black
        appleSignInButton.setTitleColor(.white, for: .normal)
        appleSignInButton.layer.cornerRadius = 25
        
        // Add Apple logo
        if #available(iOS 13.0, *) {
            let appleImage = UIImage(systemName: "applelogo")
            appleSignInButton.setImage(appleImage, for: .normal)
            appleSignInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            appleSignInButton.tintColor = .white
        }
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(appleSignInButton)
        
        // Configure 'Don't have an account?' label
        accountLabel.text = "Don't have an account?"
        accountLabel.font = UIFont.systemFont(ofSize: 14)
        accountLabel.textColor = .systemGray
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(accountLabel)
        
        // Create 'Register Now' button styled in blue
        createAccountButton.setTitle("Register Now", for: .normal)
        createAccountButton.setTitleColor(.systemBlue, for: .normal) // Blue color
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        createAccountButton.backgroundColor = .clear // No background color
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createAccountButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Add a height constraint to the content view to ensure it's scrollable
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow
        contentViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // Title - positioned at the top left
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Email label
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            
            // Email field
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Password label
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24),
            
            // Password field
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Password visibility button
            passwordVisibilityButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -16),
            passwordVisibilityButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            passwordVisibilityButton.widthAnchor.constraint(equalToConstant: 28),
            passwordVisibilityButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Forgot password button
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            
            // Sign in button
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 32),
            signInButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Or label
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            orLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 32),
            
            // Apple sign in button
            appleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            appleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            appleSignInButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 32),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Create account button
            // Account label constraints
            accountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 80),
            accountLabel.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 40),
            accountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
            
            // Register Now button constraints - positioned immediately after label
            createAccountButton.leadingAnchor.constraint(equalTo: accountLabel.trailingAnchor, constant: 4),
            createAccountButton.centerYAnchor.constraint(equalTo: accountLabel.centerYAnchor)
        ])
    }
    
    private func setupDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupTapGesture() {
        // Create a tap gesture recognizer to dismiss keyboard when tapping anywhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // Don't cancel other touch events
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        // Dismiss the keyboard when tapping anywhere on the screen
        view.endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        // Add inset to bottom of scroll view that matches the keyboard height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // If a text field is active, make sure it's visible
        if let activeField = findFirstResponder() as? UITextField {
            // Calculate the rect of the active field in the scroll view's coordinate system
            let activeRect = activeField.convert(activeField.bounds, to: scrollView)
            
            // Create a rect that includes some additional space below the text field
            var visibleRect = activeRect
            visibleRect.size.height += 20
            
            // Scroll to make the active field visible
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset the scroll view insets when keyboard hides
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    private func findFirstResponder() -> UIView? {
        return findFirstResponder(in: view)
    }
    
    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        
        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) {
                return firstResponder
            }
        }
        
        return nil
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func forgotPasswordTapped() {
        // Present the forgot password screen as a modal
        let forgotPasswordVC = ForgotPasswordViewController()
        forgotPasswordVC.modalPresentationStyle = .pageSheet
        
        // Configure sheet presentation controller for iOS 15+
        if #available(iOS 15.0, *) {
            if let sheet = forgotPasswordVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        // Present the forgot password view controller modally
        present(forgotPasswordVC, animated: true, completion: nil)
    }
    
    // Method to handle smooth transitions when dismissing
    func dismissWithAnimation(direction: CATransitionSubtype = .fromLeft) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = direction
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }
    
    // MARK: - Actions
    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Sign In Failed", message: "Please enter your email and password.")
            return
        }
        
        // Show loading indicator and disable button
        signInLoadingIndicator.startAnimating()
        signInButton.setTitle("Signing In", for: .normal)
        signInButton.isEnabled = false
        
        Task {
            do {
                let session = try await supabase.auth.signIn(email: email, password: password)
                await MainActor.run {
                    // Hide loading indicator
                    signInLoadingIndicator.stopAnimating()
                    signInButton.setTitle("Sign In", for: .normal)
                    signInButton.isEnabled = true
                    navigateToHome()
                }
            } catch {
                await MainActor.run {
                    // Hide loading indicator and re-enable button on error
                    signInLoadingIndicator.stopAnimating()
                    signInButton.setTitle("Sign In", for: .normal)
                    signInButton.isEnabled = true
                    showAlert(title: "Sign In Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func appleSignInTapped() {
        // Handle Apple Sign In (would need to implement Sign in with Apple)
        showAlert(title: "Coming Soon", message: "Sign in with Apple will be available in a future update.")
    }
    
    @objc private func createAccountTapped() {
        // Present signup screen as modal
        let signupVC = SignupContainerViewController()
        signupVC.modalPresentationStyle = .pageSheet
        
        // Configure sheet presentation controller for iOS 15+
        if #available(iOS 15.0, *) {
            if let sheet = signupVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        // Present the signup view controller modally
        present(signupVC, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    private func resetPassword(email: String) {
        Task {
            do {
                try await supabase.auth.resetPasswordForEmail(email)
                await MainActor.run {
                    showAlert(title: "Password Reset Email Sent", message: "Please check your email for instructions to reset your password.")
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Password Reset Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            
            // Apply a smooth fade-in transition animation
            let transition = CATransition()
            transition.duration = 0.6
            transition.type = CATransitionType.fade
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            view.window?.layer.add(transition, forKey: kCATransition)
            
            present(tabBarController, animated: false, completion: nil)
        }
    }
}

// MARK: - UITextFieldDelegate
extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            signInTapped()
        }
        return true
    }
    
    // No special handling needed for text field focus events
}

// MARK: - UIScrollViewDelegate
extension AuthViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        // When user scrolls past the title, show it in the navigation bar
        if offset > 100 {
            // Title is scrolled out of view, show in navigation bar
            self.title = "Sign In"
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
                self.navigationController?.navigationBar.shadowImage = nil // Show shadow
            }
        } else {
            // Title is visible, hide from navigation bar
            self.title = ""
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.backgroundColor = UIColor.clear
                self.navigationController?.navigationBar.shadowImage = UIImage() // Hide shadow
            }
        }
    }
}
