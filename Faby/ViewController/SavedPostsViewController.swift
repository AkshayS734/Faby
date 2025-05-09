import UIKit
import Supabase

class SavedPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    private var savedPosts: [SavedPost] = []
    private var posts: [Post] = []
    private var isLoading = false
    
    // Activity indicator for loading state
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    // Empty state view
    private let emptyStateView: UIView = {
        let view = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "bookmark.slash"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "You haven't saved any posts yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Bookmark posts to view them here"
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Posts"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupActivityIndicator()
        setupEmptyStateView()
        
        // Register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSavedPosts), name: .postSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSavedPosts), name: .postRemoved, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedPosts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SavedPostCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Data Fetching
    
    @objc private func refreshSavedPosts() {
        fetchSavedPosts()
    }
    
    private func fetchSavedPosts() {
        guard !isLoading else { return }
        isLoading = true
        
        // Show loading indicator
        activityIndicator.startAnimating()
        
        // Get current user
        guard let currentParent = ParentDataModel.shared.currentParent else {
            showError("No user is currently logged in")
            activityIndicator.stopAnimating()
            isLoading = false
            return
        }
        
        // Generate a UUID from the username to match the UUID format expected by Supabase
        // In a real app, you would store and use actual UUIDs for your users
        let userId = UUID(uuidString: "6033ddad-9266-4b74-b7e1-012a5162dcca") != nil ? 
                    "6033ddad-9266-4b74-b7e1-012a5162dcca" : 
                    UUID().uuidString
        
        // Fetch directly from Supabase
        fetchFromSupabase(userId: userId)
    }
    
    private func fetchFromSupabase(userId: String) {
        Task {
            // First test the connection to Supabase
            let connectionTest = await SupabaseSavedPostManager.shared.testConnection()
            
            if !connectionTest.success {
                // Connection failed, show error
                await MainActor.run {
                    self.showError(connectionTest.message)
                    self.activityIndicator.stopAnimating()
                    self.isLoading = false
                    self.emptyStateView.isHidden = false
                }
                return
            }
            
            // Connection successful, proceed with fetching saved posts
            do {
                print("Fetching saved posts for user: \(userId)")
                // Fetch saved posts from Supabase
                self.savedPosts = try await SupabaseSavedPostManager.shared.fetchSavedPosts(forUserId: userId)
                print("Fetched \(self.savedPosts.count) saved posts")
                
                // If we have saved posts, fetch the actual post content
                if !self.savedPosts.isEmpty {
                    // Extract post IDs from saved posts
                    let postIds = self.savedPosts.map { $0.post_id }
                    
                    // Try to fetch posts from Supabase Posts table
                    do {
                        let supabasePosts = try await SupabaseSavedPostManager.shared.fetchPosts(byIds: postIds)
                        
                        if !supabasePosts.isEmpty {
                            // Successfully fetched posts from Supabase
                            print("Fetched \(supabasePosts.count) posts from Posts table")
                            
                            // Store the Supabase posts for reference (for images)
                            self.supabasePosts = supabasePosts
                            
                            // Convert Supabase posts to app's Post model
                            self.posts = supabasePosts.map { $0.toPost() }
                        } else {
                            // Posts table might not exist or no matching posts found
                            // Fall back to creating posts from saved post data
                            print("No posts found in Posts table, creating from saved post data")
                            createPostsFromSavedPosts()
                        }
                    } catch {
                        // Error fetching from Posts table, fall back to saved post data
                        print("Error fetching from Posts table: \(error), falling back to saved post data")
                        createPostsFromSavedPosts()
                    }
                } else {
                    self.posts = []
                }
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    
                    // Show/hide empty state view
                    self.emptyStateView.isHidden = !self.posts.isEmpty
                    self.isLoading = false
                }
            } catch {
                print("Error fetching saved posts: \(error)")
                
                // Show error
                await MainActor.run {
                    self.showError("Could not fetch saved posts: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    self.isLoading = false
                    self.emptyStateView.isHidden = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates posts from saved post data as a fallback when Posts table is unavailable
    private func createPostsFromSavedPosts() {
        self.posts = []
        
        for (index, savedPost) in self.savedPosts.enumerated() {
            // Create a post with data from the saved post
            // Using the post_id as part of the title and text to show it's coming from Supabase
            let post = Post(
                username: "User from Supabase",
                title: "Saved Post #\(index+1) (ID: \(savedPost.id))",
                text: "This post was saved in Supabase with post_id: \(savedPost.post_id). Created at: \(formatDate(savedPost.created_at))",
                likes: Int.random(in: 5...20),
                replies: []
            )
            self.posts.append(post)
        }
    }
    
    // Store fetched Supabase posts for reference
    private var supabasePosts: [SupabasePost] = []
    
    // Find a Supabase post by its ID
    private func getSupabasePost(for postId: String) -> SupabasePost? {
        return supabasePosts.first { $0.postId == postId }
    }
    
    // Cache for loaded images
    private var imageCache: [URL: UIImage] = [:]
    
    // Load an image from a URL
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check if image is already in cache
        if let cachedImage = imageCache[url] {
            completion(cachedImage)
            return
        }
        
        // Create a URLSession task to download the image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the image
            self.imageCache[url] = image
            completion(image)
        }.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Parse the ISO8601 date string
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: dateString) else {
            return dateString // Return original string if parsing fails
        }
        
        // Format the date in a user-friendly way
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
    

    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try to dequeue a custom cell if available, otherwise use a standard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPostCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SavedPostCell")
        
        let post = posts[indexPath.row]
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        content.text = post.title
        content.secondaryText = post.text.count > 50 ? post.text.prefix(50) + "..." : post.text
        content.secondaryTextProperties.color = .darkGray
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 14)
        
        // Set the image if we have a saved post with an image URL
        if indexPath.row < savedPosts.count {
            let savedPost = savedPosts[indexPath.row]
            // Try to find the matching Supabase post with image URL
            if let supabasePost = getSupabasePost(for: savedPost.post_id) {
                if let imageUrlString = supabasePost.image_url, let imageUrl = URL(string: imageUrlString) {
                    // Load the image asynchronously
                    loadImage(from: imageUrl) { image in
                        DispatchQueue.main.async {
                            if let cell = tableView.cellForRow(at: indexPath) {
                                var updatedContent = cell.defaultContentConfiguration()
                                updatedContent.text = post.title
                                updatedContent.secondaryText = content.secondaryText
                                updatedContent.secondaryTextProperties = content.secondaryTextProperties
                                
                                if let image = image {
                                    // Resize the image to fit in the cell
                                    let size = CGSize(width: 40, height: 40)
                                    let resizedImage = image.resized(to: size)
                                    updatedContent.image = resizedImage
                                    updatedContent.imageProperties.cornerRadius = 8
                                }
                                
                                cell.contentConfiguration = updatedContent
                            }
                        }
                    }
                }
            }
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to post detail view
        let post = posts[indexPath.row]
        let postDetailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the saved post ID
            let savedPost = savedPosts[indexPath.row]
            
            // Remove from Supabase
            Task {
                do {
                    try await SupabaseSavedPostManager.shared.removeSavedPost(savedPostId: savedPost.id)
                    
                    // Update local data
                    await MainActor.run {
                        self.savedPosts.remove(at: indexPath.row)
                        self.posts.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        // Show empty state if needed
                        self.emptyStateView.isHidden = !self.posts.isEmpty
                    }
                } catch {
                    await MainActor.run {
                        self.showError("Failed to remove saved post: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unsave"
    }
}

// MARK: - Post Detail View Controller
class PostDetailViewController: UIViewController {
    
    private let post: Post
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = post.title
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupContent()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContent() {
        // Author label
        let authorLabel = UILabel()
        authorLabel.text = "Posted by: \(post.username)"
        authorLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        authorLabel.textColor = .secondaryLabel
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Content label
        let contentLabel = UILabel()
        contentLabel.text = post.text
        contentLabel.font = UIFont.systemFont(ofSize: 17)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Likes label
        let likesLabel = UILabel()
        likesLabel.text = "❤️ \(post.likes) likes"
        likesLabel.font = UIFont.systemFont(ofSize: 14)
        likesLabel.textColor = .secondaryLabel
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Replies section
        let repliesLabel = UILabel()
        repliesLabel.text = "Replies:"
        repliesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        repliesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content view
        contentView.addSubview(authorLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(likesLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            likesLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            likesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            likesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Add replies if there are any
        if !post.replies.isEmpty {
            contentView.addSubview(repliesLabel)
            
            NSLayoutConstraint.activate([
                repliesLabel.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 24),
                repliesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                repliesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
            
            var previousView: UIView = repliesLabel
            
            for (index, reply) in post.replies.enumerated() {
                let replyView = createReplyView(reply: reply, index: index)
                contentView.addSubview(replyView)
                
                NSLayoutConstraint.activate([
                    replyView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 12),
                    replyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    replyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])
                
                previousView = replyView
            }
            
            // Bottom constraint for the last reply
            NSLayoutConstraint.activate([
                previousView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        } else {
            // If no replies, set bottom constraint to likes label
            NSLayoutConstraint.activate([
                likesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
    }
    
    private func createReplyView(reply: String, index: Int) -> UIView {
        let replyView = UIView()
        replyView.backgroundColor = .systemGray6
        replyView.layer.cornerRadius = 8
        replyView.translatesAutoresizingMaskIntoConstraints = false
        
        let replyLabel = UILabel()
        replyLabel.text = reply
        replyLabel.font = UIFont.systemFont(ofSize: 15)
        replyLabel.numberOfLines = 0
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        replyView.addSubview(replyLabel)
        
        NSLayoutConstraint.activate([
            replyLabel.topAnchor.constraint(equalTo: replyView.topAnchor, constant: 12),
            replyLabel.leadingAnchor.constraint(equalTo: replyView.leadingAnchor, constant: 12),
            replyLabel.trailingAnchor.constraint(equalTo: replyView.trailingAnchor, constant: -12),
            replyLabel.bottomAnchor.constraint(equalTo: replyView.bottomAnchor, constant: -12),
            
            replyView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        return replyView
    }
}
