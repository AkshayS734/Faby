import UIKit
import Supabase
class SignUpViewController: UIPageViewController, UIPageViewControllerDelegate {
    var babyName: String?
    var babyAge: String?
    var babyGender: String?
    var babyImage: UIImage?
    
    var userEmail: String?
    var userName: String?
    var userRelationship: String?
    var userPassword: String?
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    var pages = [UIViewController]()
    let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = nil
        self.delegate = self
        
        let babyDetailsVC = storyboard?.instantiateViewController(withIdentifier: "BabyDetailsViewController") as! BabyDetailsViewController
        let userDetailsVC = storyboard?.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        
        pages.append(babyDetailsVC)
        pages.append(userDetailsVC)
        
        setViewControllers([babyDetailsVC], direction: .forward, animated: true, completion: nil)
        setupActivityIndicator()
        
    }
    func submitDataToSupabase() {
        guard let email = userEmail, let password = userPassword,
              let name = userName, let relationship = userRelationship,
              let babyName = babyName, let babyDOB = babyAge, let babyGender = babyGender else {
            showAlert("Missing required fields.")
            return
        }
        showLoading(true)
        Task {
            do {
                let authResponse = try await supabase.auth.signUp(email: email, password: password)
                let userID = authResponse.user.id.uuidString
                
                let baby = Baby(babyId: UUID(), name: babyName, dateOfBirth: babyDOB, gender: Gender(rawValue: babyGender.lowercased()) ?? .other)
                
                if let image = babyImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = "\(UUID().uuidString).jpg"
                    
                    let _ = try await supabase.storage.from("profile-images").upload(fileName, data: imageData)
                    
                    let imageUrl = "https://faby.supabase.co/storage/v1/object/public/profile-images/\(fileName)"
                    baby.imageURL = imageUrl
                }
                
                try await supabase.from("baby").insert([baby]).execute()
                
                _ = baby.babyID.uuidString
                try await supabase.from("parents").insert([
                    [
                        "uid": userID,
                        "email": email,
                        "name": name,
                        "relationship": relationship,
                        "baby_uid": baby.babyID.uuidString
                    ]
                ]).execute()
                
                DispatchQueue.main.async {
                    self.showLoading(false)
                    self.navigateToHome()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.showLoading(false)
                    self.showAlert("Signup failed: \(error.localizedDescription)")
                }
                print("\(error.localizedDescription)")
            }
        }
    }
    func navigateToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            homeVC.modalPresentationStyle = .fullScreen
            present(homeVC, animated: true, completion: nil)
        }
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
