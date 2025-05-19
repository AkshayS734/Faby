//
//  PostViewController.swift
//  Toddler Talk1
//
//  Created by Vivek Kumar on 26/01/25.
//

import UIKit
import Supabase

// Define the delegate protocol
protocol PostViewDelegate: AnyObject {
    func didPostComment(_ comment: Post)
}

class PostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITextFieldDelegate{

    // MARK: - UI Components
    private lazy var containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.backgroundColor = .systemGray6
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        
        // Default to Anonymous, will be updated in viewDidLoad
        label.text = "Anonymous"
        
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "What's on your mind?"
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.textColor = .label
        textField.backgroundColor = .clear
        textField.returnKeyType = .next
        return textField
    }()
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .secondaryLabel
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return textView
    }()
    
    private lazy var imagePickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Photo", for: .normal)
        button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 12
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.addTarget(self, action: #selector(imagePickerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = true
        imageView.alpha = 0 // Start with 0 alpha for smooth animation
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeImage))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var categoryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.alpha = 1
        return view
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Category"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var selectedCategoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0/500"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Post", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        return button
    }()

    let placeholderLabel = UILabel()
    weak var delegate: PostViewDelegate?
    var selectedCategory: String?
    var topicName: String?
    
    // Character limit
    private let characterLimit = 500

//    let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")

    private var selectedImage: UIImage?
    
    // Add height constraint for selectedImageView
    private var selectedImageViewHeightConstraint: NSLayoutConstraint?
    private var categoryViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupDelegates()
        setupInitialState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(contentView)
        
        [headerView, titleTextField, contentTextView, imagePickerButton,
         selectedImageView, categoryView, characterCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(usernameLabel)
        
        categoryView.addSubview(categoryLabel)
        categoryView.addSubview(selectedCategoryLabel)
        
        // Create height constraint for selectedImageView
        selectedImageViewHeightConstraint = selectedImageView.heightAnchor.constraint(equalToConstant: 0)
        selectedImageViewHeightConstraint?.isActive = true
        
        // Create top constraint for categoryView
        categoryViewTopConstraint = categoryView.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: 16)
        categoryViewTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            containerScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            usernameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 180),
            
            imagePickerButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            imagePickerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imagePickerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imagePickerButton.heightAnchor.constraint(equalToConstant: 44),
            
            selectedImageView.topAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 16),
            selectedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            selectedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryView.heightAnchor.constraint(equalToConstant: 50),
            
            categoryLabel.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            
            selectedCategoryLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            selectedCategoryLabel.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor),
            
            characterCountLabel.topAnchor.constraint(equalTo: categoryView.bottomAnchor, constant: 8),
            characterCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            characterCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Create Post"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(handleBack))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(postComment))
    }
    
    private func setupDelegates() {
        contentTextView.delegate = self
        titleTextField.delegate = self
        
        // Update username label and profile image with current parent data
        if let currentParent = ParentDataModel.shared.currentParent {
            usernameLabel.text = currentParent.name
            
            // Load profile image if available
            if let parentImageUrl = currentParent.parentimage_url, !parentImageUrl.isEmpty {
                print("✅ PostViewController - Found parentimage_url: \(parentImageUrl)")
                if let url = URL(string: parentImageUrl) {
                    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data) {
                                print("✅ PostViewController - Successfully loaded image")
                                self?.profileImageView.image = image
                            } else {
                                print("⚠️ PostViewController - Failed to load image data")
                                // Fallback to default image
                                self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                                self?.profileImageView.tintColor = .systemBlue
                            }
                        }
                    }.resume()
                } else {
                    print("⚠️ PostViewController - Invalid URL format for parentimage_url")
                }
            }
        } else if let userId = AuthManager.shared.currentUserID {
            // If parent data isn't loaded yet but we have a user ID, try to fetch it
            ParentDataModel.shared.updateCurrentParent(userId: userId) { [weak self] success in
                if success, let currentParent = ParentDataModel.shared.currentParent {
                    DispatchQueue.main.async {
                        self?.usernameLabel.text = currentParent.name
                        
                        // Load profile image if available
                        if let parentImageUrl = currentParent.parentimage_url, !parentImageUrl.isEmpty {
                            print("✅ PostViewController - Found parentimage_url: \(parentImageUrl)")
                            if let url = URL(string: parentImageUrl) {
                                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                                    DispatchQueue.main.async {
                                        if let data = data, let image = UIImage(data: data) {
                                            print("✅ PostViewController - Successfully loaded image")
                                            self?.profileImageView.image = image
                                        } else {
                                            print("⚠️ PostViewController - Failed to load image data")
                                            // Fallback to default image
                                            self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                                            self?.profileImageView.tintColor = .systemBlue
                                        }
                                    }
                                }.resume()
                            } else {
                                print("⚠️ PostViewController - Invalid URL format for parentimage_url")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setupInitialState() {
        selectedCategoryLabel.text = topicName ?? selectedCategory ?? "Select a category"
        contentTextView.text = "Share your thoughts here..."
        contentTextView.textColor = .secondaryLabel
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func removeImage() {
        // Animate the removal of the image
        UIView.animate(withDuration: 0.3, animations: {
            self.selectedImageView.alpha = 0
            self.selectedImageViewHeightConstraint?.constant = 0
            self.categoryViewTopConstraint?.constant = 16
            self.view.layoutIfNeeded()
        }) { _ in
            self.selectedImage = nil
            self.selectedImageView.image = nil
            self.selectedImageView.isHidden = true
            self.imagePickerButton.setTitle("Add Photo", for: .normal)
            
            UIView.animate(withDuration: 0.3) {
                self.imagePickerButton.alpha = 1
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Share your thoughts here..."
            textView.textColor = .secondaryLabel
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        characterCountLabel.text = "\(count)/500"
        
        if count > 500 {
            textView.text = String(textView.text.prefix(500))
        }
    }
    
    // MARK: - Loading UI
    private func showLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .systemBlue
        indicator.hidesWhenStopped = true
        
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        indicator.startAnimating()
        return indicator
    }
    
    private func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func postComment(_ sender: Any) {
        print("⚠️ Starting postComment...")
        guard let title = titleTextField.text, !title.isEmpty,
              let text = contentTextView.text, !text.isEmpty else {
                showAlert(message: "Please enter both a title and a comment.")
                return
            }

        print("⚠️ Checking for user ID...")
        guard let userId = AuthManager.shared.currentUserID else {
            showAlert(message: "Error: You need to be logged in to create a post!")
            return
        }
            
        print("⚠️ User ID found: \(userId)")
        
        // Get parent name for display
        let parentName = ParentDataModel.shared.currentParent?.name ?? "Anonymous"

        print("⚠️ Checking for category...")
        guard let category = selectedCategory else {
            showAlert(message: "Error: No category selected!")
            return
        }
        print("⚠️ Category found: \(category)")

        // Show loading indicator
        let loadingIndicator = showLoadingIndicator()
        
        // Convert image to Data if selected
        var imageData: Data? = nil
        if let image = selectedImage {
            imageData = image.jpegData(compressionQuality: 0.8)
        }
        
        // First check if parent exists in Supabase or create one
        Task {
            do {
                print("⚠️ Checking if parent exists in Supabase...")
                
                // We already have the userId from SupabaseManager, so we'll use that directly
                let parentId = userId
                print("✅ Using logged-in user ID: \(parentId)")
                
                // Check if parent exists in the database
                let parentResponse = try await client.database
                    .from("parents")
                    .select("uid, name")
                    .eq("uid", value: parentId)
                    .limit(1)
                    .execute()
                
                // If parent doesn't exist in database, create one
                if let parentData = String(data: parentResponse.data, encoding: .utf8), parentData.contains("[]") {
                    // Parent not found, create one
                    print("⚠️ Parent not found in Supabase, creating new parent...")
                    
                    try await client.database
                        .from("parents")
                        .insert([
                            "uid": parentId,
                            "name": parentName,
                            "gender": "male",  // Default values
                            "relation": "guardian"
                        ])
                        .execute()
                    
                    print("✅ Created new parent with ID: \(parentId)")
                } else {
                    print("✅ Parent already exists in database")
                }
                
                // Create post with image if available
                guard let categoryUUID = UUID(uuidString: category) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID format"])
                }
                
                ToddlerTalkDataController.shared.addPost(
                    title: title,
                    content: text,
                    topicID: categoryUUID,
                    imageData: imageData
                ) { success, error in
                    DispatchQueue.main.async {
                        loadingIndicator.removeFromSuperview()
                        
                        if success {
                            print("✅ Post added successfully!")
                            // Show success alert
                            let alert = UIAlertController(
                                title: "Success!",
                                message: "Your post has been successfully created.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                                self?.navigationController?.popViewController(animated: true)
                            })
                            self.present(alert, animated: true)
                        } else {
                            print("❌ Error adding post: \(error?.localizedDescription ?? "Unknown error")")
                            self.showAlert(message: "Failed to add post. Please try again.")
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    loadingIndicator.removeFromSuperview()
                    print("❌ Error: \(error.localizedDescription)")
                    self.showAlert(message: "Failed to create post. Please try again.")
                }
            }
        }
        
        print("⚠️ Completed postComment method")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupImagePicker() {
        // Configure image picker button and view
        imagePickerButton.addTarget(self, action: #selector(imagePickerButtonTapped), for: .touchUpInside)
        
        // Add constraints for image picker components if not already added
        if !contentView.subviews.contains(imagePickerButton) {
            contentView.addSubview(imagePickerButton)
            contentView.addSubview(selectedImageView)
            
            NSLayoutConstraint.activate([
                imagePickerButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
                imagePickerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                imagePickerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                imagePickerButton.heightAnchor.constraint(equalToConstant: 44),
                
                selectedImageView.topAnchor.constraint(equalTo: imagePickerButton.bottomAnchor, constant: 8),
                selectedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                selectedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                selectedImageView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
    }

    @objc private func imagePickerButtonTapped() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = imagePickerButton
            popoverController.sourceRect = imagePickerButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Error", message: "Camera not available.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true // ✅ Enable cropping

        present(picker, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        
        if let edited = info[.editedImage] as? UIImage {
            image = edited
        } else if let original = info[.originalImage] as? UIImage {
            image = original
        }

        if let image = image {
            selectedImage = image
            selectedImageView.image = image
            selectedImageView.isHidden = false

            // Animate the appearance of the image and update constraints
            UIView.animate(withDuration: 0.3) {
                self.selectedImageView.alpha = 1
                self.selectedImageViewHeightConstraint?.constant = 200
                self.categoryViewTopConstraint?.constant = 16
                self.view.layoutIfNeeded()
            }

            imagePickerButton.setTitle("Change Image", for: .normal)
        }
        
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}
