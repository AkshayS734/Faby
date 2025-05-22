import UIKit

class SavedPostDetailViewController: UIViewController {
    private let post: Post
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let postImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorInfoView = UIView()
    private let authorImageView = UIImageView()
    private let authorNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let unsaveButton = UIButton(type: .system)
    
    // Initialization with a Post
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithPost()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Post Details"
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup post image view
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.backgroundColor = .systemGray6
        postImageView.layer.cornerRadius = 8
        contentView.addSubview(postImageView)
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        // Setup author info view
        authorInfoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(authorInfoView)
        
        // Setup author image view
        authorImageView.translatesAutoresizingMaskIntoConstraints = false
        authorImageView.contentMode = .scaleAspectFill
        authorImageView.clipsToBounds = true
        authorImageView.backgroundColor = .systemGray5
        authorImageView.layer.cornerRadius = 20
        authorInfoView.addSubview(authorImageView)
        
        // Setup author name label
        authorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        authorNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        authorNameLabel.textColor = .label
        authorInfoView.addSubview(authorNameLabel)
        
        // Setup date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        authorInfoView.addSubview(dateLabel)
        
        // Setup content label
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .label
        contentView.addSubview(contentLabel)
        
        // Setup unsave button
        unsaveButton.translatesAutoresizingMaskIntoConstraints = false
        unsaveButton.setTitle("Remove from Saved", for: .normal)
        unsaveButton.setTitleColor(.systemRed, for: .normal)
        unsaveButton.backgroundColor = .systemBackground
        unsaveButton.layer.borderWidth = 1
        unsaveButton.layer.borderColor = UIColor.systemRed.cgColor
        unsaveButton.layer.cornerRadius = 8
        unsaveButton.addTarget(self, action: #selector(unsavePost), for: .touchUpInside)
        contentView.addSubview(unsaveButton)
        
        // Set layout constraints
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
            
            // Post image view constraints
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Author info view constraints
            authorInfoView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            authorInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authorInfoView.heightAnchor.constraint(equalToConstant: 50),
            
            // Author image view constraints
            authorImageView.leadingAnchor.constraint(equalTo: authorInfoView.leadingAnchor),
            authorImageView.centerYAnchor.constraint(equalTo: authorInfoView.centerYAnchor),
            authorImageView.widthAnchor.constraint(equalToConstant: 40),
            authorImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Author name label constraints
            authorNameLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 12),
            authorNameLabel.topAnchor.constraint(equalTo: authorInfoView.topAnchor, constant: 4),
            authorNameLabel.trailingAnchor.constraint(equalTo: authorInfoView.trailingAnchor),
            
            // Date label constraints
            dateLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 12),
            dateLabel.topAnchor.constraint(equalTo: authorNameLabel.bottomAnchor, constant: 2),
            dateLabel.trailingAnchor.constraint(equalTo: authorInfoView.trailingAnchor),
            
            // Content label constraints
            contentLabel.topAnchor.constraint(equalTo: authorInfoView.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Unsave button constraints
            unsaveButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            unsaveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            unsaveButton.widthAnchor.constraint(equalToConstant: 200),
            unsaveButton.heightAnchor.constraint(equalToConstant: 44),
            unsaveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func configureWithPost() {
        titleLabel.text = post.postTitle
        contentLabel.text = post.postContent
        
        // Format and display date
        if let dateString = post.createdAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, yyyy"
                dateLabel.text = displayFormatter.string(from: date)
            } else {
                dateLabel.text = dateString
            }
        } else {
            dateLabel.text = "Unknown date"
        }
        
        // Set author name and image
        if let parentName = post.parents?.first?.name {
            authorNameLabel.text = parentName
            
            // Load author image if available
            if let parentImageURL = post.parents?.first?.parentimage_url, !parentImageURL.isEmpty, let url = URL(string: parentImageURL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.authorImageView.image = image
                        }
                    }
                }.resume()
            } else {
                // Set default author image if no image URL is available
                authorImageView.image = UIImage(systemName: "person.circle")
                authorImageView.tintColor = .gray
            }
        } else {
            authorNameLabel.text = "Unknown Author"
            authorImageView.image = UIImage(systemName: "person.circle")
            authorImageView.tintColor = .gray
        }
        
        // Load post image if available
        if let imageUrlString = post.image_url, !imageUrlString.isEmpty, let url = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.postImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.postImageView.image = UIImage(systemName: "photo")
                        self?.postImageView.tintColor = .gray
                    }
                }
            }.resume()
        } else {
            postImageView.image = UIImage(systemName: "photo")
            postImageView.tintColor = .gray
        }
    }
    
    @objc private func unsavePost() {
        // Show confirmation alert
        let alert = UIAlertController(title: "Remove from Saved", message: "Are you sure you want to remove this post from your saved posts?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Show loading
            let loadingAlert = UIAlertController(title: nil, message: "Removing...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            loadingAlert.view.addSubview(loadingIndicator)
            self.present(loadingAlert, animated: true)
            
            // Remove post from saved posts using the data controller
            ProfileSettingDataController.shared.removeFromSavedPosts(postId: self.post.postId) { success in
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        if success {
                            // Show success message and pop view controller
                            let successAlert = UIAlertController(title: "Success", message: "Post removed from saved posts", preferredStyle: .alert)
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                self.navigationController?.popViewController(animated: true)
                            })
                            self.present(successAlert, animated: true)
                        } else {
                            // Show error message
                            let errorAlert = UIAlertController(title: "Error", message: "Failed to remove post from saved posts. Please try again later.", preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        
        present(alert, animated: true)
    }
}
