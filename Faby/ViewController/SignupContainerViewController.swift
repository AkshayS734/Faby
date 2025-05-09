import UIKit

// Protocol for handling back navigation
protocol BabySignupViewControllerDelegate: AnyObject {
    func didTapBackButton()
}

class SignupContainerViewController: UIViewController, BabySignupViewControllerDelegate {
    // Container to hold both screens
    private let containerView = UIView()
    
    // First screen view controller
    private var signupVC: ModernSignupViewController!
    
    // Reference to baby signup VC (created when needed)
    private var babySignupVC: ModernBabySignupViewController?
    
    // User info to pass between screens
    private var userInfo: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupContainer()
        setupSignupScreen()
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
        if babySignupVC == nil {
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
        // Only respond if we're on the baby signup screen
        if babySignupVC != nil {
            goBackToSignupScreen()
        }
    }
    
    // MARK: - BabySignupViewControllerDelegate
    func didTapBackButton() {
        // Navigate back to the signup screen
        goBackToSignupScreen()
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
    
    private func showBabySignupScreen(with userInfo: [String: String]) {
        // Store user info for passing to baby signup
        self.userInfo = userInfo
        
        // Remove current view controller (the navigation controller containing signup)
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
            babyVC.userEmail = userInfo["email"]
            babyVC.userName = userInfo["name"]
            babyVC.userRelationship = userInfo["relationship"]
            babyVC.userPassword = userInfo["password"]
            
            // Embed in navigation controller
            let navController = UINavigationController(rootViewController: babyVC)
            
            // Add to container
            addChild(navController)
            containerView.addSubview(navController.view)
            navController.view.frame = containerView.bounds
            navController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            navController.didMove(toParent: self)
        }
        // No need for manual animation - navigation controller handles transitions
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
        
        // Clear reference
        babySignupVC = nil
    }
    
    private func addObserversForBabyVC(_ babyVC: ModernBabySignupViewController) {
        // Add a target to the back button
        if let backButton = babyVC.view.subviews.first(where: { $0 is UIButton && ($0 as? UIButton)?.image(for: .normal) != nil }) as? UIButton {
            backButton.removeTarget(nil, action: nil, for: .allEvents)
            backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        }
        
        // Add a target to the complete button
        if let completeButton = babyVC.view.subviews.first(where: { $0 is UIButton && ($0 as? UIButton)?.titleLabel?.text == "Complete Signup" }) as? UIButton {
            // We'll use method swizzling to observe when the navigation happens
            NotificationCenter.default.addObserver(self, selector: #selector(handleSignupCompletion), name: Notification.Name("SignupCompleted"), object: nil)
        }
    }
    
    @objc private func backButtonPressed() {
        goBackToSignupScreen()
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
        showBabySignupScreen(with: userInfo)
    }
}


