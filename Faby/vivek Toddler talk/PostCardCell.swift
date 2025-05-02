import UIKit

class PostCardCell: UITableViewCell {
    
    enum CardStyle {
        case simple
        case withImage
        
        var backgroundColor: UIColor {
            switch self {
            case .simple:
                return .white
            case .withImage:
                return .white
            }
        }
        
        static let pastelColors: [UIColor] = [
            UIColor(red: 0.95, green: 0.97, blue: 1.00, alpha: 1.0),  // Light Blue
            UIColor(red: 0.98, green: 0.95, blue: 1.00, alpha: 1.0),  // Light Purple
            UIColor(red: 1.00, green: 0.98, blue: 0.95, alpha: 1.0),  // Light Orange
            UIColor(red: 0.95, green: 1.00, blue: 0.97, alpha: 1.0),  // Light Green
            UIColor(red: 1.00, green: 0.95, blue: 0.95, alpha: 1.0),  // Light Pink
            UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0),  // Light Gray
            UIColor(red: 0.95, green: 1.00, blue: 1.00, alpha: 1.0),  // Light Cyan
            UIColor(red: 1.00, green: 1.00, blue: 0.95, alpha: 1.0)   // Light Yellow
        ]
    }
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let hashtagsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        return label
    }()
    
    private let postImagesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let interactionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.isHidden = true
        return label
    }()
    
//    private let shareButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        button.tintColor = .systemGray
//        return button
//    }()
    
    private var postImagesStackViewHeightConstraint: NSLayoutConstraint?
    private var isLiked = false {
        didSet {
            updateLikeButtonAppearance()
        }
    }
    
    private func updateLikeButtonAppearance() {
        likeButton.setImage(
            UIImage(systemName: isLiked ? "heart.fill" : "heart"),
            for: .normal
        )
        likeButton.tintColor = isLiked ? .systemRed : .systemGray
    }
    
    // MARK: - Properties
    private var post: Post?
    private var post_id: String?
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
        backgroundColor = .clear
        
        contentView.addSubview(cardView)
        
        [userImageView, userNameLabel, timeLabel, moreButton, titleLabel, contentLabel,
         hashtagsLabel, postImagesStackView, interactionView].forEach { cardView.addSubview($0) }
        
        [likeButton, likeCountLabel, commentButton, commentCountLabel].forEach { interactionView.addSubview($0) }
        
        postImagesStackViewHeightConstraint = postImagesStackView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            userImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            userImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40),
            
            userNameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            
            timeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            
            moreButton.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            moreButton.widthAnchor.constraint(equalToConstant: 30),
            moreButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            hashtagsLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            hashtagsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            hashtagsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            postImagesStackView.topAnchor.constraint(equalTo: hashtagsLabel.bottomAnchor, constant: 12),
            postImagesStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            postImagesStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            postImagesStackViewHeightConstraint!,
            
            interactionView.topAnchor.constraint(equalTo: postImagesStackView.bottomAnchor, constant: 12),
            interactionView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            interactionView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            interactionView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            interactionView.heightAnchor.constraint(equalToConstant: 36),
            
            likeButton.leadingAnchor.constraint(equalTo: interactionView.leadingAnchor),
            likeButton.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
            commentButton.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            
            commentCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 4),
            commentCountLabel.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor)
        ])
        
        setupMoreButton()
    }
    
    private func setupGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        cardView.addGestureRecognizer(doubleTap)
        cardView.isUserInteractionEnabled = true
        
        likeButton.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
    
    private func setupMoreButton() {
        let interaction = UIContextMenuInteraction(delegate: self)
        moreButton.addInteraction(interaction)
    }
    
    // MARK: - Actions
    @objc private func handleDoubleTap() {
        handleLikeButton()
    }
    
    @objc private func handleLikeButton() {
        guard let postId = post_id else {
            print("❌ Missing postId")
            return
        }
        
        guard let userId = SupabaseManager.shared.userID else {
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
        
        if isLiked {
            // Adding like
            print("📢 Adding like for post: \(postId)")
            SupabaseManager.shared.addLike(postId: postId, userId: userId) { [weak self] success, error in
                DispatchQueue.main.async {
                    if !success {
                        // Revert UI if like failed
                        self?.isLiked = false
                        print("❌ Failed to add like: \(error?.localizedDescription ?? "Unknown error")")
                        
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to like post. Please try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                    }
                }
            }
        } else {
            // Removing like
            print("📢 Removing like for post: \(postId)")
            SupabaseManager.shared.removeLike(postId: postId, userId: userId) { [weak self] success, error in
                DispatchQueue.main.async {
                    if !success {
                        // Revert UI if unlike failed
                        self?.isLiked = true
                        print("❌ Failed to remove like: \(error?.localizedDescription ?? "Unknown error")")
                        
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to remove like. Please try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func handleCommentButton() {
        if let post = post {
            delegate?.didTapComment(for: post)
        }
    }
    
    @objc private func handleMoreButton() {
        if let post = post {
            delegate?.didTapMore(for: post)
        }
    }
    
    // MARK: - Configuration
    func configure(with post: Post, isLiked: Bool = false) {
        self.post = post
        self.post_id = post.postId
        self.isLiked = isLiked
        
        userNameLabel.text = post.parents?.first?.name ?? "Unknown User"
        titleLabel.text = post.postTitle
        contentLabel.text = post.postContent
        
        // Format time
        timeLabel.text = DateFormatter.formatPostDate(post.createdAt)
        
        // Set card style
        let hasImage = post.image_url != nil
        let style: CardStyle = hasImage ? .withImage : .simple
        cardView.backgroundColor = style.backgroundColor
        
        // Handle images
        postImagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let imageUrlString = post.image_url, let imageUrl = URL(string: imageUrlString) {
            postImagesStackViewHeightConstraint?.constant = 200
            let imageView = createPostImageView()
            postImagesStackView.addArrangedSubview(imageView)
            
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        imageView.image = image
                    } else {
                        imageView.backgroundColor = .systemGray5
                        imageView.image = UIImage(systemName: "photo")
                        imageView.tintColor = .systemGray3
                    }
                }
            }.resume()
        } else {
            postImagesStackViewHeightConstraint?.constant = 0
        }
        
        // Fetch like counts - using new optimized method
        SupabaseManager.shared.fetchPostLikeCount(postId: post.postId) { [weak self] count, error in
            DispatchQueue.main.async {
                self?.likeCountLabel.text = "\(count)"
                self?.likeCountLabel.isHidden = count == 0
            }
        }
        
        // Fetch comment counts
        SupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            DispatchQueue.main.async {
                let commentCount = comments?.count ?? 0
                self?.commentCountLabel.text = "\(commentCount)"
                self?.commentCountLabel.isHidden = commentCount == 0
            }
        }
    }
    
    private func createPostImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension PostCardCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if interaction.view == moreButton {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                guard let self = self, let post = self.post else { return nil }
                
                let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    self.delegate?.didTapMore(for: post)
                }
                
                let bookmark = UIAction(title: "Save", image: UIImage(systemName: "bookmark")) { _ in
                    self.delegate?.didTapSave(for: post)
                }
                
                let report = UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.triangle"),
                                    attributes: .destructive) { _ in
                    self.delegate?.didTapReport(for: post)
                }
                
                return UIMenu(title: "", children: [share, bookmark, report])
            }
        }
        return nil
    }
}
