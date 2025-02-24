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
    
    var pages = [UIViewController]()
    var progressBar: UIProgressView!
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
        
//        setupProgressBar()
    }
    
//    func setupProgressBar() {
//        progressBar = UIProgressView(progressViewStyle: .default)
//        progressBar.progress = 0.5
//        progressBar.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(progressBar)
//        
//        NSLayoutConstraint.activate([
//            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            progressBar.heightAnchor.constraint(equalToConstant: 4)
//        ])
//    }
//    
//    func updateProgressBar(progress: Float) {
//        UIView.animate(withDuration: 0.3) {
//            self.progressBar.progress = progress
//        }
//    }
    func submitDataToSupabase() {
        guard let email = userEmail, let password = userPassword,
              let name = userName, let relationship = userRelationship,
              let babyName = babyName, let babyAge = babyAge, let babyGender = babyGender else {
            showAlert("Missing required fields.")
            return
        }

        Task {
            do {
                let _ = try await supabase.auth.signUp(email: email, password: password)
                
                var babyData: [String: String] = [
                    "name": babyName,
                    "age": babyAge,
                    "gender": babyGender
                ]
                
                if let image = babyImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fileName = "baby_images/\(UUID().uuidString).jpg"
                    
                    let _ = try await supabase.storage.from("baby_images").upload(fileName, data: imageData)
                    
                    let imageUrl = "https://hlkmrimpxzsnxzrgofes.supabase.co/storage/v1/object/public/baby_images/\(fileName)"
                    babyData["image_url"] = imageUrl
                }

                try await supabase.from("babies").insert([babyData]).execute()
                
                try await supabase.from("users").insert([
                    ["email": email, "name": name, "relationship": relationship]
                ]).execute()

                showAlert("Signup successful!")
            } catch {
                showAlert("Signup failed: \(error.localizedDescription)")
            }
        }
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
//            return nil
//        }
//        return pages[currentIndex - 1]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
//            return nil
//        }
//        return pages[currentIndex + 1]
//    }
//}
