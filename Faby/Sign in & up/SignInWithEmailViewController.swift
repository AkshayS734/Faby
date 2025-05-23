import UIKit
import Supabase

class SignInWithEmailViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        emailText.delegate = self
        passwordText.delegate = self
        
    }
    deinit {
           NotificationCenter.default.removeObserver(self)
       }
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    @IBAction func signInPressed(_ sender: UIButton) {
        guard let email = emailText.text, !email.isEmpty,
            let password = passwordText.text, !password.isEmpty else {
            showAlert(title: "Sign in failed", message: "Please enter email and password")
                return
            }
                
            Task {
                do {
                    let session = try await supabase.auth.signIn(email: email, password: password)
                    navigateToHome()
                } catch {
                    showAlert(title: "Login failed", message: "\(error.localizedDescription)")
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

}
