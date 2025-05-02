import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: - UI Components
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
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
        label.isHidden = true
        label.text = "0"
        return label
    }()
    
    private let replyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        button.tintColor = .systemGray
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
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add subviews directly to contentView instead of containerView
        [userImageView, userNameLabel, timeLabel, contentLabel, likeButton, likeCountLabel, replyButton, moreButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userImageView.widthAnchor.constraint(equalToConstant: 32),
            userImageView.heightAnchor.constraint(equalToConstant: 32),
            
            userNameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -8),
            
            moreButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            contentLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            likeButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            
            replyButton.topAnchor.constraint(equalTo: likeButton.topAnchor),
            replyButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
            replyButton.bottomAnchor.constraint(equalTo: likeButton.bottomAnchor)
        ])
        
        setupMoreButton()
    }
    
    private func setupGestures() {
        likeButton.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(handleReplyButton), for: .touchUpInside)
        
        // Remove tap action from moreButton
        // moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
        
        // Instead, add long press gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMoreButton(_:)))
        moreButton.addGestureRecognizer(longPressGesture)
    }
    
    private func setupMoreButton() {
        // Setup context menu - this will only be triggered by the long press gesture now
        let interaction = UIContextMenuInteraction(delegate: self)
        moreButton.addInteraction(interaction)
    }
    
    private func updateLikeButtonAppearance() {
        likeButton.setImage(
            UIImage(systemName: isLiked ? "heart.fill" : "heart"),
            for: .normal
        )
        likeButton.tintColor = isLiked ? .systemRed : .systemGray
    }
    
    // MARK: - Configuration
    func configure(with comment: Comment, isLiked: Bool) {
        self.comment = comment
        
        userNameLabel.text = comment.parentName ?? "Unknown User"
        contentLabel.text = comment.content
        timeLabel.text = DateFormatter.formatPostDate(comment.createdAt)
        
        // For now, use a default user image
        userImageView.image = UIImage(systemName: "person.circle.fill")
        userImageView.tintColor = .systemBlue
        
        // Check if this comment is liked by the current user
        if let userId = SupabaseManager.shared.userID, let commentId = comment.commentId {
            // Use the actual Comment_id from the database instead of postId
            SupabaseManager.shared.checkIfUserLikedComment(commentId: String(commentId), userId: userId) { [weak self] isCommentLiked, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLiked = isCommentLiked
                    print("\(isCommentLiked ? "❤️" : "🤍") Comment \(commentId) like status: \(isCommentLiked)")
                }
            }
        } else {
            self.isLiked = false
        }
        
        // Fetch and update like count
        if let commentId = comment.commentId {
            updateLikeCount(for: String(commentId))
        } else {
            likeCountLabel.text = "0"
            likeCountLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func handleLikeButton() {
        guard let comment = comment else { return }
        guard let commentId = comment.commentId else {
            print("❌ Comment doesn't have a valid commentId")
            return
        }
        
        guard let userId = SupabaseManager.shared.userID else {
            print("❌ User not logged in")
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please log in to like comments",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            return
        }
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button
        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = .identity
            }
        }
        
        // Optimistically update UI
        isLiked = !isLiked
        
        // Check if already liked before adding/removing like
        let commentIdString = String(commentId)
        SupabaseManager.shared.checkIfUserLikedComment(commentId: commentIdString, userId: userId) { [weak self] alreadyLiked, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to check comment like status: \(error.localizedDescription)")
                // Revert UI state
                DispatchQueue.main.async {
                    self.isLiked = !self.isLiked
                }
                return
            }
            
            if alreadyLiked {
                // Remove like
                SupabaseManager.shared.removeCommentLike(commentId: commentIdString, userId: userId) { success, error in
                    if let error = error {
                        print("❌ Failed to remove comment like: \(error.localizedDescription)")
                        // Revert UI state
                        DispatchQueue.main.async {
                            self.isLiked = !self.isLiked
                        }
                    } else {
                        // Update like count
                        self.updateLikeCount(for: commentIdString)
                    }
                }
            } else {
                // Add like
                SupabaseManager.shared.addCommentLike(commentId: commentIdString, userId: userId) { success, error in
                    if let error = error {
                        print("❌ Failed to add comment like: \(error.localizedDescription)")
                        // Revert UI state
                        DispatchQueue.main.async {
                            self.isLiked = !self.isLiked
                        }
                    } else {
                        // Update like count
                        self.updateLikeCount(for: commentIdString)
                    }
                }
            }
        }
    }
    
    private func updateLikeCount(for commentId: String) {
        SupabaseManager.shared.fetchCommentLikes(commentId: commentId) { [weak self] count, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.likeCountLabel.text = "\(count)"
                self.likeCountLabel.isHidden = count == 0
            }
        }
    }
    
    @objc private func handleReplyButton() {
        guard let comment = comment else { return }
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button
        UIView.animate(withDuration: 0.2, animations: {
            self.replyButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.replyButton.transform = .identity
            }
        }
        
        // Notify delegate about reply action
        delegate?.didTapReplyButton(for: comment)
    }
    
    @objc private func handleLongPressMoreButton(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if let comment = comment {
                delegate?.didTapMore(for: comment)
            }
        }
    }
}

// MARK: - CommentCellDelegate
protocol CommentCellDelegate: AnyObject {
    func didTapReplyButton(for comment: Comment)
    func didTapMore(for comment: Comment)
    func didTapReport(for comment: Comment)
}

// MARK: - UIContextMenuInteractionDelegate
extension CommentCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if interaction.view == moreButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                guard let self = self, let comment = self.comment else { return nil }
                
                let report = UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.triangle"),
                                    attributes: .destructive) { _ in
                    self.delegate?.didTapReport(for: comment)
                }
                
                return UIMenu(title: "", children: [report])
            }
        }
        return nil
    }
}
