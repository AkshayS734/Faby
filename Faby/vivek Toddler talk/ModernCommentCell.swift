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
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(username: String, comment: String, time: String) {
        usernameLabel.text = username
        commentLabel.text = comment
        timeLabel.text = time
    }
}
