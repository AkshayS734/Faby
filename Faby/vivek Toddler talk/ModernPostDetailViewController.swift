import UIKit

class ModernPostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewDelegate, PostCardCellDelegate {
    
    // MARK: - Properties
    var selectedTopicId: String?
    var topicName: String?
    var passedTitle: String?
    private var posts: [Post] = []
    private var likedPostIds: Set<String> = []
    private var isLoading = false {
        didSet {
            updateLoadingState()
        }
    }
    private var comments: [Comment] = [] {
        didSet {
            commentsTableView.reloadData()
            updateCommentsCountLabel()
        }
    }
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemGroupedBackground
        table.separatorStyle = .none
        table.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return table
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Comment Input View
    private lazy var commentsOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var commentInputView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Write a comment..."
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 18
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        return button
    }()
    
    private var keyboardHeight: CGFloat = 0
    private var commentInputBottomConstraint: NSLayoutConstraint?
    private var currentPost: Post?
    
    private lazy var commentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var commentsCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var overlayDismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(hideCommentInput), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        setupCommentsTableView()
        setupKeyboardObservers()
        fetchLikedPosts()
        fetchPosts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add main content views
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(commentsOverlayView)
        
        // Add subviews to comments overlay
        commentsOverlayView.addSubview(overlayDismissButton)
        commentsOverlayView.addSubview(commentsCountLabel)
        commentsOverlayView.addSubview(commentsTableView)
        commentsOverlayView.addSubview(commentInputView)
        
        // Add input view subviews
        commentInputView.addSubview(commentTextField)
        commentInputView.addSubview(sendButton)
        
        // Initialize bottom constraint
        commentInputBottomConstraint = commentInputView.bottomAnchor.constraint(equalTo: commentsOverlayView.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // Main table view (posts)
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Comments overlay
            commentsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            commentsOverlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            // Dismiss button
            overlayDismissButton.topAnchor.constraint(equalTo: commentsOverlayView.topAnchor, constant: 16),
            overlayDismissButton.trailingAnchor.constraint(equalTo: commentsOverlayView.trailingAnchor, constant: -16),
            overlayDismissButton.widthAnchor.constraint(equalToConstant: 32),
            overlayDismissButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Comments count label
            commentsCountLabel.topAnchor.constraint(equalTo: commentsOverlayView.topAnchor, constant: 20),
            commentsCountLabel.leadingAnchor.constraint(equalTo: commentsOverlayView.leadingAnchor, constant: 20),
            commentsCountLabel.trailingAnchor.constraint(equalTo: overlayDismissButton.leadingAnchor, constant: -8),
            
            // Comments table view
            commentsTableView.topAnchor.constraint(equalTo: commentsCountLabel.bottomAnchor, constant: 12),
            commentsTableView.leadingAnchor.constraint(equalTo: commentsOverlayView.leadingAnchor),
            commentsTableView.trailingAnchor.constraint(equalTo: commentsOverlayView.trailingAnchor),
            commentsTableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
            
            // Comment input view
            commentInputView.leadingAnchor.constraint(equalTo: commentsOverlayView.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: commentsOverlayView.trailingAnchor),
            commentInputView.heightAnchor.constraint(equalToConstant: 60),
            commentInputBottomConstraint!,
            
            // Comment text field
            commentTextField.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            commentTextField.heightAnchor.constraint(equalToConstant: 36),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Set initial state
        commentsOverlayView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        commentsOverlayView.isHidden = true
        
        // Style the views
        commentsTableView.backgroundColor = .clear
        commentsTableView.separatorStyle = .none
        
        commentInputView.backgroundColor = .systemBackground
        commentInputView.layer.shadowColor = UIColor.black.cgColor
        commentInputView.layer.shadowOpacity = 0.1
        commentInputView.layer.shadowOffset = CGSize(width: 0, height: -2)
        commentInputView.layer.shadowRadius = 4
        
        commentTextField.backgroundColor = .systemGray6
        commentTextField.layer.cornerRadius = 18
        commentTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        commentTextField.leftViewMode = .always
        commentTextField.placeholder = "Write a comment..."
        
        commentsCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        commentsCountLabel.textColor = .label
    }
    
    private func setupNavigationBar() {
        title = topicName
        navigationItem.largeTitleDisplayMode = .never
        
        let addPostButton = UIBarButtonItem(title: "Add Post",
                                          style: .plain,
                                          target: self,
                                          action: #selector(addPostButtonTapped))
        navigationItem.rightBarButtonItem = addPostButton
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCardCell.self, forCellReuseIdentifier: "PostCardCell")
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupCommentsTableView() {
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        commentsTableView.estimatedRowHeight = 100
        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.separatorStyle = .none
        commentsTableView.backgroundColor = .clear
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.commentInputBottomConstraint?.constant = -self.keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.commentInputBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleSendComment() {
        guard let commentText = commentTextField.text, !commentText.isEmpty,
              let post = currentPost,
              let userId = SupabaseManager.shared.userID else {
            return
        }
        
        SupabaseManager.shared.addComment(postId: post.postId, userId: userId, content: commentText) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.commentTextField.text = ""
                    self?.hideCommentInput()
                    // Refresh comments
                    self?.fetchComments()
                } else {
                    let alert = UIAlertController(title: "Error", message: "Failed to add comment. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showCommentInput(for post: Post) {
        print("📱 Showing comment input for post: \(post.postId)")
        currentPost = post
        
        // Reset transform and show overlay
        commentsOverlayView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        commentsOverlayView.isHidden = false
        view.layoutIfNeeded()
        
        // Animate the overlay sliding up
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.commentsOverlayView.transform = .identity
            self.tableView.alpha = 0.5  // Dim the background
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.commentTextField.becomeFirstResponder()
        }
        
        // Fetch comments for this post
        fetchComments()
    }
    
    @objc private func hideCommentInput() {
        print("📱 Hiding comment input")
        
        commentTextField.resignFirstResponder()
        
        // Animate the overlay sliding down
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            self.commentsOverlayView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
            self.tableView.alpha = 1.0  // Restore background
        } completion: { _ in
            self.commentsOverlayView.isHidden = true
            self.currentPost = nil
        }
    }
    
    private func fetchComments() {
        guard let post = currentPost else {
            print("❌ No current post set for fetching comments")
            return
        }
        
        print("🔄 Fetching comments for post: \(post.postId)")
        SupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching comments: \(error.localizedDescription)")
                return
            }
            
            if let comments = comments {
                print("✅ Fetched \(comments.count) comments")
                DispatchQueue.main.async {
                    self.comments = comments
                    self.commentsTableView.reloadData()
                    self.updateCommentsCountLabel()
                }
            }
        }
    }
    
    // MARK: - Data Loading
    private func fetchLikedPosts() {
        print("📢 fetchLikedPosts() called")
        SupabaseManager.shared.fetchLikedPostIds { [weak self] likedPostIds, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching liked posts: \(error.localizedDescription)")
                return
            }
            
            self.likedPostIds = likedPostIds
            print("✅ Loaded \(likedPostIds.count) liked posts")
            
            // Reload the table view to update the like states
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchPosts() {
        guard let topicId = selectedTopicId else { return }
        
        isLoading = true
        
        guard let topicUUID = UUID(uuidString: topicId) else {
            showError(message: "Invalid topic ID format")
            isLoading = false
            return
        }
        
        SupabaseManager.shared.fetchPosts(for: topicUUID) { [weak self] posts, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                    self.showError(message: "Failed to load posts")
                    return
                }
                
                if var posts = posts {
                    // Sort posts by creation date, newest first
                    posts.sort { post1, post2 in
                        guard let createdAt1 = post1.createdAt,
                              let createdAt2 = post2.createdAt,
                              let date1 = DateFormatter.iso8601Full.date(from: createdAt1),
                              let date2 = DateFormatter.iso8601Full.date(from: createdAt2) else {
                            return false
                        }
                        return date1 > date2
                    }

                    
                    self.posts = posts
                    self.tableView.reloadData()
                } else {
                    self.showError(message: "No posts found")
                }
            }
        }
    }
    
    private func updateLoadingState() {
        if isLoading {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return posts.count
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCardCell", for: indexPath) as! PostCardCell
            let post = posts[indexPath.row]
            cell.delegate = self
            let isLiked = likedPostIds.contains(post.postId)
            cell.configure(with: post, isLiked: isLiked)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.configure(with: comment, isLiked: false)
            return cell
        }
    }
    
    // MARK: - Actions
    @objc private func addPostButtonTapped() {
        let storyboard = UIStoryboard(name: "ToddlerTalk", bundle: nil)
        if let postVC = storyboard.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController {
            postVC.selectedCategory = selectedTopicId
            postVC.topicName = topicName
            postVC.delegate = self
            navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    @objc private func refreshPosts() {
        fetchLikedPosts()
        fetchPosts()
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - PostViewDelegate
    func didPostComment(_ comment: Post) {
        // Insert the new post at the top of the list
        posts.insert(comment, at: 0)
        
        // Reload the table view with animation
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            // Scroll to the top to show the new post
            if !self.posts.isEmpty {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    // MARK: - PostCardCellDelegate
    func didTapComment(for post: Post) {
        showCommentInput(for: post)
    }
    
    func didTapMore(for post: Post) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "Share Post", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.sharePost(post, from: self)
        }

        
        let saveAction = UIAlertAction(title: "Save Post", style: .default) { [weak self] _ in
            self?.savePost(post)
        }
        
        let reportAction = UIAlertAction(title: "Report Post", style: .destructive) { [weak self] _ in
            self?.reportPost(post)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(shareAction)
        alertController.addAction(saveAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func didTapSave(for post: Post) {
        savePost(post)
    }
    
    func didTapReport(for post: Post) {
        reportPost(post)
    }
    

    func sharePost(_ post: Post, from viewController: UIViewController) {
        var items: [Any] = [post.postTitle, post.postContent]

        if let imageUrlString = post.image_url, let imageUrl = URL(string: imageUrlString) {
            // Load image asynchronously
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    items.append(image)
                }

                DispatchQueue.main.async {
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
            }.resume()
        } else {
            // No image, share text only
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
    }


    
    private func savePost(_ post: Post) {
        // TODO: Implement save post functionality
        let alert = UIAlertController(title: "Post Saved", message: "This post has been saved to your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func reportPost(_ post: Post) {
        let alert = UIAlertController(title: "Report Post",
                                    message: "Are you sure you want to report this post?",
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // TODO: Implement report post functionality
            let confirmAlert = UIAlertController(title: "Thank You",
                                               message: "Your report has been submitted for review",
                                               preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirmAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateCommentsCountLabel() {
        let count = comments.count
        commentsCountLabel.text = "\(count) \(count == 1 ? "Comment" : "Comments")"
        print("📊 Updated comments count: \(count)")
    }
}

// Add DateFormatter extension if not already present
private extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
