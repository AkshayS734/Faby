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
        imageView.layer.cornerRadius = 16
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
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
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
    
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.systemGray, for: .normal)
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
        button.setTitleColor(.systemGray, for: .normal)
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
        containerView.addSubview(replyButton)
        containerView.addSubview(moreButton)
        containerView.addSubview(viewRepliesButton)
        containerView.addSubview(indentLineView)
        
        // Add tap targets
        replyButton.addTarget(self, action: #selector(handleReply), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            commentBubble.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            commentBubble.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            commentBubble.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -8),
            
            usernameLabel.topAnchor.constraint(equalTo: commentBubble.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -12),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 12),
            commentLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -12),
            commentLabel.bottomAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor),
            
            replyButton.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            replyButton.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 16),
            replyButton.heightAnchor.constraint(equalToConstant: 22),
            
            moreButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            moreButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // View replies button - Instagram style
            viewRepliesButton.topAnchor.constraint(equalTo: replyButton.bottomAnchor, constant: 8),
            viewRepliesButton.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20), // Indented
            viewRepliesButton.heightAnchor.constraint(equalToConstant: 22),
            viewRepliesButton.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -80),
            
            // Indent line for replies (Instagram style)
            indentLineView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            indentLineView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 4),
            indentLineView.widthAnchor.constraint(equalToConstant: 1.5),
            indentLineView.bottomAnchor.constraint(equalTo: viewRepliesButton.bottomAnchor),
            
            // Bottom constraint (dynamic based on reply button visibility)
            viewRepliesButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with comment: Comment, isLiked: Bool) {
        self.comment = comment
        
        usernameLabel.text = comment.parentName ?? "Unknown User"
        commentLabel.text = comment.content
        self.isLiked = isLiked
        
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
        timeLabel.text = formatTimeAgo(from: comment.createdAt)
        
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
    
    private func updateLikeButtonAppearance() {
        // Update visual appearance based on like state
    }
    
    // MARK: - Helper Methods
    private func formatTimeAgo(from timeString: String?) -> String {
        guard let timeString = timeString,
              let date = DateFormatter.iso8601Full.date(from: timeString) else {
            return "Just now"
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
        
        if let minutes = components.minute, minutes < 60 {
            return minutes == 1 ? "1m" : "\(minutes)m"
        } else if let hours = components.hour, hours < 24 {
            return hours == 1 ? "1h" : "\(hours)h"
        } else if let days = components.day, days < 7 {
            return days == 1 ? "1d" : "\(days)d"
        } else if let weeks = components.weekOfYear, weeks < 5 {
            return weeks == 1 ? "1w" : "\(weeks)w"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comment = nil
        isLiked = false
        viewRepliesButton.isHidden = true
        indentLineView.isHidden = true
    }
}
