import UIKit

class ModernCommentCell: UITableViewCell {
    
    static let identifier = "ModernCommentCell"
    
    // MARK: - UI Components
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let commentLabel: UILabel = {
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
        label.textColor = .systemGray
        return label
    }()
    
    // Actions row for likes, replies, etc.
    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    // Reply button styled like Instagram
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reply", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.systemGray, for: .normal)
        return button
    }()
    
    // View Replies button styled like Instagram
    private let viewRepliesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .clear
        return button
    }()
    
    // Indent line for replies - Instagram style
    private let indentLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        return view
    }()
    
    // MARK: - Properties
    private var comment: Comment?
    private var delegate: CommentCellDelegate?
    
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
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(userImageView)
        contentView.addSubview(commentBubble)
        commentBubble.addSubview(usernameLabel)
        commentBubble.addSubview(commentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(actionsStackView)
        contentView.addSubview(viewRepliesButton)
        contentView.addSubview(indentLineView)
        
        // Add reply button to actions stack
        actionsStackView.addArrangedSubview(replyButton)
        
        // Setup reply button action
        replyButton.addTarget(self, action: #selector(replyButtonTapped), for: .touchUpInside)
        viewRepliesButton.addTarget(self, action: #selector(viewRepliesButtonTapped), for: .touchUpInside)
        
        // Hide indent line and view replies button by default
        indentLineView.isHidden = true
        viewRepliesButton.isHidden = true
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userImageView.widthAnchor.constraint(equalToConstant: 30),
            userImageView.heightAnchor.constraint(equalToConstant: 30),
            
            commentBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            commentBubble.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            commentBubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: commentBubble.topAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -12),
            
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            commentLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor, constant: 12),
            commentLabel.trailingAnchor.constraint(equalTo: commentBubble.trailingAnchor, constant: -12),
            commentLabel.bottomAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: commentBubble.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor),
            
            // Action stack view positioning
            actionsStackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            actionsStackView.leadingAnchor.constraint(equalTo: commentBubble.leadingAnchor),
            actionsStackView.heightAnchor.constraint(equalToConstant: 24),
            
            // View replies button
            viewRepliesButton.topAnchor.constraint(equalTo: actionsStackView.bottomAnchor, constant: 4),
            viewRepliesButton.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20), // Indented more than the comment
            viewRepliesButton.heightAnchor.constraint(equalToConstant: 22),
            viewRepliesButton.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -80),
            
            // Indent line for replies (Instagram style)
            indentLineView.topAnchor.constraint(equalTo: actionsStackView.bottomAnchor, constant: 8),
            indentLineView.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 4),
            indentLineView.widthAnchor.constraint(equalToConstant: 1.5),
            indentLineView.bottomAnchor.constraint(equalTo: viewRepliesButton.bottomAnchor),
            
            // Content bottom constraint
            viewRepliesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with comment: Comment, isLiked: Bool, delegate: CommentCellDelegate? = nil) {
        self.comment = comment
        self.delegate = delegate
        
        usernameLabel.text = comment.parentName ?? "Unknown User"
        commentLabel.text = comment.content
        timeLabel.text = formatTime(from: comment.createdAt)
        
        // Configure the view replies button if there are replies
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
        
        // If it's a reply, adjust the UI accordingly
        if comment.isReply == true {
            // Replies don't have the view replies button
            viewRepliesButton.isHidden = true
            indentLineView.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func replyButtonTapped() {
        guard let comment = comment, let delegate = delegate else { return }
        delegate.didTapReplyButton(for: comment)
    }
    
    @objc private func viewRepliesButtonTapped() {
        guard let comment = comment, let delegate = delegate else { return }
        delegate.didTapViewReplies(for: comment)
    }
    
    // MARK: - Helper Methods
    private func formatTime(from timeString: String?) -> String {
        // If timeString is nil, create a new date with the current time
        guard let timeString = timeString else {
            // For new comments without a timestamp, use the current time
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: now)
        }
        
        // Try to parse the ISO date string
        guard let date = DateFormatter.iso8601Full.date(from: timeString) else {
            // If parsing fails, return a formatted current time
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: now)
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
}

