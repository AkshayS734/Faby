import UIKit
import Supabase

class UserPostListViewController: UIViewController {
    
    // MARK: - Properties
    private var posts: [Post] = []
    private var allPosts: [Post] = [] // Store all posts for filtering
    private var topics: [Topics] = [] // Store all topics
    private var selectedTopicId: String? // Track selected topic
    private let refreshControl = UIRefreshControl()
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 200
        return table
    }()
    
    private let categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.image = UIImage(systemName: "doc.text.image")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        )
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No posts yet\nStart sharing your thoughts!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCategoryCollectionView()
        setupEmptyState()
        setupNavigationBar()
        
        // Add initial "All Posts" topic
        let allPostsTopic = Topics(id: "all", title: "All Posts", imageView: "")
        self.topics = [allPostsTopic]
        self.categoryCollectionView.reloadData()
        
        // Then fetch other topics
        fetchTopics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Collection view frame after layout: \(categoryCollectionView.frame)")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(categoryCollectionView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            // Category Collection View
            categoryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupCategoryCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoryCollectionView.backgroundColor = .systemBackground
        categoryCollectionView.showsHorizontalScrollIndicator = false
        
        // Add subtle bottom shadow
        categoryCollectionView.layer.shadowColor = UIColor.black.cgColor
        categoryCollectionView.layer.shadowOpacity = 0.1
        categoryCollectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        categoryCollectionView.layer.shadowRadius = 4
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyPostCardCell.self, forCellReuseIdentifier: "MyPostCardCell")
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupEmptyState() {
        emptyStateView.isHidden = false
    }
    
    private func setupNavigationBar() {
        title = "My Posts"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Data Fetching
    private func fetchTopics() {
        PostsSupabaseManager.shared.fetchTopics { [weak self] topics, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let topics = topics {
                    // Keep "All Posts" as first item and add other topics
                    var updatedTopics = self.topics // Keep existing "All Posts"
                    updatedTopics.append(contentsOf: topics)
                    self.topics = updatedTopics
                    
                    print("📱 Topics loaded: \(self.topics.count)")
                    self.categoryCollectionView.reloadData()
                    
                    // Debug print for cells
                    print("Number of items in collection view: \(self.categoryCollectionView.numberOfItems(inSection: 0))")
                }
            }
        }
    }
    
    private func fetchPosts() {
        print("🔍 Starting to fetch posts...")
        
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let userId = session.user.id
                
                print("✅ Found current user with ID: \(userId)")
                
                refreshControl.beginRefreshing()
                
                PostsSupabaseManager.shared.fetchUserPosts(for: userId) { [weak self] posts, error in
                    DispatchQueue.main.async {
                        self?.refreshControl.endRefreshing()
                        
                        if let error = error {
                            print("❌ Error fetching posts: \(error.localizedDescription)")
                            self?.showError(message: error.localizedDescription)
                            self?.emptyStateView.isHidden = false
                        } else {
                            print("✅ Successfully fetched \(posts?.count ?? 0) posts")
                            self?.allPosts = posts ?? []
                            self?.filterPosts()
                            
                            // Update empty state visibility
                            let hasPosts = !(self?.posts.isEmpty ?? true)
                            self?.emptyStateView.isHidden = hasPosts
                            self?.tableView.isHidden = !hasPosts
                            
                            if hasPosts {
                                self?.tableView.reloadData()
                            }
                        }
                    }
                }
            } catch {
                print("❌ Error getting current session: \(error.localizedDescription)")
                showError(message: "Please login to view your posts")
                emptyStateView.isHidden = false
            }
        }
    }
    
    private func filterPosts() {
        if let selectedTopicId = selectedTopicId, selectedTopicId != "all" {
            posts = allPosts.filter { $0.topicId == selectedTopicId }
        } else {
            posts = allPosts
        }
        posts.sort { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        tableView.reloadData()
        
        // Update empty state
        let hasPosts = !posts.isEmpty
        emptyStateView.isHidden = hasPosts
        tableView.isHidden = !hasPosts
    }
    
    @objc private func handleRefresh() {
        fetchPosts()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func deletePost(_ post: Post) {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Show loading indicator
            let loadingAlert = UIAlertController(
                title: "Deleting Post",
                message: "Please wait...",
                preferredStyle: .alert
            )
            self.present(loadingAlert, animated: true)
            
            // Call Supabase manager to delete post
            PostsSupabaseManager.shared.deletePost(postId: post.postId) { success, error in
                DispatchQueue.main.async {
                    // Dismiss loading indicator
                    loadingAlert.dismiss(animated: true) {
                        if success {
                            // Provide success feedback
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                            
                            // Show success toast
                            let toast = UIAlertController(
                                title: "Post Deleted",
                                message: "Your post has been successfully deleted",
                                preferredStyle: .alert
                            )
                            self.present(toast, animated: true)
                            
                            // Dismiss toast after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                toast.dismiss(animated: true) {
                                    // Refresh posts after deletion
                                    self.fetchPosts()
                                }
                            }
                        } else {
                            // Show error message
                            let errorAlert = UIAlertController(
                                title: "Error",
                                message: error?.localizedDescription ?? "Failed to delete post",
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension UserPostListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCardCell", for: indexPath) as! MyPostCardCell
        let post = posts[indexPath.row]
        cell.configure(with: post, isLiked: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        
        // Navigate to post details view controller
        let detailsVC = PostDetailsViewController(post: post)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension UserPostListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("📱 Number of topics: \(topics.count)")
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let topic = topics[indexPath.item]
        cell.configure(with: topic.title, isSelected: topic.id == (selectedTopicId ?? "all"))
        print("📱 Configuring cell for topic: \(topic.title)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topic = topics[indexPath.item]
        let width = topic.title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]).width + 48
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topic = topics[indexPath.item]
        selectedTopicId = topic.id
        collectionView.reloadData()
        filterPosts()
    }
}

// MARK: - PostCardCellDelegate
extension UserPostListViewController: PostCardCellDelegate {
    func didTapLike(for post: Post, isLiked: Bool) {
        
    }
    
    func didTapComment(for post: Post) {
        let storyboard = UIStoryboard(name: "ToddlerTalk", bundle: nil)
        if let commentVC = storyboard.instantiateViewController(withIdentifier: "ModernPostDetailViewController") as? ModernPostDetailViewController {
            commentVC.selectedTopicId = post.topicId
            commentVC.passedTitle = post.postTitle
            commentVC.topicName = post.postTitle
            navigationController?.pushViewController(commentVC, animated: true)
        }
    }
    
    func didTapMore(for post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.sharePost(post)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePost(post)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func didTapSave(for post: Post) {
        // Implement save functionality
        PostsSupabaseManager.shared.isPostSaved(postId: post.postId) { [weak self] isSaved, error in
            guard let self = self else { return }
            
            if isSaved {
                // Post is already saved, ask if they want to unsave
                let alert = UIAlertController(title: "Post Already Saved", 
                                             message: "Do you want to remove this post from your saved collection?", 
                                             preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
                    PostsSupabaseManager.shared.unsavePost(postId: post.postId) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                let feedback = UINotificationFeedbackGenerator()
                                feedback.notificationOccurred(.success)
                                
                                let toast = UIAlertController(title: "Post Removed", message: "Post has been removed from your saved collection", preferredStyle: .alert)
                                self.present(toast, animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    toast.dismiss(animated: true)
                                }
                            } else {
                                self.showError(message: "Failed to remove post from your saved collection")
                            }
                        }
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
                
            } else {
                // Save the post
                PostsSupabaseManager.shared.savePost(postId: post.postId) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            let feedback = UINotificationFeedbackGenerator()
                            feedback.notificationOccurred(.success)
                            
                            let toast = UIAlertController(title: "Post Saved", message: "Post has been saved to your collection", preferredStyle: .alert)
                            self.present(toast, animated: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                toast.dismiss(animated: true)
                            }
                        } else {
                            self.showError(message: "Failed to save post")
                        }
                    }
                }
            }
        }
    }
    
    func didTapReport(for post: Post) {
        // No need for report in own posts
    }
    
    func didTapPostForDetails(_ post: Post) {
        // Navigate to post details view controller
        let detailsVC = PostDetailsViewController(post: post)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    func sharePost(_ post: Post, from viewController: UIViewController) {
        var items: [Any] = []
        
        // Create post title with content
        let postText = "\(post.postTitle)\n\n\(post.postContent)"
        items.append(postText)
        
        // Add deep link or web link for sharing
        if let deepLink = PostsSupabaseManager.shared.generatePostDeepLink(for: post) {
            items.append(deepLink)
        } else if let webLink = PostsSupabaseManager.shared.generatePostWebLink(for: post) {
            items.append(webLink)
        }
        
        // Add image if available
        if let imageUrlString = post.image_url, let imageUrl = URL(string: imageUrlString) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    items.append(image)
                }
                
                DispatchQueue.main.async {
                    self.presentShareSheet(items: items, from: viewController)
                }
            }.resume()
        } else {
            // No image, share text and link only
            self.presentShareSheet(items: items, from: viewController)
        }
    }
    
    private func presentShareSheet(items: [Any], from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0,
                                       height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    private func sharePost(_ post: Post) {
        // Keep this for backward compatibility with didTapMore
        sharePost(post, from: self)
    }
}

// MARK: - CategoryCell
class CategoryCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 18
        clipsToBounds = true
        
        // Add border
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        configure(with: "", isSelected: false)
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        
        if isSelected {
            backgroundColor = .systemBlue
            titleLabel.textColor = .white
            layer.borderWidth = 0
        } else {
            backgroundColor = .systemBackground
            titleLabel.textColor = .secondaryLabel
            layer.borderWidth = 1
            layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
}
