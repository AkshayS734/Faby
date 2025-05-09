import UIKit
import Supabase

class ModernBabyDetailsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressBar = UIProgressView()
    
    private let babyNameLabel = UILabel()
    private let babyNameTextField = UITextField()
    
    private let babyAgeLabel = UILabel()
    private let ageButtonsStackView = UIStackView()
    private var ageButtons: [UIButton] = []
    
    private let babyGenderLabel = UILabel()
    private let genderButtonsStackView = UIStackView()
    private var genderButtons: [UIButton] = []
    
    private let createAccountButton = UIButton(type: .system)
    private let termsLabel = UILabel()
    
    // MARK: - Properties
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
    )
    
    // Data from previous screen
    private var userEmail: String?
    private var userName: String?
    private var userRelationship: String?
    private var userPassword: String?
    
    // Selected values
    private var selectedAge: String?
    private var selectedGender: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUserData()
        setupUI()
    }
    
    private func retrieveUserData() {
        userEmail = UserDefaults.standard.string(forKey: "tempUserEmail")
        userName = UserDefaults.standard.string(forKey: "tempUserName")
        userRelationship = UserDefaults.standard.string(forKey: "tempUserRelationship")
        userPassword = UserDefaults.standard.string(forKey: "tempUserPassword")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // ScrollView for content
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content view inside scrollView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .systemBlue
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backButton)
        
        // Title
        titleLabel.text = "Baby Details"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Tell us about your little one"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        // Progress bar
        progressBar.progress = 0.75
        progressBar.trackTintColor = .systemGray5
        progressBar.progressTintColor = .systemBlue
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressBar)
        
        // Baby's Name Label
        babyNameLabel.text = "Baby's Name"
        babyNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        babyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyNameLabel)
        
        // Baby's Name TextField
        babyNameTextField.placeholder = "Enter baby's name"
        babyNameTextField.borderStyle = .none
        babyNameTextField.backgroundColor = .systemGray6
        babyNameTextField.layer.cornerRadius = 10
        babyNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: babyNameTextField.frame.height))
        babyNameTextField.leftViewMode = .always
        babyNameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyNameTextField)
        
        // Baby's Age Label
        babyAgeLabel.text = "Baby's Age"
        babyAgeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        babyAgeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyAgeLabel)
        
        // Age Buttons Stack View
        setupAgeButtons()
        
        // Baby's Gender Label
        babyGenderLabel.text = "Baby's Gender"
        babyGenderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        babyGenderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(babyGenderLabel)
        
        // Gender Buttons Stack View
        setupGenderButtons()
        
        // Create Account Button
        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.backgroundColor = .systemBlue
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        createAccountButton.layer.cornerRadius = 25
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createAccountButton)
        
        // Terms Label
        let attributedString = NSMutableAttributedString(string: "By creating an account, you agree to our Terms of Service and Privacy Policy")
        let termsRange = (attributedString.string as NSString).range(of: "Terms of Service")
        let policyRange = (attributedString.string as NSString).range(of: "Privacy Policy")
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: termsRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: policyRange)
        
        termsLabel.attributedText = attributedString
        termsLabel.font = UIFont.systemFont(ofSize: 12)
        termsLabel.textColor = .secondaryLabel
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(termsLabel)
        
        setupConstraints()
    }
    
    private func setupAgeButtons() {
        // Age Buttons Stack View - Two rows
        let ageButtonsTopRow = UIStackView()
        ageButtonsTopRow.axis = .horizontal
        ageButtonsTopRow.distribution = .fillEqually
        ageButtonsTopRow.spacing = 8
        ageButtonsTopRow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageButtonsTopRow)
        
        let ageButtonsBottomRow = UIStackView()
        ageButtonsBottomRow.axis = .horizontal
        ageButtonsBottomRow.distribution = .fillEqually
        ageButtonsBottomRow.spacing = 8
        ageButtonsBottomRow.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageButtonsBottomRow)
        
        // Age options
        let ageOptions = ["Expecting", "0-6 months", "6-12 months", "1-2 years", "2+ years"]
        
        // Create buttons for top row (2 buttons)
        for i in 0..<2 {
            let button = createSelectionButton(title: ageOptions[i], isSelected: i == 0)
            button.tag = i
            button.addTarget(self, action: #selector(ageButtonTapped(_:)), for: .touchUpInside)
            ageButtonsTopRow.addArrangedSubview(button)
            ageButtons.append(button)
        }
        
        // Create buttons for bottom row (3 buttons)
        for i in 2..<5 {
            let button = createSelectionButton(title: ageOptions[i], isSelected: false)
            button.tag = i
            button.addTarget(self, action: #selector(ageButtonTapped(_:)), for: .touchUpInside)
            ageButtonsBottomRow.addArrangedSubview(button)
            ageButtons.append(button)
        }
        
        // Set initial selection
        selectedAge = ageOptions[0]
        
        // Store stack views for constraints
        ageButtonsStackView.axis = .vertical
        ageButtonsStackView.spacing = 8
        ageButtonsStackView.addArrangedSubview(ageButtonsTopRow)
        ageButtonsStackView.addArrangedSubview(ageButtonsBottomRow)
        ageButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageButtonsStackView)
    }
    
    private func setupGenderButtons() {
        genderButtonsStackView.axis = .horizontal
        genderButtonsStackView.distribution = .fillEqually
        genderButtonsStackView.spacing = 8
        genderButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderButtonsStackView)
        
        // Gender options
        let genderOptions = ["Boy", "Girl", "Prefer not to say"]
        
        // Create gender buttons
        for (index, option) in genderOptions.enumerated() {
            let button = createSelectionButton(title: option, isSelected: index == 0)
            button.tag = index
            button.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
            genderButtonsStackView.addArrangedSubview(button)
            genderButtons.append(button)
        }
        
        // Set initial selection
        selectedGender = genderOptions[0]
    }
    
    private func createSelectionButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        
        if isSelected {
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.label, for: .normal)
        }
        
        return button
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Back Button
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Progress Bar
            progressBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            progressBar.heightAnchor.constraint(equalToConstant: 3),
            
            // Baby's Name Label
            babyNameLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 24),
            babyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            babyNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Baby's Name TextField
            babyNameTextField.topAnchor.constraint(equalTo: babyNameLabel.bottomAnchor, constant: 8),
            babyNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            babyNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            babyNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Baby's Age Label
            babyAgeLabel.topAnchor.constraint(equalTo: babyNameTextField.bottomAnchor, constant: 16),
            babyAgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            babyAgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Age Buttons Stack View
            ageButtonsStackView.topAnchor.constraint(equalTo: babyAgeLabel.bottomAnchor, constant: 8),
            ageButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            ageButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Baby's Gender Label
            babyGenderLabel.topAnchor.constraint(equalTo: ageButtonsStackView.bottomAnchor, constant: 16),
            babyGenderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            babyGenderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Gender Buttons Stack View
            genderButtonsStackView.topAnchor.constraint(equalTo: babyGenderLabel.bottomAnchor, constant: 8),
            genderButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            genderButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            genderButtonsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Create Account Button
            createAccountButton.topAnchor.constraint(equalTo: genderButtonsStackView.bottomAnchor, constant: 32),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Terms Label
            termsLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 16),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - Action Methods
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func ageButtonTapped(_ sender: UIButton) {
        // Reset all age buttons
        for button in ageButtons {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.label, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        // Set selected button
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Save selected age
        selectedAge = sender.title(for: .normal)
    }
    
    @objc private func genderButtonTapped(_ sender: UIButton) {
        // Reset all gender buttons
        for button in genderButtons {
            button.backgroundColor = .systemGray6
            button.setTitleColor(.label, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.cgColor
        }
        
        // Set selected button
        sender.backgroundColor = .systemBlue
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Save selected gender
        selectedGender = sender.title(for: .normal)
    }
    
    @objc private func createAccountTapped() {
        guard let babyName = babyNameTextField.text, !babyName.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter your baby's name")
            return
        }
        
        guard let age = selectedAge else {
            showAlert(title: "Missing Information", message: "Please select your baby's age")
            return
        }
        
        guard let gender = selectedGender else {
            showAlert(title: "Missing Information", message: "Please select your baby's gender")
            return
        }
        
        // Create account in Supabase
        createAccount(babyName: babyName, babyAge: age, babyGender: gender)
    }
    
    // MARK: - Helper Methods
    private func createAccount(babyName: String, babyAge: String, babyGender: String) {
        guard let email = userEmail, let password = userPassword, let name = userName, let relationship = userRelationship else {
            showAlert(title: "Error", message: "Missing user information")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        Task {
            do {
                // 1. Create user in Supabase Auth
                let authResponse = try await supabase.auth.signUp(email: email, password: password)
                let userId = authResponse.user.id.uuidString
                
                // 2. Create baby record
                let babyId = UUID().uuidString
                try await supabase.from("baby").insert([
                    "uid": babyId,
                    "name": babyName,
                    "dob": babyAge,
                    "gender": babyGender,
                    "user_id": userId
                ]).execute()
                
                // 3. Create parent record
                try await supabase.from("parents").insert([
                    "email": email,
                    "name": name,
                    "relationship": relationship,
                    "baby_uid": babyId
                ]).execute()
                
                // Success - navigate to main app
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    navigateToMainApp()
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    showAlert(title: "Error", message: "Failed to create account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToMainApp() {
        // Clear temporary user data
        UserDefaults.standard.removeObject(forKey: "tempUserEmail")
        UserDefaults.standard.removeObject(forKey: "tempUserName")
        UserDefaults.standard.removeObject(forKey: "tempUserRelationship")
        UserDefaults.standard.removeObject(forKey: "tempUserPassword")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen
            present(tabBarController, animated: true)
        }
    }
}
