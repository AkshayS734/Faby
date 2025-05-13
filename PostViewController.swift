import UIKit

class PostViewController: UIViewController {
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemBlue
        imageView.layer.cornerRadius = 25
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .white
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "Adarsh"
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter a title for your post..."
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = .label
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .secondaryLabel
        textView.text = "Share your thoughts here..."
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add Image", for: .normal)
        button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        return button
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private let titleSeparatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTextViewDelegate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(separatorLine)
        view.addSubview(titleTextField)
        view.addSubview(titleSeparatorLine)
        view.addSubview(contentTextView)
        view.addSubview(addImageButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            titleTextField.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            titleSeparatorLine.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            titleSeparatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleSeparatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleSeparatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            contentTextView.topAnchor.constraint(equalTo: titleSeparatorLine.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            contentTextView.heightAnchor.constraint(equalToConstant: 200),
            
            addImageButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            addImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addImageButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Create Post"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let postButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handlePost))
        navigationItem.rightBarButtonItem = postButton
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
    }
    
    private func setupTextViewDelegate() {
        contentTextView.delegate = self
    }
    
    // MARK: - Actions
    @objc private func handlePost() {
        // Add post handling logic
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension PostViewController: UITextViewDelegate {
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
}

// MARK: - Loading UI
private let loadingContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBackground.withAlphaComponent(0.8)
    view.layer.cornerRadius = 12
    view.clipsToBounds = true
    view.isHidden = true
    return view
}()

private let loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
}()

private let loadingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Posting..."
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .label
    label.textAlignment = .center
    return label
}()

// Update the existing showLoadingIndicator method
private func showLoadingIndicator(withMessage message: String = "Posting...") {
    // Setup loading container if not already added
    if loadingContainerView.superview == nil {
        view.addSubview(loadingContainerView)
        loadingContainerView.addSubview(loadingIndicator)
        loadingContainerView.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingContainerView.widthAnchor.constraint(equalToConstant: 140),
            loadingContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: 20),
            
            loadingLabel.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 8),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -8)
        ])
    }
    
    // Update loading message
    loadingLabel.text = message
    
    // Show loading UI with animation
    loadingContainerView.alpha = 0
    loadingContainerView.isHidden = false
    loadingIndicator.startAnimating()
    
    UIView.animate(withDuration: 0.25) {
        self.loadingContainerView.alpha = 1
    }
}

// Add method to hide loading indicator
private func hideLoadingIndicator() {
    UIView.animate(withDuration: 0.25) {
        self.loadingContainerView.alpha = 0
    } completion: { _ in
        self.loadingContainerView.isHidden = true
        self.loadingIndicator.stopAnimating()
    }
}

// Update error alert to be more native and informative
private func showAlert(title: String = "Error", message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    
    // Present alert with animation
    present(alert, animated: true)
}

// When starting an operation:
showLoadingIndicator(withMessage: "Uploading post...")

// When operation completes:
hideLoadingIndicator()

// If there's an error:
showAlert(title: "Upload Failed", message: "Please check your connection and try again.") 