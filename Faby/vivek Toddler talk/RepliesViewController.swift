import UIKit

class RepliesViewController: UIViewController {
    
    // MARK: - Properties
    private var comment: Comment
    private var replies: [CommentReply] = []
    private var postId: String
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let originalCommentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let replyCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(comment: Comment, postId: String) {
        self.comment = comment
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔍 RepliesViewController loaded for comment ID: \(comment.commentId ?? -1)")
        print("🔍 Comment content: \(comment.content)")
        
        setupUI()
        setupNavBar()
        configureHeaderView()
        
        // Dispatch after a brief delay to ensure view is fully laid out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.fetchReplies()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Register cell
        tableView.register(ReplyCell.self, forCellReuseIdentifier: ReplyCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add subviews
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Add constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 140),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func setupNavBar() {
        title = "Replies"
        navigationItem.largeTitleDisplayMode = .never
        
        // Add close button with explicit dismiss action
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(forceClose)
        )
        navigationItem.rightBarButtonItem = closeButton
    }
    
    private func configureHeaderView() {
        // Add subviews to header
        headerView.addSubview(originalCommentView)
        headerView.addSubview(replyCountLabel)
        originalCommentView.addSubview(userNameLabel)
        originalCommentView.addSubview(contentLabel)
        originalCommentView.addSubview(timeLabel)
        
        // Add constraints
        NSLayoutConstraint.activate([
            originalCommentView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            originalCommentView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            originalCommentView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            userNameLabel.topAnchor.constraint(equalTo: originalCommentView.topAnchor, constant: 12),
            userNameLabel.leadingAnchor.constraint(equalTo: originalCommentView.leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: originalCommentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: originalCommentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: originalCommentView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: originalCommentView.leadingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: originalCommentView.bottomAnchor, constant: -12),
            
            replyCountLabel.topAnchor.constraint(equalTo: originalCommentView.bottomAnchor, constant: 12),
            replyCountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            replyCountLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        // Configure with comment data
        userNameLabel.text = comment.parentName ?? "Unknown User"
        contentLabel.text = comment.content
        timeLabel.text = DateFormatter.formatPostDate(comment.createdAt)
    }
    
    // MARK: - Data Fetching
    private func fetchReplies() {
        guard let commentId = comment.commentId else { 
            print("❌ ERROR: Cannot fetch replies - comment has no ID")
            showErrorAlert(message: "Cannot load replies - invalid comment")
            return 
        }
        
        print("🔄 Fetching replies for comment ID: \(commentId)")
        loadingIndicator.startAnimating()
        
        // For debugging, print database schema info
        print("📊 Reply data should have: commentId=\(commentId), postId=\(postId)")
        
        SupabaseManager.shared.fetchRepliesForComment(commentId: commentId) { [weak self] replies, error in
            guard let self = self else { return }
            
            self.loadingIndicator.stopAnimating()
            
            if let error = error {
                print("❌ ERROR in fetchReplies: \(error)")
                self.showErrorAlert(message: "Failed to load replies. Please try again.")
                return
            }
            
            if let replies = replies {
                print("✅ Successfully fetched \(replies.count) replies for comment \(commentId)")
                
                // Debug log the replies content
                for (index, reply) in replies.enumerated() {
                    print("📝 Reply \(index+1):")
                    print("   - Content: \(reply.replyContent)")
                    print("   - Created by: \(reply.parentName ?? "Unknown")")
                    print("   - Created at: \(reply.createdAt ?? "Unknown time")")
                }
                
                // Store the replies and update UI
                self.replies = replies
                
                // Ensure UI update happens on main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    // Update reply count
                    let count = replies.count
                    self.replyCountLabel.text = "\(count) \(count == 1 ? "Reply" : "Replies")"
                    
                    // Show empty state if needed
                    if count == 0 {
                        print("ℹ️ No replies found for comment \(commentId)")
                        self.tableView.backgroundView = self.createEmptyStateView()
                    } else {
                        print("✅ Showing \(count) replies in table view")
                        self.tableView.backgroundView = nil
                    }
                }
            } else {
                print("⚠️ Received nil replies array for comment \(commentId)")
                self.tableView.backgroundView = self.createEmptyStateView()
            }
        }
    }
    
    private func createEmptyStateView() -> UIView {
        let emptyView = UIView()
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        let imageView = UIImageView(image: UIImage(systemName: "bubble.left"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No replies yet"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Be the first to reply to this comment"
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 15)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(subtitleLabel)
        
        emptyView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
        ])
        
        return emptyView
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func forceClose() {
        print("🔴 Force closing RepliesViewController")
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Forcefully dismiss this view controller
        self.dismiss(animated: true) {
            print("✅ RepliesViewController dismissed successfully")
        }
    }
    
    // Keep the old method for backward compatibility
    @objc private func handleClose() {
        forceClose()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RepliesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReplyCell.identifier, for: indexPath) as? ReplyCell else {
            return UITableViewCell()
        }
        
        let reply = replies[indexPath.row]
        cell.configure(with: reply)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Debug helper to get cell details
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("✅ Cell for row \(indexPath.row) will display")
        
        if let replyCell = cell as? ReplyCell, indexPath.row < replies.count {
            let reply = replies[indexPath.row]
            print("   - Cell configured with reply: \(reply.replyContent)")
        }
    }
} 