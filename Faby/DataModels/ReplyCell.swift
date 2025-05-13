import UIKit

class ReplyCell: UITableViewCell {
    
    static let identifier = "ReplyCell"
    
    // MARK: - UI Components
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        // Add subtle border
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.2).cgColor
        return imageView
    }()
    
    private let replyBubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        // Add subtle shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemBlue
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
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Properties
    private var reply: CommentReply?
    
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
        
        // Add subtle highlight effect to cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        selectedBackgroundView = backgroundView
        
        contentView.addSubview(userImageView)
        contentView.addSubview(replyBubble)
        replyBubble.addSubview(userNameLabel)
        replyBubble.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), // Indented from normal comments
            userImageView.widthAnchor.constraint(equalToConstant: 28),
            userImageView.heightAnchor.constraint(equalToConstant: 28),
            
            replyBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            replyBubble.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            replyBubble.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            userNameLabel.topAnchor.constraint(equalTo: replyBubble.topAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: replyBubble.leadingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: replyBubble.trailingAnchor, constant: -12),
            
            contentLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: replyBubble.leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: replyBubble.trailingAnchor, constant: -12),
            contentLabel.bottomAnchor.constraint(equalTo: replyBubble.bottomAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: replyBubble.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: replyBubble.leadingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with reply: CommentReply) {
        print("🔍 Configuring ReplyCell with data:")
        print("   - Reply Content: \(reply.replyContent)")
        print("   - Parent Name: \(reply.parentName ?? "nil")")
        print("   - Created At: \(reply.createdAt ?? "nil")")
        
        self.reply = reply
        
        // Set username with indicator that it's a reply
        let userName = reply.parentName ?? "Unknown User"
        userNameLabel.text = userName
        
        // Make reply content stand out
        contentLabel.text = reply.replyContent
        
        // Format time nicely
        if let timeString = DateFormatter.formatPostDate(reply.createdAt) {
            timeLabel.text = timeString
        } else {
            timeLabel.text = "Recently"
        }
        
        // Randomize user avatar colors for visual variety
        let colors: [UIColor] = [.systemBlue, .systemIndigo, .systemPurple, .systemTeal, .systemGreen]
        let randomIndex = abs(userName.hashValue) % colors.count
        userImageView.tintColor = colors[randomIndex]
        
        // Force layout update
        layoutIfNeeded()
        
        print("✅ ReplyCell configured successfully")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = nil
        contentLabel.text = nil
        timeLabel.text = nil
    }
} 
