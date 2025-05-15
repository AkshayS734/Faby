import UIKit

class MyPostCardCell: UITableViewCell {
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        button.setImage(UIImage(systemName: "message", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private let likeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let commentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - Properties
    private var post: Post?
    private var isLiked = false {
        didSet {
            updateLikeButtonAppearance()
        }
    }
    weak var delegate: PostCardCellDelegate?
    
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
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(cardView)
        
        [categoryLabel, timestampLabel, titleLabel, previewLabel, thumbnailImageView, buttonsStackView].forEach {
            cardView.addSubview($0)
        }
        
        likeStackView.addArrangedSubview(likeButton)
        likeStackView.addArrangedSubview(likeCountLabel)
        
        commentStackView.addArrangedSubview(commentButton)
        commentStackView.addArrangedSubview(commentCountLabel)
        
        buttonsStackView.addArrangedSubview(likeStackView)
        buttonsStackView.addArrangedSubview(commentStackView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            thumbnailImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            thumbnailImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 100),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 100),
            
            categoryLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),

            timestampLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            timestampLabel.trailingAnchor.constraint(lessThanOrEqualTo: thumbnailImageView.leadingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
            
            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            previewLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            previewLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
            
            buttonsStackView.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 12),
            buttonsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            buttonsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupGestures() {
        likeButton.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
    }
    
    private func updateLikeButtonAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        likeButton.setImage(
            UIImage(systemName: isLiked ? "heart.fill" : "heart", withConfiguration: config),
            for: .normal
        )
        likeButton.tintColor = isLiked ? .systemRed : .systemGray
    }
    
    // MARK: - Actions
    @objc private func handleLikeButton() {
        guard let post = post else { return }
        
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ User not logged in")
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please log in to like posts",
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
        PostsSupabaseManager.shared.checkIfUserLiked(postId: post.postId, userId: userId) { [weak self] alreadyLiked, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to check like status: \(error.localizedDescription)")
                // Revert UI state
                DispatchQueue.main.async {
                    self.isLiked = !self.isLiked
                }
                return
            }
            
            if alreadyLiked {
                // Remove like
                PostsSupabaseManager.shared.removeLike(postId: post.postId, userId: userId) { success, error in
                    if let error = error {
                        print("❌ Failed to remove like: \(error.localizedDescription)")
                        // Revert UI state
                        DispatchQueue.main.async {
                            self.isLiked = !self.isLiked
                        }
                    }
                }
            } else {
                // Add like
                PostsSupabaseManager.shared.addLike(postId: post.postId, userId: userId) { success, error in
                    if let error = error {
                        print("❌ Failed to add like: \(error.localizedDescription)")
                        // Revert UI state
                        DispatchQueue.main.async {
                            self.isLiked = !self.isLiked
                        }
                    }
                }
            }
        }
    }
    
    @objc private func handleCommentButton() {
        guard let post = post else { return }
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button
        UIView.animate(withDuration: 0.2, animations: {
            self.commentButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.commentButton.transform = .identity
            }
        }
        
        // Notify delegate about comment action
        delegate?.didTapComment(for: post)
    }
    
    // MARK: - Configuration
    func configure(with post: Post, isLiked: Bool = false) {
        self.post = post
        self.isLiked = isLiked
        
        titleLabel.text = post.postTitle
        previewLabel.text = post.postContent
        
        // Format date
        if let dateString = post.createdAt, let formattedDate = DateFormatter.formatPostDate(dateString) {
            timestampLabel.text = formattedDate
        } else {
            timestampLabel.text = "Recently"
        }
        
        // Update the like button appearance based on isLiked
        updateLikeButtonAppearance()
        
        // Fetch and set topic name
        if let topicUUID = UUID(uuidString: post.topicId) {
            PostsSupabaseManager.shared.fetchTopics { [weak self] topics, error in
                DispatchQueue.main.async {
                    if let topics = topics,
                       let topic = topics.first(where: { UUID(uuidString: $0.id) == topicUUID }) {
                        self?.categoryLabel.text = topic.title
                    } else {
                        self?.categoryLabel.text = "Unknown Category"
                    }
                }
            }
        } else {
            categoryLabel.text = "Unknown Category"
        }
        
        // Fetch like counts using new optimized method
        PostsSupabaseManager.shared.fetchPostLikeCount(postId: post.postId) { [weak self] count, error in
            DispatchQueue.main.async {
                self?.likeCountLabel.text = "\(count)"
                self?.likeCountLabel.isHidden = count == 0
                
                // Update isLiked state based on count
                self?.isLiked = count ?? 0 > 0
                
                // Update button appearance after changing isLiked
                self?.updateLikeButtonAppearance()
            }
        }
        
        // Fetch comment counts
        PostsSupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            DispatchQueue.main.async {
                let commentCount = comments?.count ?? 0
                self?.commentCountLabel.text = "\(commentCount)"
                self?.commentCountLabel.isHidden = commentCount == 0
            }
        }
        
        // Handle thumbnail image
        if let imageUrlString = post.image_url, let imageUrl = URL(string: imageUrlString) {
            thumbnailImageView.isHidden = false
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.thumbnailImageView.image = image
                    } else {
                        self?.thumbnailImageView.image = UIImage(systemName: "photo")
                        self?.thumbnailImageView.tintColor = .systemGray3
                    }
                }
            }.resume()
        } else {
            thumbnailImageView.isHidden = true
        }
    }
}
