import UIKit

class BabyEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let changePhotoButton = UIButton(type: .system)
    
    private let nameLabel = UILabel()
    private let nameTextField = UITextField()
    
    private let dobLabel = UILabel()
    private let dobTextField = UITextField()
    private let dobPicker = UIDatePicker()
    
    private let genderLabel = UILabel()
    private let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Other"])
    
    private let saveButton = UIButton(type: .system)
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // Data
    private var baby: Baby?
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBabyData()
    }
    
    private func setupUI() {
        title = "Edit Baby Profile"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup profile image view
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 60
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(named: "profile_picture")
        contentView.addSubview(profileImageView)
        
        // Setup change photo button
        changePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        changePhotoButton.setTitle("Change Photo", for: .normal)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        contentView.addSubview(changePhotoButton)
        
        // Setup name field
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(nameLabel)
        
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.borderStyle = .roundedRect
        nameTextField.placeholder = "Enter baby's name"
        contentView.addSubview(nameTextField)
        
        // Setup date of birth field
        dobLabel.translatesAutoresizingMaskIntoConstraints = false
        dobLabel.text = "Date of Birth"
        dobLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(dobLabel)
        
        dobTextField.translatesAutoresizingMaskIntoConstraints = false
        dobTextField.borderStyle = .roundedRect
        dobTextField.placeholder = "Select date of birth"
        dobTextField.inputView = dobPicker
        contentView.addSubview(dobTextField)
        
        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        dobPicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        // Setup gender field
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(genderLabel)
        
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        genderSegmentedControl.selectedSegmentIndex = 0
        contentView.addSubview(genderSegmentedControl)
        
        // Setup save button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemBlue
        view.addSubview(loadingIndicator)
        
        setupConstraints()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Profile image view constraints
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Change photo button constraints
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Name text field constraints
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Date of birth label constraints
            dobLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            dobLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dobLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Date of birth text field constraints
            dobTextField.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: 8),
            dobTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dobTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Gender label constraints
            genderLabel.topAnchor.constraint(equalTo: dobTextField.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Gender segmented control constraints
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Save button constraints
            saveButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadBabyData() {
        loadingIndicator.startAnimating()
        
        // Get baby data from DataController
        if let baby = DataController.shared.baby {
            self.baby = baby
            updateUI()
            loadBabyImage()
        } else {
            // If no baby data is available, try to fetch it
            Task {
                await DataController.shared.loadBabyData()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let baby = DataController.shared.baby {
                        self.baby = baby
                        self.updateUI()
                        self.loadBabyImage()
                    } else {
                        self.showErrorAlert(message: "Failed to load baby data. Please try again later.")
                    }
                    
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func updateUI() {
        guard let baby = baby else { return }
        
        nameTextField.text = baby.name
        
        // Format date of birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: baby.dateOfBirth) {
            dobPicker.date = date
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy"
            dobTextField.text = displayFormatter.string(from: date)
        }
        
        // Set gender
        switch baby.gender {
        case .male:
            genderSegmentedControl.selectedSegmentIndex = 0
        case .female:
            genderSegmentedControl.selectedSegmentIndex = 1
        case .other:
            genderSegmentedControl.selectedSegmentIndex = 2
        }
        
        loadingIndicator.stopAnimating()
    }
    
    private func loadBabyImage() {
        guard let baby = baby, let imageURL = baby.imageURL, !imageURL.isEmpty else {
            return
        }
        
        // Load baby image from URL
        guard let url = URL(string: imageURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error loading baby image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode baby image data")
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    @objc private func changePhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Select Photo Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        dobTextField.text = formatter.string(from: dobPicker.date)
    }
    
    @objc private func saveButtonTapped() {
        guard let baby = baby else { return }
        
        // Validate inputs
        guard let name = nameTextField.text, !name.isEmpty else {
            showErrorAlert(message: "Please enter a name for your baby.")
            return
        }
        
        guard let dobText = dobTextField.text, !dobText.isEmpty else {
            showErrorAlert(message: "Please select a date of birth.")
            return
        }
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        // Update baby data
        baby.name = name
        
        // Format date of birth for database
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        baby.dateOfBirth = dateFormatter.string(from: dobPicker.date)
        
        // Update gender
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            baby.gender = .male
        case 1:
            baby.gender = .female
        default:
            baby.gender = .other
        }
        
        // Save changes to database
        Task {
            do {
                try await updateBabyInDatabase(baby: baby)
                
                // Upload image if selected
                if let selectedImage = selectedImage {
                    try await uploadBabyImage(image: selectedImage, for: baby)
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to save changes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateBabyInDatabase(baby: Baby) async throws {
        let client = AuthManager.shared.getClient()
        
        // Create a struct that conforms to Encodable for the update operation
        struct BabyUpdate: Encodable {
            let name: String
            let dob: String
            let gender: String
        }
        
        // Create an encodable object with the updated values
        let updateData = BabyUpdate(
            name: baby.name,
            dob: baby.dateOfBirth,
            gender: baby.gender.rawValue
        )
        
        // Update baby in database
        _ = try await client.database
            .from("baby")
            .update(updateData)
            .eq("uid", value: baby.babyID.uuidString)
            .execute()
    }
    
    private func uploadBabyImage(image: UIImage, for baby: Baby) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "BabyEditViewController", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let client = AuthManager.shared.getClient()
        let fileName = "baby_image_\(baby.babyID.uuidString).jpeg"
        
        // Upload image to Supabase storage
        _ = try await client.storage
            .from("babyimage")
            .upload(fileName, data: imageData)
        
        // Create a signed URL for the uploaded image
        let signedURL = try await client.storage
            .from("babyimage")
            .createSignedURL(path: fileName, expiresIn: 31536000) // 1 year expiration
        
        // Create a struct that conforms to Encodable for the update operation
        struct ImageUpdate: Encodable {
            let image_url: String
        }
        
        // Update baby record with new image URL
        _ = try await client.database
            .from("baby")
            .update(ImageUpdate(image_url: signedURL.absoluteString))
            .eq("uid", value: baby.babyID.uuidString)
            .execute()
        
        // Update local baby object
        baby.imageURL = signedURL.absoluteString
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Baby profile updated successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            selectedImage = originalImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
