import UIKit

class SavedPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let noPostsLabel = UILabel()
    
    private var savedPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSavedPosts()
    }
    
    private func setupUI() {
        title = "Saved Posts"
        view.backgroundColor = .systemBackground
        
        // Setup loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemBlue
        view.addSubview(loadingIndicator)
        
        // Setup no posts label
        noPostsLabel.translatesAutoresizingMaskIntoConstraints = false
        noPostsLabel.text = "You haven't saved any posts yet."
        noPostsLabel.textAlignment = .center
        noPostsLabel.font = UIFont.systemFont(ofSize: 16)
        noPostsLabel.textColor = .gray
        noPostsLabel.isHidden = true
        view.addSubview(noPostsLabel)
        
        // Setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SavedPostCell.self, forCellReuseIdentifier: "SavedPostCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // No posts label constraints
            noPostsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noPostsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noPostsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noPostsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func fetchSavedPosts() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        noPostsLabel.isHidden = true
        
        SavedPostsDataController.shared.loadSavedPosts { [weak self] success in
            guard let self = self else { return }
            
            self.loadingIndicator.stopAnimating()
            
            if !success {
                print("❌ Error fetching saved posts")
                self.showErrorAlert(message: "Failed to load saved posts. Please try again later.")
                return
            }
            
            // Get posts from data controller
            let posts = SavedPostsDataController.shared.getAllSavedPosts()
            self.savedPosts = posts
            
            DispatchQueue.main.async {
                if posts.isEmpty {
                    self.noPostsLabel.isHidden = false
                    self.tableView.isHidden = true
                } else {
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPostCell", for: indexPath) as! SavedPostCell
        let post = savedPosts[indexPath.row]
        cell.configure(with: post)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = savedPosts[indexPath.row]
        
        // Navigate to post detail view
        let postDetailVC = SavedPostDetailViewController(post: post)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SavedPostCell

class SavedPostCell: UITableViewCell {
    private let postImageView = UIImageView()
    private let titleLabel = UILabel()
    private let contentPreviewLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        // Setup post image view
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 5
        postImageView.backgroundColor = .systemGray6
        contentView.addSubview(postImageView)
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        // Setup content preview label
        contentPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPreviewLabel.font = UIFont.systemFont(ofSize: 14)
        contentPreviewLabel.textColor = .darkGray
        contentPreviewLabel.numberOfLines = 2
        contentView.addSubview(contentPreviewLabel)
        
        // Setup author label
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.textColor = .gray
        contentView.addSubview(authorLabel)
        
        // Setup date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            // Post image view constraints
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            postImageView.widthAnchor.constraint(equalToConstant: 70),
            postImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            // Content preview label constraints
            contentPreviewLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 15),
            contentPreviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            contentPreviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            // Author label constraints
            authorLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 15),
            authorLabel.topAnchor.constraint(equalTo: contentPreviewLabel.bottomAnchor, constant: 5),
            authorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // Date label constraints
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 10)
        ])
    }
    
    func configure(with post: Post) {
        titleLabel.text = post.postTitle
        
        // Truncate content for preview
        let content = post.postContent
        let maxLength = 100
        if content.count > maxLength {
            let index = content.index(content.startIndex, offsetBy: maxLength)
            contentPreviewLabel.text = content[..<index] + "..."
        } else {
            contentPreviewLabel.text = content
        }
        
        // Display author name
        if let parentName = post.parents?.first?.name {
            authorLabel.text = "By: \(parentName)"
        } else {
            authorLabel.text = "By: Unknown"
        }
        
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
}

// MARK: - PostDetailViewController
// This is a placeholder - you'll need to implement the real detail view based on your app's design
class PostDetailViewController: UIViewController {
    private let post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Post Detail"
        
        // Implement the post detail view based on your app's design
        // This would typically include the full post content, image,
        // comments, likes, etc.
        
        let label = UILabel()
        label.text = "Post details would be shown here"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
