import UIKit

protocol CommentCellDelegate: AnyObject {
    func didTapLikeButton(for comment: Comment)
    func didTapReplyButton(for comment: Comment)
    func didTapMore(for comment: Comment)
    func didTapViewReplies(for comment: Comment)
    func didTapReport(for comment: Comment)
}

class CommentCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let commentBubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.text = "0"
        return label
    }()
    
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    // Add a view replies button - Instagram style
    private lazy var viewRepliesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleViewReplies), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    // Indent line for replies - Instagram style
    private let indentLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.isHidden = true
        return view
    }()
    
    // MARK: - Properties
    private var isLiked = false {
        didSet {
            updateLikeButtonAppearance()
        }
    }
    
    private var comment: Comment?
    weak var delegate: CommentCellDelegate?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(commentBubble)
        commentBubble.addSubview(usernameLabel)
        commentBubble.addSubview(commentLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(likeButton)
        containerView.addSubview(likeCountLabel)
        containerView.addSubview(replyButton)
        containerView.addSubview(moreButton)
        containerView.addSubview(viewRepliesButton)
        containerView.addSubview(indentLineView)
        
        // Add tap targets
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(handleReply), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            commentBubble.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            commentBubble.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            commentBubble.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -12),
            
            usernameLabel.topAnchor.constraint(equalTo: commentBubble.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -16),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            commentLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -16),
            commentLabel.bottomAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: -10),
            
            timeLabel.topAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor),
            
            likeButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 16),
            likeButton.widthAnchor.constraint(equalToConstant: 16),
            likeButton.heightAnchor.constraint(equalToConstant: 16),


            
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            
            replyButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor, constant: 8),
            replyButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
            replyButton.heightAnchor.constraint(equalToConstant: 22),
            
            moreButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            moreButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // View replies button - Instagram style
            viewRepliesButton.topAnchor.constraint(equalTo: replyButton.bottomAnchor, constant: 12),
            viewRepliesButton.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24), // Indented
            viewRepliesButton.heightAnchor.constraint(equalToConstant: 24),
            viewRepliesButton.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -80),
            
            // Indent line for replies (Instagram style)
            indentLineView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            indentLineView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 4),
            indentLineView.widthAnchor.constraint(equalToConstant: 1.5),
            indentLineView.bottomAnchor.constraint(equalTo: viewRepliesButton.bottomAnchor),
            
            // Bottom constraint (dynamic based on reply button visibility)
            viewRepliesButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with comment: Comment, isLiked: Bool) {
        self.comment = comment
        
        usernameLabel.text = comment.parentName ?? "Unknown User"
        commentLabel.text = comment.content
        self.isLiked = isLiked
        
        // Fetch parent profile image if available
        let userId = comment.userId
        print("🔍 CommentCell - Fetching profile image for userId: \(userId)")
        Task {
            do {
                let client = SupabaseManager.shared.client
                let response = try await client.database
                    .from("parents")
                    .select()
                    .eq("uid", value: userId)
                    .limit(1)
                    .execute()
                
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("🔍 CommentCell - Parent data from Supabase: \(jsonString)")
                }
                
                if let jsonData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] {
                    print("🔍 CommentCell - Found \(jsonData.count) parent records")
                    
                    if let firstParent = jsonData.first {
                        print("🔍 CommentCell - Parent data: \(firstParent)")
                        
                        if let parentImageUrl = firstParent["parentimage_url"] as? String {
                            print("✅ CommentCell - Found parentimage_url: \(parentImageUrl)")
                            
                            if let url = URL(string: parentImageUrl) {
                    
                                let (data, _) = try await URLSession.shared.data(from: url)
                                if let image = UIImage(data: data) {
                                    print("✅ CommentCell - Successfully loaded image")
                                    DispatchQueue.main.async { [weak self] in
                                        self?.avatarImageView.image = image
                                    }
                                } else {
                                    print("⚠️ CommentCell - Failed to create image from data")
                                }
                            } else {
                                print("⚠️ CommentCell - Invalid URL format for parentimage_url")
                            }
                        } else {
                            print("⚠️ CommentCell - No parentimage_url found in parent data")
                        }
                    } else {
                        print("⚠️ CommentCell - No parent record found")
                    }
                } else {
                    print("⚠️ CommentCell - Failed to parse parent data from JSON")
                }
            } catch {
                print("❌ Error fetching parent image: \(error.localizedDescription)")
            }
        }
        
        // Fetch like count for this comment
        if let commentId = comment.commentId?.description {
            PostsSupabaseManager.shared.fetchCommentLikes(commentId: commentId) { [weak self] count, _ in
                DispatchQueue.main.async {
                    self?.likeCountLabel.text = count > 0 ? "\(count)" : ""
                }
            }
        }
        
        // Show/hide view replies button based on replies count
        if let repliesCount = comment.repliesCount, repliesCount > 0 {
            viewRepliesButton.isHidden = false
            indentLineView.isHidden = false
            
            // Instagram style with customization for count
            let repliesCountText = repliesCount == 1 ? "1 reply" : "\(repliesCount) replies"
            
            // Check if replies are expanded
            if comment.isRepliesExpanded == true {
                viewRepliesButton.setTitle("Hide replies", for: .normal)
            } else {
                viewRepliesButton.setTitle("View \(repliesCountText)", for: .normal)
            }
        } else {
            viewRepliesButton.isHidden = true
            indentLineView.isHidden = true
        }
        
        // Format time
        timeLabel.text = DateFormatter.formatPostDate(comment.createdAt)
        
        // If this is a reply, adjust the UI accordingly
        if comment.isReply == true {
            // Replies don't have the view replies button
            viewRepliesButton.isHidden = true
            indentLineView.isHidden = true
            
            // Apply indentation through container padding
            containerView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            containerView.layoutMargins = .zero
        }
    }
    
    // MARK: - Actions
    @objc private func handleReply() {
        guard let comment = comment else { return }
        delegate?.didTapReplyButton(for: comment)
    }
    
    @objc private func handleMore() {
        guard let comment = comment else { return }
        delegate?.didTapMore(for: comment)
    }
    
    @objc private func handleViewReplies() {
        guard let comment = comment else { return }
        delegate?.didTapViewReplies(for: comment)
    }
    
    @objc private func handleLike() {
        guard let comment = comment else { return }
        delegate?.didTapLikeButton(for: comment)
    }
    
    private func updateLikeButtonAppearance() {
        // Update visual appearance based on like state
        if isLiked {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .systemGray
        }
    }
    
    // MARK: - Helper Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comment = nil
        isLiked = false
        viewRepliesButton.isHidden = true
        indentLineView.isHidden = true
    }
}

