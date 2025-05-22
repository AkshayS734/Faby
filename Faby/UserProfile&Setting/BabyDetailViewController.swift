import UIKit
import Supabase

class BabyDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView = UIImageView()
    private let changePhotoButton = UIButton(type: .system)
    
    private let nameLabel = UILabel()
    private let nameValueLabel = UILabel()
    
    private let dobLabel = UILabel()
    private let dobValueLabel = UILabel()
    
    private let genderLabel = UILabel()
    private let genderValueLabel = UILabel()
    
    private let heightLabel = UILabel()
    private let heightValueLabel = UILabel()
    
    private let weightLabel = UILabel()
    private let weightValueLabel = UILabel()
    
    private let saveButton = UIButton(type: .system)
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private var baby: Baby?
    private var selectedImage: UIImage?
    
    // Direct Supabase client reference from AuthManager
    private let client = AuthManager.shared.client
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadBabyData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Baby Profile"
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
        changePhotoButton.setTitleColor(.systemBlue, for: .normal)
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        contentView.addSubview(changePhotoButton)
        
        // Setup name fields
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(nameLabel)
        
        nameValueLabel.translatesAutoresizingMaskIntoConstraints = false
        nameValueLabel.font = UIFont.systemFont(ofSize: 16)
        nameValueLabel.textColor = .darkGray
        contentView.addSubview(nameValueLabel)
        
        // Setup date of birth fields
        dobLabel.translatesAutoresizingMaskIntoConstraints = false
        dobLabel.text = "Date of Birth"
        dobLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(dobLabel)
        
        dobValueLabel.translatesAutoresizingMaskIntoConstraints = false
        dobValueLabel.font = UIFont.systemFont(ofSize: 16)
        dobValueLabel.textColor = .darkGray
        contentView.addSubview(dobValueLabel)
        
        // Setup gender fields
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(genderLabel)
        
        genderValueLabel.translatesAutoresizingMaskIntoConstraints = false
        genderValueLabel.font = UIFont.systemFont(ofSize: 16)
        genderValueLabel.textColor = .darkGray
        contentView.addSubview(genderValueLabel)
        
        // Setup height fields
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        heightLabel.text = "Height"
        heightLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(heightLabel)
        
        heightValueLabel.translatesAutoresizingMaskIntoConstraints = false
        heightValueLabel.font = UIFont.systemFont(ofSize: 16)
        heightValueLabel.textColor = .darkGray
        contentView.addSubview(heightValueLabel)
        
        // Setup weight fields
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.text = "Weight"
        weightLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(weightLabel)
        
        weightValueLabel.translatesAutoresizingMaskIntoConstraints = false
        weightValueLabel.font = UIFont.systemFont(ofSize: 16)
        weightValueLabel.textColor = .darkGray
        contentView.addSubview(weightValueLabel)
        
        // Setup save button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Photo", for: .normal)
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
            nameLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Name value label constraints
            nameValueLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            nameValueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            nameValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Date of birth label constraints
            dobLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            dobLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dobLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Date of birth value label constraints
            dobValueLabel.centerYAnchor.constraint(equalTo: dobLabel.centerYAnchor),
            dobValueLabel.leadingAnchor.constraint(equalTo: dobLabel.trailingAnchor, constant: 10),
            dobValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Gender label constraints
            genderLabel.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Gender value label constraints
            genderValueLabel.centerYAnchor.constraint(equalTo: genderLabel.centerYAnchor),
            genderValueLabel.leadingAnchor.constraint(equalTo: genderLabel.trailingAnchor, constant: 10),
            genderValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Height label constraints
            heightLabel.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 20),
            heightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heightLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Height value label constraints
            heightValueLabel.centerYAnchor.constraint(equalTo: heightLabel.centerYAnchor),
            heightValueLabel.leadingAnchor.constraint(equalTo: heightLabel.trailingAnchor, constant: 10),
            heightValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Weight label constraints
            weightLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 20),
            weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightLabel.widthAnchor.constraint(equalToConstant: 120),
            
            // Weight value label constraints
            weightValueLabel.centerYAnchor.constraint(equalTo: weightLabel.centerYAnchor),
            weightValueLabel.leadingAnchor.constraint(equalTo: weightLabel.trailingAnchor, constant: 10),
            weightValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Save button constraints
            saveButton.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadBabyData() {
        loadingIndicator.startAnimating()
        
        // Get baby data from DataController
        if let baby = DataController.shared.baby {
            self.baby = baby
            updateUI()
            loadBabyImage()
            loadingIndicator.stopAnimating()
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
        
        // Set name
        nameValueLabel.text = baby.name
        
        // Format date of birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        
        if let date = dateFormatter.date(from: baby.dateOfBirth) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy"
            dobValueLabel.text = displayFormatter.string(from: date)
        } else {
            dobValueLabel.text = baby.dateOfBirth
        }
        
        // Set gender
        genderValueLabel.text = baby.gender.rawValue.capitalized
        
        // Set height (latest measurement)
        if let latestHeight = baby.heightMeasurements.sorted(by: { $0.date > $1.date }).first {
            heightValueLabel.text = "\(latestHeight.value) cm"
        } else {
            heightValueLabel.text = "Not recorded"
        }
        
        // Set weight (latest measurement)
        if let latestWeight = baby.weightMeasurements.sorted(by: { $0.date > $1.date }).first {
            weightValueLabel.text = "\(latestWeight.value) kg"
        } else {
            weightValueLabel.text = "Not recorded"
        }
        
        // Update save button state
        saveButton.isEnabled = selectedImage != nil
        saveButton.alpha = selectedImage != nil ? 1.0 : 0.5
    }
    
    private func loadBabyImage() {
        guard let baby = baby, let imageURL = baby.imageURL, !imageURL.isEmpty else {
            print("⚠️ No image URL available for baby")
            return
        }
        
        print("📷 Baby image URL: \(imageURL)")
        
        // Try to load image directly with the URL - this approach works for parent images
        guard let url = URL(string: imageURL) else {
            print("❌ Invalid baby image URL: \(imageURL)")
            return
        }
        
        print("🔍 Attempting to load baby image directly from URL: \(imageURL)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error loading baby image: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Baby image HTTP response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ Bad HTTP response for baby image: \(httpResponse.statusCode)")
                    // If URL doesn't work directly, try to refresh the signed URL
                    self?.refreshSignedURL(for: imageURL)
                    return
                }
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode baby image data")
                return
            }
            
            print("✅ Successfully loaded baby image")
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    private func refreshSignedURL(for imageURL: String) {
        // For public URLs from postimages bucket, we don't need to refresh
        // Just try loading directly
        loadImageFromDirectURL(imageURL)
    }
    
    private func loadImageFromDirectURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL format: \(urlString)")
            return
        }
        
        print("🔍 Loading baby image from refreshed URL: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error loading baby image from refreshed URL: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode baby image data from refreshed URL")
                return
            }
            
            print("✅ Successfully loaded baby image from refreshed URL")
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }
        
        print("📷 Attempting to load baby image from URL: \(urlString)")
        print("🔍 Starting URLSession task to load baby image from: \(urlString)")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error loading baby image: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Baby image HTTP response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("❌ Bad HTTP response for baby image: \(httpResponse.statusCode)")
                    print("❌ Failed to load baby image from URL")
                    return
                }
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Failed to decode baby image data")
                return
            }
            
            print("✅ Successfully loaded baby image")
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }
        
        task.resume()
    }
    
    private func updateBabyImageURL(_ newURL: String) {
        guard let baby = baby else { return }
        
        // Update local baby object
        baby.imageURL = newURL
        DataController.shared.baby?.imageURL = newURL
        
        // Update database record
        Task {
            do {
                // Create a struct for the update operation
                struct ImageUpdate: Encodable {
                    let image_url: String
                }
                
                let response = try await client.database
                    .from("baby")
                    .update(ImageUpdate(image_url: newURL))
                    .eq("uid", value: baby.babyID.uuidString)
                    .execute()
                
                print("✅ Updated baby record with signed URL")
            } catch {
                print("⚠️ Could not update baby record with signed URL: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
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
    
    @objc private func saveButtonTapped() {
        guard let baby = baby else { return }
        
        // Only validate if an image is selected
        guard let selectedImage = selectedImage else {
            showErrorAlert(message: "Please select an image first.")
            return
        }
        
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        
        // Upload image to Supabase
        Task {
            do {
                try await uploadBabyImage(image: selectedImage, for: baby)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.selectedImage = nil
                    self.updateUI()
                    self.showSuccessAlert()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadingIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.showErrorAlert(message: "Failed to upload image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Image Upload
    private func uploadBabyImage(image: UIImage, for baby: Baby) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "BabyDetailViewController", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let fileName = "baby_\(baby.babyID.uuidString)_\(Int(Date().timeIntervalSince1970)).jpg"
        
        print("🔍 Attempting to upload baby image to storage bucket")
        print("📊 Original image size: \(Double(imageData.count) / 1024.0)KB")
        
        // Upload image to Supabase storage
        do {
            // We won't try to delete old files since each upload will have a unique name
            
            // Using the postimages bucket which is known to work
            print("📊 Uploading to postimages bucket...")
            _ = try await client.storage
                .from("postimages")
                .upload(
                    path: fileName,
                    file: imageData
                )
            
            print("✅ Successfully uploaded baby image to storage")
            
            // Use the same public URL approach that works for posts
            let publicURL = "https://tmnltannywgqrrxavoge.supabase.co/storage/v1/object/public/postimages/\(fileName)"
            print("📊 Generated public URL for baby image: \(publicURL)")
            
            // Create a struct that conforms to Encodable for the update operation
            struct ImageUpdate: Encodable {
                let image_url: String
            }
            
            print("🔍 Updating baby record with new image URL")
            
            do {
                let response = try await client.database
                    .from("baby")
                    .update(ImageUpdate(image_url: publicURL))
                    .eq("uid", value: baby.babyID.uuidString)
                    .execute()
                
                // Print response status
                print("📊 Database update status: \(response.status)")
                
                if response.status >= 200 && response.status < 300 {
                    print("✅ Successfully updated baby record with new image URL")
                } else {
                    print("⚠️ Database update returned non-success status code: \(response.status)")
                }
            } catch {
                print("❌ Error updating baby record: \(error.localizedDescription)")
                print("📊 Detailed error: \(error)")
                
                // Try a different approach - direct RPC call
                print("📊 Attempting alternative update method...")
                
                do {
                    // Create a struct for the RPC call
                    struct UpdateBabyImageParams: Encodable {
                        let baby_id: String
                        let image_url: String
                    }
                    
                    let params = UpdateBabyImageParams(
                        baby_id: baby.babyID.uuidString,
                        image_url: publicURL
                    )
                    
                    // Call a stored procedure if available, or fall back to a direct query
                    let rpcResponse = try await client.database
                        .rpc("update_baby_image", params: params)
                        .execute()
                    
                    print("✅ Successfully updated baby record using RPC method")
                } catch let rpcError {
                    print("❌ Error with alternative update method: \(rpcError.localizedDescription)")
                    throw error // Throw the original error
                }
            }
            
            // Update local baby object
            baby.imageURL = publicURL
            
            // Update the DataController's baby object
            DataController.shared.baby?.imageURL = publicURL
        } catch {
            print("❌ Error in uploadBabyImage: \(error.localizedDescription)")
            
            // If the error is about resource already existing, try to update the database anyway
            if error.localizedDescription.contains("already exists") {
                do {
                    print("🔍 Resource already exists, trying to update database with URL anyway")
                    
                    // Use public URL instead of signed URL
                    let publicURL = "https://tmnltannywgqrrxavoge.supabase.co/storage/v1/object/public/babyimage/\(fileName)"
                    print("📊 Generated public URL for existing baby image: \(publicURL)")
                    
                    // Create a struct that conforms to Encodable for the update operation
                    struct ImageUpdate: Encodable {
                        let image_url: String
                    }
                    
                    // Update baby record with the URL
                    let response = try await client.database
                        .from("baby")
                        .update(ImageUpdate(image_url: publicURL))
                        .eq("uid", value: baby.babyID.uuidString)
                        .execute()
                    
                    print("✅ Successfully updated baby record with image URL despite upload error")
                    
                    // Update local baby object
                    baby.imageURL = publicURL
                    
                    // Update the DataController's baby object
                    DataController.shared.baby?.imageURL = publicURL
                    
                    // Return without throwing an error since we succeeded in updating the database
                    return
                } catch let dbError {
                    print("❌ Error updating database after upload error: \(dbError.localizedDescription)")
                    throw dbError
                }
            }
            
            throw error
        }
    }
    
    // MARK: - Alerts
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Baby profile photo updated successfully.", preferredStyle: .alert)
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
            selectedImage = editedImage
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profileImageView.image = originalImage
        }
        
        // Update save button state
        saveButton.isEnabled = selectedImage != nil
        saveButton.alpha = selectedImage != nil ? 1.0 : 0.5
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
