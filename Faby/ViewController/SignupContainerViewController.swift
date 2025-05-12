import UIKit

class SignupContainerViewController: UIViewController {
    // Flag to skip directly to baby signup if OTP was already verified
    var skipToOTPVerified: Bool = false
    // Container to hold both screens
    private let containerView = UIView()
    
    // First screen view controller
    private var signupVC: ModernSignupViewController!
    
    // OTP verification view controller (created when needed)
    private var otpVC: OTPVerificationViewController?
    
    // Reference to baby signup VC (created when needed)
    private var babySignupVC: ModernBabySignupViewController?
    
    // User info to pass between screens
    private var userInfo: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupContainer()
        
        // Check if we should skip to OTP verified state
        if skipToOTPVerified, let email = UserSessionManager.shared.userEmail, 
           let password = UserSessionManager.shared.userPassword,
           let userInfo = UserSessionManager.shared.userInfo {
            // Restore session data and skip to baby signup
            self.userInfo = userInfo
            showBabySignupScreen(with: email, password: password, userInfo: userInfo)
        } else {
            // Normal flow - start with signup screen
            setupSignupScreen()
        }
        
        setupSwipeGestures()
    }
    
    private func setupSwipeGestures() {
        // Add left swipe gesture (to go to baby details)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        // Add right swipe gesture (to go back to user details)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipeLeft() {
        // Only proceed if we're on the first screen
        if otpVC == nil && babySignupVC == nil {
            // Get user info from delegate method
            signupVC.delegate?.didFinishUserSignup(with: [:])
            
            // Provide haptic feedback
            if #available(iOS 10.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }
    
    @objc private func handleSwipeRight() {
        // Go back to previous screen based on current state
        if babySignupVC != nil {
            // If on baby signup, go back to OTP verification
            goBackToOTPScreen()
        } else if otpVC != nil {
            // If on OTP verification, go back to signup
            goBackToSignupScreen()
        }
    }
    
    // Handle back navigation from baby signup
    @objc func handleBackFromBabySignup() {
        goBackToOTPScreen()
    }
    
    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSignupScreen() {
        // Create signup view controller
        signupVC = ModernSignupViewController()
        signupVC.delegate = self
        
        // Embed in navigation controller
        let navController = UINavigationController(rootViewController: signupVC)
        
        // Add to container
        addChild(navController)
        containerView.addSubview(navController.view)
        navController.view.frame = containerView.bounds
        navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        navController.didMove(toParent: self)
    }
    
    // Show OTP verification screen
    private func showOTPVerificationScreen(with userInfo: [String: String]) {
        // Store user info for passing to baby signup
        self.userInfo = userInfo
        
        // Remove current view controller
        if let currentViewController = children.first {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Create and add OTP verification screen
        otpVC = OTPVerificationViewController()
        if let otpVC = otpVC {
            // Set delegate to handle navigation
            otpVC.delegate = self
            otpVC.userEmail = userInfo["email"] ?? ""
            otpVC.userPassword = userInfo["password"] ?? ""
            otpVC.userInfo = userInfo
            
            // Embed in navigation controller
            let navController = UINavigationController(rootViewController: otpVC)
            
            // Add to container
            addChild(navController)
            containerView.addSubview(navController.view)
            navController.view.frame = containerView.bounds
            navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            navController.didMove(toParent: self)
        }
    }
    
    // Show baby signup screen after OTP verification
    private func showBabySignupScreen(with email: String, password: String, userInfo: [String: String]) {
        // Store user info for passing to baby signup
        self.userInfo = userInfo
        
        // Remove current view controller
        if let currentViewController = children.first {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Create and add baby signup screen
        babySignupVC = ModernBabySignupViewController()
        if let babyVC = babySignupVC {
            // Set delegate to handle back navigation
            babyVC.delegate = self
            babyVC.userEmail = email
            babyVC.userName = userInfo["name"]
            babyVC.userRelationship = userInfo["relationship"]
            babyVC.userPassword = password
            
            // Embed in navigation controller
            let navController = UINavigationController(rootViewController: babyVC)
            
            // Add to container
            addChild(navController)
            containerView.addSubview(navController.view)
            navController.view.frame = containerView.bounds
            navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            navController.didMove(toParent: self)
        }
    }
    
    private func goBackToOTPScreen() {
        // Remove current navigation controller
        if let currentViewController = children.first {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Create OTP verification screen again
        otpVC = OTPVerificationViewController()
        if let otpVC = otpVC {
            // Set delegate to handle navigation
            otpVC.delegate = self
            otpVC.userEmail = userInfo["email"] ?? ""
            otpVC.userPassword = userInfo["password"] ?? ""
            otpVC.userInfo = userInfo
            
            // Embed in navigation controller
            let navController = UINavigationController(rootViewController: otpVC)
            
            // Add to container
            addChild(navController)
            containerView.addSubview(navController.view)
            navController.view.frame = containerView.bounds
            navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            navController.didMove(toParent: self)
        }
        
        // Clear reference
        babySignupVC = nil
    }
    
    private func goBackToSignupScreen() {
        // Remove current navigation controller
        if let currentViewController = children.first {
            currentViewController.willMove(toParent: nil)
            currentViewController.view.removeFromSuperview()
            currentViewController.removeFromParent()
        }
        
        // Create signup view controller again
        signupVC = ModernSignupViewController()
        signupVC.delegate = self
        
        // Embed in navigation controller
        let navController = UINavigationController(rootViewController: signupVC)
        
        // Add to container
        addChild(navController)
        containerView.addSubview(navController.view)
        navController.view.frame = containerView.bounds
        navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        navController.didMove(toParent: self)
        
        // Clear references
        otpVC = nil
        babySignupVC = nil
    }
    
    private func addObserversForBabyVC(_ babyVC: ModernBabySignupViewController) {
        // We don't need to manually add observers anymore since we're using the delegate pattern
        // This method is kept for backward compatibility but is now empty
        
        // Add a target to the complete button
        if let completeButton = babyVC.view.subviews.first(where: { $0 is UIButton && ($0 as? UIButton)?.titleLabel?.text == "Complete Signup" }) as? UIButton {
            // We'll use method swizzling to observe when the navigation happens
            NotificationCenter.default.addObserver(self, selector: #selector(handleSignupCompletion), name: Notification.Name("SignupCompleted"), object: nil)
        }
    }
    
    // This method is deprecated and kept for backward compatibility
    // Use the delegate methods instead
    @objc private func backButtonPressed() {
        goBackToOTPScreen()
    }
    
    @objc private func handleSignupCompletion() {
        // Navigate to main app
        navigateToMainApp()
    }
    
    private func navigateToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            mainTabBarController.modalPresentationStyle = .fullScreen
            
            // Present from the root view controller to replace the entire navigation stack
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = mainTabBarController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            } else {
                // Fallback if window scene isn't available
                self.view.window?.rootViewController = mainTabBarController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - ModernSignupViewControllerDelegate
extension SignupContainerViewController: ModernSignupViewControllerDelegate {
    func didFinishUserSignup(with userInfo: [String: String]) {
        showOTPVerificationScreen(with: userInfo)
    }
}

// MARK: - ModernBabySignupViewControllerDelegate
extension SignupContainerViewController: ModernBabySignupViewControllerDelegate {
    func didTapBackButton() {
        // Navigate back to the OTP verification screen
        goBackToOTPScreen()
    }
    
    func didCompleteBabySignup() {
        // Navigate to the main app
        navigateToMainApp()
    }
}

// MARK: - OTPVerificationViewControllerDelegate
extension SignupContainerViewController: OTPVerificationViewControllerDelegate {
    func didVerifyOTP(email: String, password: String, userInfo: [String: String]) {
        showBabySignupScreen(with: email, password: password, userInfo: userInfo)
    }
    
    func didTapBackFromOTP() {
        goBackToSignupScreen()
    }
}


