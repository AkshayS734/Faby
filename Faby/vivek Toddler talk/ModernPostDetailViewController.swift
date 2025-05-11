import UIKit

class ModernPostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewDelegate, PostCardCellDelegate, CommentCellDelegate {
    
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
    
    // Properties for reply functionality
    private var replyingToComment: Comment?
    private var isInReplyMode: Bool = false {
        didSet {
            updateCommentTextFieldPlaceholder()
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
    
    // Replace the entire reply indicator implementation with a simpler approach
    private lazy var replyIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.isHidden = true
        
        // Ensure proper height
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Add top border for visibility
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
        border.backgroundColor = UIColor.systemGray4.cgColor
        view.layer.addSublayer(border)
        
        return view
    }()
    
    private lazy var replyToLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.text = "Replying to"
        return label
    }()
    
    private lazy var replyToNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    // Remove the standalone reply button and replace with an in-textfield cross button
    private lazy var cancelReplyButton: UIButton = {
        // Configure the button with SF Symbol
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let xImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        
        button.setImage(xImage, for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(simpleCancelReply), for: .touchUpInside)
        
        // Size it appropriately
        button.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
        
        return button
    }()
    
    // Add drag handle for fullscreen expansion
    private lazy var dragHandleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
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
        view.layoutMargins = .zero
        return view
    }()
    
    // Add spacer view to fill gap between keyboard and input
    private lazy var keyboardSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    // Update the comment text field to include a custom right view for the cancel button
    private lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Write a comment..."
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        
        // Set left padding
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        
        // Create a right view container - empty by default
        let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        textField.rightView = rightViewContainer
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
    
    private var commentsOverlayHeightConstraint: NSLayoutConstraint?
    private var isCommentsFullscreen = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        setupCommentsTableView()
        setupKeyboardObservers()
        setupTextFieldTapGesture()
        fetchLikedPosts()
        fetchPosts()
        
        // Add a long press gesture to navigation bar to run debug tests
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Debug the cancel button setup
        print("📱 Cancel button initialized: \(cancelReplyButton != nil ? "YES" : "NO")")
        print("📱 Cancel button has actions: \(cancelReplyButton.actions(forTarget: self, forControlEvent: .touchUpInside)?.count ?? 0)")
        
        // Run SavedPosts debugging to diagnose the issue
        #if DEBUG
        debugSavedPostsFunctionality()
        #endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Debug layout for cancel button
        print("📐 Cancel button frame after layout: \(cancelReplyButton.frame)")
        print("📐 Cancel button is inside: \(cancelReplyButton.superview?.description ?? "NO SUPERVIEW")")
        print("📐 Cancel button is hidden: \(cancelReplyButton.isHidden)")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add main content views
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(commentsOverlayView)
        view.addSubview(keyboardSpacerView)
        
        // Add subviews to comments overlay
        commentsOverlayView.addSubview(dragHandleView)
        commentsOverlayView.addSubview(overlayDismissButton)
        commentsOverlayView.addSubview(commentsCountLabel)
        commentsOverlayView.addSubview(commentsTableView)
        commentsOverlayView.addSubview(commentInputView)
        
        // Add reply indicator view
        commentInputView.addSubview(replyIndicatorView)
        replyIndicatorView.addSubview(replyToLabel)
        replyIndicatorView.addSubview(replyToNameLabel)
        
        // Add input view subviews
        commentInputView.addSubview(commentTextField)
        commentInputView.addSubview(sendButton)
        
        // Initialize bottom constraint
        commentInputBottomConstraint = commentInputView.bottomAnchor.constraint(equalTo: commentsOverlayView.safeAreaLayoutGuide.bottomAnchor)
        commentsOverlayHeightConstraint = commentsOverlayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        
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
            commentsOverlayHeightConstraint!,
            
            // Drag handle
            dragHandleView.topAnchor.constraint(equalTo: commentsOverlayView.topAnchor, constant: 8),
            dragHandleView.centerXAnchor.constraint(equalTo: commentsOverlayView.centerXAnchor),
            dragHandleView.widthAnchor.constraint(equalToConstant: 40),
            dragHandleView.heightAnchor.constraint(equalToConstant: 5),
            
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
            commentInputView.heightAnchor.constraint(equalToConstant: 50),
            commentInputBottomConstraint!,
            
            // Reply indicator view
            replyIndicatorView.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 8),
            replyIndicatorView.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -8),
            replyIndicatorView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -4),
            replyIndicatorView.heightAnchor.constraint(equalToConstant: 28),
            
            // Reply to label
            replyToLabel.leadingAnchor.constraint(equalTo: replyIndicatorView.leadingAnchor, constant: 12),
            replyToLabel.centerYAnchor.constraint(equalTo: replyIndicatorView.centerYAnchor),
            
            // Reply to name label - with safe constraint
            replyToNameLabel.leadingAnchor.constraint(equalTo: replyToLabel.trailingAnchor, constant: 4),
            replyToNameLabel.centerYAnchor.constraint(equalTo: replyIndicatorView.centerYAnchor),
            replyToNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: replyIndicatorView.trailingAnchor, constant: -50),
            
            // Comment text field
            commentTextField.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            commentTextField.heightAnchor.constraint(equalToConstant: 32),
            
            // Send button
            sendButton.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Keyboard spacer view
            keyboardSpacerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardSpacerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardSpacerView.topAnchor.constraint(equalTo: commentsOverlayView.bottomAnchor),
            keyboardSpacerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        
        commentsCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        commentsCountLabel.textColor = .label
        
        // Add pan gesture to drag handle for expanding/collapsing comments view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture(_:)))
        dragHandleView.addGestureRecognizer(panGesture)
        dragHandleView.isUserInteractionEnabled = true
        
        // Add tap gesture to expand/collapse
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDragHandleTap(_:)))
        dragHandleView.addGestureRecognizer(tapGesture)
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
        
        // Calculate the safe area bottom inset
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        
        // Only show the keyboard spacer when needed
        keyboardSpacerView.isHidden = false
        
        // Get animation duration from notification
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        UIView.animate(withDuration: duration) {
            // Use a more aggressive adjustment to minimize the gap
            // Subtracting both safe area and a small additional offset
            self.commentInputBottomConstraint?.constant = -(self.keyboardHeight - safeAreaBottomInset) + 5
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardSpacerView.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.commentInputBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleDragGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // Limit drag to only moving up/down
            commentsOverlayHeightConstraint?.constant = translation.y
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            let shouldExpand = velocity.y < 0 || (translation.y < 0 && abs(translation.y) > view.bounds.height * 0.1)
            
            toggleCommentsFullscreen(expand: shouldExpand)
            
        default:
            break
        }
    }
    
    @objc private func handleDragHandleTap(_ gesture: UITapGestureRecognizer) {
        toggleCommentsFullscreen(expand: !isCommentsFullscreen)
    }
    
    private func toggleCommentsFullscreen(expand: Bool) {
        isCommentsFullscreen = expand
        
        // First deactivate any conflicting constraints
        if expand {
            commentsOverlayHeightConstraint?.isActive = false
            
            // Make sure any existing top constraints are removed
            for constraint in view.constraints {
                if let firstItem = constraint.firstItem as? NSObject,
                   firstItem == commentsOverlayView,
                   constraint.firstAttribute == .top {
                    constraint.isActive = false
                }
            }
            
            // Add top constraint to expand to full screen
            let topConstraint = commentsOverlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            topConstraint.isActive = true
        } else {
            // Remove any top constraints first
            for constraint in view.constraints {
                if let firstItem = constraint.firstItem as? NSObject,
                   firstItem == commentsOverlayView,
                   constraint.firstAttribute == .top {
                    constraint.isActive = false
                }
            }
            
            // Reactivate height constraint
            commentsOverlayHeightConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleSendComment() {
        guard let commentText = commentTextField.text, !commentText.isEmpty,
              let post = currentPost,
              let userId = SupabaseManager.shared.userID else {
            return
        }
        
        if isInReplyMode, let replyToComment = replyingToComment, let commentId = replyToComment.commentId {
            // We're replying to a specific comment
            SupabaseManager.shared.addCommentReply(
                commentId: commentId,
                postId: post.postId,
                userId: userId,
                content: commentText
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.commentTextField.text = ""
                        self?.simpleCancelReply() // Use new simple cancel method
                        // Refresh comments
                        self?.fetchComments()
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Failed to add reply. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        } else {
            // Regular comment (not a reply)
            SupabaseManager.shared.addComment(postId: post.postId, userId: userId, content: commentText) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.commentTextField.text = ""
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
    }
    
    private func showCommentInput(for post: Post) {
        print("📱 Showing comment input for post: \(post.postId)")
        currentPost = post
        
        // Reset transform and show overlay
        commentsOverlayView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        commentsOverlayView.isHidden = false
        isCommentsFullscreen = false
        
        // Make sure we reset to default height by removing any top constraints
        for constraint in view.constraints {
            if let firstItem = constraint.firstItem as? NSObject,
               firstItem == commentsOverlayView,
               constraint.firstAttribute == .top {
                constraint.isActive = false
            }
        }
        
        // Activate the height constraint for partial view (not fullscreen)
        commentsOverlayHeightConstraint?.isActive = true
        
        view.layoutIfNeeded()
        
        // Animate the overlay sliding up
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.commentsOverlayView.transform = .identity
            self.tableView.alpha = 0.5  // Dim the background
            self.view.layoutIfNeeded()
        } completion: { _ in
            // Don't automatically focus the text field - wait for tap
            // self.commentTextField.becomeFirstResponder()
            
            print("📱 Comment input view displayed (without keyboard)")
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
            let comment = comments[indexPath.row]
            
            // Configure the cell based on whether it's a reply or loading indicator
            if comment.isLoadingIndicator == true {
                // Create a simple loading cell
                let loadingCell = UITableViewCell()
                let indicator = UIActivityIndicatorView(style: .medium)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.startAnimating()
                
                loadingCell.contentView.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: loadingCell.contentView.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: loadingCell.contentView.centerYAnchor),
                    indicator.topAnchor.constraint(equalTo: loadingCell.contentView.topAnchor, constant: 8),
                    indicator.bottomAnchor.constraint(equalTo: loadingCell.contentView.bottomAnchor, constant: -8)
                ])
                
                // No visual indicators - just clean indentation
                loadingCell.indentationLevel = 4
                loadingCell.backgroundColor = .systemBackground
                loadingCell.selectionStyle = .none
                
                return loadingCell
            } else if comment.isEmptyState == true {
                // Create a simple empty state cell
                let emptyCell = UITableViewCell()
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "No replies yet"
                label.textColor = .secondaryLabel
                label.font = UIFont.italicSystemFont(ofSize: 14)
                label.textAlignment = .left
                
                emptyCell.contentView.addSubview(label)
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: emptyCell.contentView.leadingAnchor, constant: 32), // More indentation for cleaner look
                    label.trailingAnchor.constraint(equalTo: emptyCell.contentView.trailingAnchor, constant: -16),
                    label.topAnchor.constraint(equalTo: emptyCell.contentView.topAnchor, constant: 8),
                    label.bottomAnchor.constraint(equalTo: emptyCell.contentView.bottomAnchor, constant: -8)
                ])
                
                // Clean indentation without visual separators
                emptyCell.indentationLevel = 4
                emptyCell.backgroundColor = .systemBackground
                emptyCell.selectionStyle = .none
                
                return emptyCell
            } else {
                // Regular comment or reply
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
                cell.delegate = self
                
                // Check if the user has liked this comment
                if let commentId = comment.commentId?.description, let userId = SupabaseManager.shared.userID {
                    SupabaseManager.shared.checkIfUserLikedComment(commentId: commentId, userId: userId) { isLiked, _ in
                        DispatchQueue.main.async {
                            cell.configure(with: comment, isLiked: isLiked)
                        }
                    }
                } else {
                    cell.configure(with: comment, isLiked: false)
                }
                
                return cell
            }
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
    
    func didTapPostForDetails(_ post: Post) {
        // Create and present the post details view controller
        let detailsVC = PostDetailsViewController(post: post)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    // Implement optional sharePost method for direct sharing
    func sharePost(_ post: Post, from viewController: UIViewController) {
        var items: [Any] = []
        
        // Create post title with content
        let postText = "\(post.postTitle)\n\n\(post.postContent)"
        items.append(postText)
        
        // Add deep link or web link for sharing
        if let deepLink = SupabaseManager.shared.generatePostDeepLink(for: post) {
            items.append(deepLink)
        } else if let webLink = SupabaseManager.shared.generatePostWebLink(for: post) {
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
    
    func didTapSave(for post: Post) {
        savePost(post)
    }
    
    func didTapReport(for post: Post) {
        reportPost(post)
    }
    
    // Add empty implementation for didTapMore since we're handling actions directly now
    func didTapMore(for post: Post) {
        // This is required by the protocol but no longer used
        // All actions are now handled directly by the context menu
    }
    
    private func savePost(_ post: Post) {
        SupabaseManager.shared.isPostSaved(postId: post.postId) { [weak self] isSaved, error in
            guard let self = self else { return }
            
            if isSaved {
                // Post is already saved, ask if they want to unsave
                let alert = UIAlertController(title: "Post Already Saved", 
                                             message: "Do you want to remove this post from your saved collection?", 
                                             preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
                    SupabaseManager.shared.unsavePost(postId: post.postId) { success, error in
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
                SupabaseManager.shared.savePost(postId: post.postId) { success, error in
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
    
    // MARK: - CommentCellDelegate methods
    func didTapReplyButton(for comment: Comment) {
        print("🗣️ Reply button tapped for comment: \(comment.content)")
        startReplyToComment(comment)
    }
    
    func didTapViewReplies(for comment: Comment) {
        print("🔍 View replies tapped for comment: \(comment.content)")
        print("🔍 Comment ID: \(comment.commentId ?? -1)")
        
        guard let commentId = comment.commentId else {
            print("❌ ERROR: Comment has no ID, cannot show replies")
            let alert = UIAlertController(
                title: "Error",
                message: "Cannot load replies for this comment",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        guard let postId = currentPost?.postId else {
            print("❌ ERROR: Cannot show replies - no current post")
            return
        }
        
        // DEBUGGING - Print all comments currently displayed to help understand the state
        print("📊 Current comments in tableView: \(comments.count)")
        for (index, comment) in comments.enumerated() {
            print("  \(index): ID=\(comment.commentId ?? -1), Content=\(comment.content.prefix(20))...")
        }
        
        // Find the index of the comment in the array
        if let commentIndex = comments.firstIndex(where: { $0.commentId == commentId }) {
            print("✅ Found comment at index \(commentIndex)")
            
            // Check if comment already has expanded replies
            let isExpanded = comments[commentIndex].isRepliesExpanded ?? false
            print("📊 Comment expanded state: \(isExpanded ? "EXPANDED" : "COLLAPSED")")
            
            if isExpanded {
                // Collapse the replies
                print("📱 Collapsing replies for comment at index \(commentIndex)")
                
                // Remove all replies from the comment array
                comments = comments.filter { comment in
                    // Keep the comment itself and all non-replies
                    if comment.commentId == commentId { return true }
                    if comment.isReply != true { return true }
                    if comment.replyToCommentId != commentId { return true }
                    return false // Remove replies to this comment
                }
                
                // Mark comment as collapsed
                comments[commentIndex].isRepliesExpanded = false
                
                // Reload the table
                commentsTableView.reloadData()
            } else {
                // Expand to show replies
                print("📱 Expanding replies for comment at index \(commentIndex)")
                
                // Mark comment as expanded
                comments[commentIndex].isRepliesExpanded = true
                
                // Show loading indicator underneath comment
                let loadingComment = Comment(
                    commentId: nil,
                    content: "Loading replies...",
                    parentId: nil,
                    parentName: nil,
                    postId: postId,
                    createdAt: nil,
                    isLoadingIndicator: true,
                    replyToCommentId: commentId
                )
                
                // Insert loading indicator right after the comment
                if commentIndex + 1 <= comments.count {
                    comments.insert(loadingComment, at: commentIndex + 1)
                    commentsTableView.reloadData()
                }
                
                print("🔄 Sending API request to fetch replies for comment ID: \(commentId)")
                
                // Fetch replies
                SupabaseManager.shared.fetchRepliesForComment(commentId: commentId) { [weak self] replies, error in
                    guard let self = self else { return }
                    
                    print("🔄 Reply fetch callback received")
                    
                    DispatchQueue.main.async {
                        // Remove loading indicator
                        print("🔄 Removing loading indicators...")
                        self.comments = self.comments.filter { !($0.isLoadingIndicator == true) }
                        
                        if let error = error {
                            print("❌ ERROR: Failed to load replies: \(error.localizedDescription)")
                            self.commentsTableView.reloadData()
                            return
                        }
                        
                        if let replies = replies {
                            print("✅ Loaded \(replies.count) replies")
                            
                            if !replies.isEmpty {
                                // Convert replies to Comment objects and insert them after the comment
                                var index = commentIndex + 1
                                for reply in replies {
                                    print("🔄 Processing reply: ID=\(reply.replyId ?? -1), Content=\(reply.replyContent.prefix(20))...")
                                    
                                    let replyComment = Comment(
                                        commentId: reply.replyId,
                                        content: reply.replyContent,
                                        parentId: reply.userId,
                                        parentName: reply.parentName,
                                        postId: postId,
                                        createdAt: reply.createdAt,
                                        isReply: true,
                                        replyToCommentId: commentId
                                    )
                                    
                                    if index <= self.comments.count {
                                        self.comments.insert(replyComment, at: index)
                                        index += 1
                                    } else {
                                        self.comments.append(replyComment)
                                    }
                                }
                            } else {
                                print("ℹ️ No replies found for this comment")
                                
                                // Show an empty state
                                let emptyReply = Comment(
                                    commentId: nil,
                                    content: "No replies yet",
                                    parentId: nil,
                                    parentName: nil,
                                    postId: postId,
                                    createdAt: nil,
                                    isEmptyState: true,
                                    replyToCommentId: commentId
                                )
                                
                                if commentIndex + 1 <= self.comments.count {
                                    self.comments.insert(emptyReply, at: commentIndex + 1)
                                }
                            }
                            
                            print("🔄 Reloading table with \(self.comments.count) comments (including replies)")
                            // Reload the table
                            self.commentsTableView.reloadData()
                            
                            // Scroll to show the replies
                            if let originalCommentCell = self.commentsTableView.cellForRow(at: IndexPath(row: commentIndex, section: 0)) {
                                self.commentsTableView.scrollRectToVisible(originalCommentCell.frame, animated: true)
                            }
                        } else {
                            print("❌ ERROR: Replies data is nil")
                            self.commentsTableView.reloadData()
                        }
                    }
                }
            }
        } else {
            print("❌ ERROR: Could not find comment with ID \(commentId) in the comments array")
        }
    }
    
    func didTapMore(for comment: Comment) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report Comment", style: .destructive) { [weak self] _ in
            self?.didTapReport(for: comment)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func didTapReport(for comment: Comment) {
        let alert = UIAlertController(title: "Report Comment",
                                    message: "Are you sure you want to report this comment?",
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // TODO: Implement report comment functionality
            let confirmAlert = UIAlertController(title: "Thank You",
                                               message: "Your report has been submitted for review",
                                               preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirmAlert, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // Add missing method to conform to CommentCellDelegate
    func didTapLikeButton(for comment: Comment) {
        guard let commentId = comment.commentId?.description else {
            print("❌ Error: Comment ID is missing")
            return
        }
        
        guard let userId = SupabaseManager.shared.userID else {
            print("❌ Error: User not logged in")
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please log in to like comments",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Check if already liked
        SupabaseManager.shared.checkIfUserLikedComment(commentId: commentId, userId: userId) { [weak self] isLiked, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error checking like status: \(error.localizedDescription)")
                return
            }
            
            if isLiked {
                // Unlike comment
                SupabaseManager.shared.removeCommentLike(commentId: commentId, userId: userId) { success, error in
                    if success {
                        print("✅ Successfully unliked comment")
                        
                        // Refresh comments to update UI
                        self.fetchComments()
                    } else if let error = error {
                        print("❌ Error unliking comment: \(error.localizedDescription)")
                    }
                }
            } else {
                // Like comment
                SupabaseManager.shared.addCommentLike(commentId: commentId, userId: userId) { success, error in
                    if success {
                        print("✅ Successfully liked comment")
                        
                        // Refresh comments to update UI
                        self.fetchComments()
                    } else if let error = error {
                        print("❌ Error liking comment: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Reply functionality
    @objc private func simpleCancelReply() {
        print("🔴🔴🔴 CANCEL BUTTON TAPPED - RIGHT VIEW VERSION 🔴🔴🔴")
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Clear all reply state
        isInReplyMode = false
        replyingToComment = nil
        
        // Update text field right view
        updateTextFieldForReplyMode(isReplying: false)
        
        // Hide the reply indicator
        replyIndicatorView.isHidden = true
        
        // Clear text fields
        commentTextField.text = ""
        replyToNameLabel.text = ""
        
        // Reset placeholder
        commentTextField.placeholder = "Write a comment..."
        
        print("✅✅✅ COMPLETED CANCEL REPLY ✅✅✅")
    }
    
    // Update the startReplyToComment method
    private func startReplyToComment(_ comment: Comment) {
        print("📝 Starting reply to comment: \(comment.content)")
        
        // Store the comment we're replying to
        replyingToComment = comment
        isInReplyMode = true
        
        // Update UI
        replyToNameLabel.text = comment.parentName ?? "Unknown User"
        
        // Update the text field for reply mode
        updateTextFieldForReplyMode(isReplying: true)
        
        // Log state
        print("🟢 Reply mode activated with cancel button in rightView")
        
        // Update placeholder text
        updateCommentTextFieldPlaceholder()
        
        // Focus on the text field
        commentTextField.becomeFirstResponder()
    }
    
    private func updateCommentTextFieldPlaceholder() {
        if isInReplyMode {
            commentTextField.placeholder = "Reply to \(replyingToComment?.parentName ?? "comment")..."
        } else {
            commentTextField.placeholder = "Write a comment..."
        }
    }
    
    // Replace setupCancelButton with a method that updates the rightView
    private func updateTextFieldForReplyMode(isReplying: Bool) {
        if isReplying {
            print("📱 Setting up text field for reply mode")
            
            // Create a new container for the right view
            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            
            // Configure the cancel button
            cancelReplyButton.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
            
            // Add button to the container
            rightViewContainer.addSubview(cancelReplyButton)
            
            // Set as right view
            commentTextField.rightView = rightViewContainer
            
            print("📱 Cancel button added to right view container")
        } else {
            // Reset to empty right view
            let emptyRightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
            commentTextField.rightView = emptyRightView
        }
    }
    
    // Add a tap gesture recognizer to the text field
    private func setupTextFieldTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(commentTextFieldTapped))
        commentTextField.addGestureRecognizer(tapGesture)
        commentTextField.isUserInteractionEnabled = true
    }
    
    @objc private func commentTextFieldTapped() {
        print("📱 Comment text field tapped, showing keyboard")
        commentTextField.becomeFirstResponder()
    }
    
    // MARK: - Debug Functions
    func debugSavedPostsFunctionality() {
        print("\n\n🛠️ Starting SavedPosts debugging from ModernPostDetailViewController...\n\n")
        SavedPostsDebugger.runTests()
    }
    
    // Debug handler
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let alert = UIAlertController(title: "Debug Options", message: "Select a debug action", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Test SavedPosts Functionality", style: .default) { [weak self] _ in
                self?.debugSavedPostsFunctionality()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
}

//
