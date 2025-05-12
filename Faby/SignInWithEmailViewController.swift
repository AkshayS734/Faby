import UIKit
import Supabase

class SignInWithEmailViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        emailText.delegate = self
        passwordText.delegate = self
        setupActivityIndicator()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    let authManager = AuthManager.shared
    
    @IBAction func signInPressed(_ sender: UIButton) {
        guard let email = emailText.text, !email.isEmpty,
              let password = passwordText.text, !password.isEmpty else {
            showAlert(title: "Sign in failed", message: "Please enter email and password")
            return
        }
        
        showLoading(true)
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                await DataController.shared.loadBabyData()
                
                DispatchQueue.main.async {
                    self.showLoading(false)
                    self.navigateToHome()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showLoading(false)
                    self.showAlert(title: "Login failed", message: "\(error.localizedDescription)")
                }
            }
        }
    }
    
    func navigateToHome() {
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
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "forgotPassword", sender: nil)
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            self.view.frame.origin.y = -keyboardHeight / 2
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func setupActivityIndicator() {
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0
        view.addSubview(blurEffectView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor)
        ])
    }
    func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.blurEffectView.alpha = 0.5
                self.activityIndicator.startAnimating()
                self.view.isUserInteractionEnabled = false
            } else {
                self.activityIndicator.stopAnimating()
                self.blurEffectView.alpha = 0
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
}
