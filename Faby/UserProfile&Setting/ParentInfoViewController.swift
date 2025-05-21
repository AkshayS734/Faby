import UIKit

class ParentInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let genderLabel = UILabel()
    private let relationLabel = UILabel()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // Data
    private var parentData: Parent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEditButton()
        loadParentData()
    }
    
    private func setupUI() {
        title = "Parent Information"
        view.backgroundColor = .systemBackground
        
        // Add tap gesture to profile image for editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
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
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray2
        contentView.addSubview(profileImageView)
        
        // Setup labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(emailLabel)
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(phoneLabel)
        
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(genderLabel)
        
        relationLabel.translatesAutoresizingMaskIntoConstraints = false
        relationLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(relationLabel)
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemBlue
        view.addSubview(loadingIndicator)
        
        setupConstraints()
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
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Email label constraints
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Phone label constraints
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 15),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Gender label constraints
            genderLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 15),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Relation label constraints
            relationLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 15),
            relationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            relationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            relationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadParentData() {
        loadingIndicator.startAnimating()
        
        // First check if we have the current parent data in ParentDataModel
        if let currentParent = ParentDataModel.shared.currentParent {
            self.parentData = currentParent
            updateUI()
            loadProfileImage()
            loadingIndicator.stopAnimating()
            return
        }
        
        // If not, we need to fetch it from Supabase
        Task {
            if let userId = await AuthManager.shared.getCurrentUserID() {
                ParentDataModel.shared.updateCurrentParent(userId: userId) { [weak self] success in
                    guard let self = self else { return }
                    
                    if success, let currentParent = ParentDataModel.shared.currentParent {
                        self.parentData = currentParent
                        self.updateUI()
                        self.loadProfileImage()
                    } else {
                        self.showErrorAlert(message: "Failed to load parent data. Please try again later.")
                    }
                    
                    self.loadingIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "You need to be logged in to view parent information.")
                }
            }
        }
    }
    
    private func updateUI() {
        guard let parentData = parentData else { return }
        
        nameLabel.text = parentData.name
        emailLabel.text = "Email: \(parentData.email)"
        
        if let phoneNumber = parentData.phoneNumber, !phoneNumber.isEmpty {
            phoneLabel.text = "Phone: \(phoneNumber)"
            phoneLabel.isHidden = false
        } else {
            phoneLabel.isHidden = true
        }
        
        genderLabel.text = "Gender: \(parentData.gender.rawValue.capitalized)"
        relationLabel.text = "Relation: \(parentData.relation.rawValue.capitalized)"
    }
    
    private func loadProfileImage() {
        guard let parentData = parentData else {
            print("❌ ParentInfoViewController: No parent data available")
            return
        }
        
        guard let imageUrlString = parentData.parentimage_url, !imageUrlString.isEmpty else {
            print("❌ ParentInfoViewController: No profile image URL available")
            // Set default image
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        print("📷 ParentInfoViewController: Attempting to load image directly from URL: \(imageUrlString)")
        
        // Since we're having issues with the Supabase storage API, let's try to load the image directly from the URL
        // The URL in the database appears to be a pre-signed URL that should work directly
        guard let url = URL(string: imageUrlString) else {
            print("❌ ParentInfoViewController: Invalid image URL")
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = profileImageView.center
        activityIndicator.startAnimating()
        profileImageView.addSubview(activityIndicator)
        
        // Try to load the image directly from the URL
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                
                if let error = error {
                    print("❌ Error loading image directly: \(error.localizedDescription)")
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 HTTP response status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("❌ Bad HTTP response: \(httpResponse.statusCode)")
                        self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                        return
                    }
                }
                
                guard let data = data, !data.isEmpty else {
                    print("❌ No data received")
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("❌ Failed to decode image data")
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                    return
                }
                
                print("✅ Successfully loaded image directly from URL, size: \(image.size)")
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    private func setupEditButton() {
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func editButtonTapped() {
        // Create alert with text fields for editing parent info
        let alert = UIAlertController(title: "Edit Parent Information", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.parentData?.name
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.text = self.parentData?.email
            textField.keyboardType = .emailAddress
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Phone Number"
            textField.text = self.parentData?.phoneNumber
            textField.keyboardType = .phonePad
        }
        
        // Add gender selection
        let genderAction = UIAlertAction(title: "Select Gender", style: .default) { _ in
            self.showGenderSelectionAlert()
        }
        
        // Add relation selection
        let relationAction = UIAlertAction(title: "Select Relation", style: .default) { _ in
            self.showRelationSelectionAlert()
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let nameField = alert.textFields?[0],
                  let emailField = alert.textFields?[1],
                  let phoneField = alert.textFields?[2],
                  let name = nameField.text, !name.isEmpty,
                  let email = emailField.text, !email.isEmpty else {
                self?.showErrorAlert(message: "Please fill in all required fields.")
                return
            }
            
            // Update parent data
            self.updateParentInfo(name: name, email: email, phone: phoneField.text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(genderAction)
        alert.addAction(relationAction)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showGenderSelectionAlert() {
        let alert = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
        
        let maleAction = UIAlertAction(title: "Male", style: .default) { [weak self] _ in
            self?.updateGender(.male)
        }
        
        let femaleAction = UIAlertAction(title: "Female", style: .default) { [weak self] _ in
            self?.updateGender(.female)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(maleAction)
        alert.addAction(femaleAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showRelationSelectionAlert() {
        let alert = UIAlertController(title: "Select Relation", message: nil, preferredStyle: .actionSheet)
        
        let fatherAction = UIAlertAction(title: "Father", style: .default) { [weak self] _ in
            self?.updateRelation(.father)
        }
        
        let motherAction = UIAlertAction(title: "Mother", style: .default) { [weak self] _ in
            self?.updateRelation(.mother)
        }
        
        let guardianAction = UIAlertAction(title: "Guardian", style: .default) { [weak self] _ in
            self?.updateRelation(.guardian)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(fatherAction)
        alert.addAction(motherAction)
        alert.addAction(guardianAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func profileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        
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
    
    private func updateParentInfo(name: String, email: String, phone: String?) {
        guard let parentData = parentData, let userId = AuthManager.shared.currentUserID else {
            showErrorAlert(message: "Failed to update parent information.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let client = AuthManager.shared.getClient()
                
                // Create a struct that conforms to Encodable for the update operation
                struct ParentUpdate: Encodable {
                    let name: String
                    let email: String
                    let phone_number: String?
                }
                
                // Create an encodable object with the updated values
                let updateData = ParentUpdate(
                    name: name,
                    email: email,
                    phone_number: phone?.isEmpty == true ? nil : phone
                )
                
                // Update parent in database
                _ = try await client.database
                    .from("parents")
                    .update(updateData)
                    .eq("uid", value: userId)
                    .execute()
                
                // Update local parent data
                self.parentData?.name = name
                self.parentData?.email = email
                self.parentData?.phoneNumber = phone
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.updateUI()
                    self.loadingIndicator.stopAnimating()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to update parent information: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateGender(_ gender: Gender) {
        guard let parentData = parentData, let userId = AuthManager.shared.currentUserID else {
            showErrorAlert(message: "Failed to update gender.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let client = AuthManager.shared.getClient()
                
                // Create a struct that conforms to Encodable for the update operation
                struct GenderUpdate: Encodable {
                    let gender: String
                }
                
                // Update gender in database
                _ = try await client.database
                    .from("parents")
                    .update(GenderUpdate(gender: gender.rawValue))
                    .eq("uid", value: userId)
                    .execute()
                
                // Update local parent data
                self.parentData?.gender = gender
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.updateUI()
                    self.loadingIndicator.stopAnimating()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to update gender: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateRelation(_ relation: Relation) {
        guard let parentData = parentData, let userId = AuthManager.shared.currentUserID else {
            showErrorAlert(message: "Failed to update relation.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let client = AuthManager.shared.getClient()
                
                // Create a struct that conforms to Encodable for the update operation
                struct RelationUpdate: Encodable {
                    let relation: String
                }
                
                // Update relation in database
                _ = try await client.database
                    .from("parents")
                    .update(RelationUpdate(relation: relation.rawValue))
                    .eq("uid", value: userId)
                    .execute()
                
                // Update local parent data
                self.parentData?.relation = relation
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.updateUI()
                    self.loadingIndicator.stopAnimating()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to update relation: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let parentData = parentData, let userId = AuthManager.shared.currentUserID else {
            showErrorAlert(message: "Failed to upload profile image.")
            return
        }
        
        loadingIndicator.startAnimating()
        
        Task {
            do {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ParentInfoViewController", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                }
                
                let client = AuthManager.shared.getClient()
                let fileName = "parent_image_\(userId).jpeg"
                
                // Upload image to Supabase storage
                _ = try await client.storage
                    .from("profile-images")
                    .upload(fileName, data: imageData)
                
                // Create a signed URL for the uploaded image
                let signedURL = try await client.storage
                    .from("profile-images")
                    .createSignedURL(path: fileName, expiresIn: 31536000) // 1 year expiration
                
                // Create a struct that conforms to Encodable for the update operation
                struct ImageUpdate: Encodable {
                    let parentimage_url: String
                }
                
                // Update parent record with new image URL
                _ = try await client.database
                    .from("parents")
                    .update(ImageUpdate(parentimage_url: signedURL.absoluteString))
                    .eq("uid", value: userId)
                    .execute()
                
                // Update local parent data
                self.parentData?.parentimage_url = signedURL.absoluteString
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.profileImageView.image = image
                    self.loadingIndicator.stopAnimating()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to upload profile image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Parent information updated successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
            uploadProfileImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadProfileImage(originalImage)
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
