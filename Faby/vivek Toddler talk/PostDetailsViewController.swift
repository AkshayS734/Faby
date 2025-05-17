//
//  PostDetailsViewController.swift
//  Faby
//
//  Created by Vivek kumar on 10/05/25.
//

import UIKit

class PostDetailsViewController: UIViewController {
    
    // MARK: - Properties
    private var post: Post
    private var comments: [Comment] = []
    private var isLoadingComments = false
    private var commentsContainerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
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
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.layer.cornerRadius = 8
        return scrollView
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true // Enable user interaction for tap gesture
        return imageView
    }()
    
    private let interactionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let commentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let commentsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let commentsHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let handleBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let commentsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "Comments"
        return label
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
    
    private lazy var commentSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        return button
    }()
    
    private let noCommentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No comments yet. Be the first to comment!"
        label.textColor = .systemGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
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
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
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
        return label
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private var isLiked = false {
        didSet {
            updateLikeButtonAppearance()
        }
    }
    
    // Properties for reply functionality
    private var replyingToComment: Comment?
    private var isInReplyMode: Bool = false {
        didSet {
            updateCommentTextFieldPlaceholder()
        }
    }
    
    private lazy var cancelReplyButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let xImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(xImage, for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(simpleCancelReply), for: .touchUpInside)
        button.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
        return button
    }()
    
    // MARK: - Initialization
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithPost()
        setupGestures()
        setupActions()
        setupKeyboardObservers()
        
        // Check if user has liked this post
        checkIfPostIsLiked()
        
        // Fetch comments for this post
        fetchComments()
        
        // Initially set comments container to be hidden at bottom of screen
        commentsContainerView.alpha = 0.0
        commentsContainerHeightConstraint?.constant = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Post Details"
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(handleMoreButton)
        )
        
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add components to contentView
        [userInfoView, titleLabel, contentLabel, hashtagsLabel, imageScrollView, interactionView].forEach {
            contentView.addSubview($0)
        }
        
        // Add user info components
        [userImageView, userNameLabel, timeLabel].forEach {
            userInfoView.addSubview($0)
        }
        
        // Add image view to image scroll view
        imageScrollView.addSubview(postImageView)
        
        // Add tap gesture recognizer to the image view for full-screen viewing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        postImageView.addGestureRecognizer(tapGesture)
        
        // Add interaction components
        [likeButton, likeCountLabel, commentButton, commentCountLabel, shareButton].forEach {
            interactionView.addSubview($0)
        }
        
        // Add comments container - add it last so it's on top of everything else when shown
        view.addSubview(commentsContainerView)
        
        // Add comments header with handle bar and close button
        commentsContainerView.addSubview(commentsHeaderView)
        commentsHeaderView.addSubview(handleBarView)
        commentsHeaderView.addSubview(commentsHeaderLabel)
        commentsHeaderView.addSubview(closeButton)
        
        // Add comments table and input
        commentsContainerView.addSubview(commentsTableView)
        commentsTableView.addSubview(noCommentsLabel)
        commentsContainerView.addSubview(commentInputView)
        commentInputView.addSubview(commentTextField)
        commentInputView.addSubview(commentSendButton)
        
        // Setup table view
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        // Setup actions
        commentSendButton.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleCloseComments), for: .touchUpInside)
        
        // Add pan gesture for dragging the comments view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        commentsHeaderView.addGestureRecognizer(panGesture)
        commentsHeaderView.isUserInteractionEnabled = true
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // User info view constraints
        NSLayoutConstraint.activate([
            userInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            userInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            userInfoView.heightAnchor.constraint(equalToConstant: 50),
            
            userImageView.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor),
            userImageView.centerYAnchor.constraint(equalTo: userInfoView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 12),
            userNameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: userInfoView.trailingAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 2),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: userInfoView.trailingAnchor)
        ])
        
        // Title, content, and hashtags constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            hashtagsLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            hashtagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hashtagsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Image scroll view constraints
        NSLayoutConstraint.activate([
            imageScrollView.topAnchor.constraint(equalTo: hashtagsLabel.bottomAnchor, constant: 16),
            imageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            // Set a reasonable aspect ratio (16:9) instead of a square
            imageScrollView.heightAnchor.constraint(equalTo: imageScrollView.widthAnchor, multiplier: 0.75),
            
            postImageView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            postImageView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
            postImageView.widthAnchor.constraint(equalTo: imageScrollView.widthAnchor),
            postImageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor)
        ])
        
        // Interaction view constraints
        NSLayoutConstraint.activate([
            interactionView.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 16),
            interactionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            interactionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            interactionView.heightAnchor.constraint(equalToConstant: 44),
            interactionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            likeButton.leadingAnchor.constraint(equalTo: interactionView.leadingAnchor),
            likeButton.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 36),
            likeButton.heightAnchor.constraint(equalToConstant: 36),
            
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4),
            likeCountLabel.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            
            commentButton.leadingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor, constant: 16),
            commentButton.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 36),
            commentButton.heightAnchor.constraint(equalToConstant: 36),
            
            commentCountLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 4),
            commentCountLabel.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            
            shareButton.trailingAnchor.constraint(equalTo: interactionView.trailingAnchor),
            shareButton.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 36),
            shareButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Comments container view constraints
        commentsContainerHeightConstraint = commentsContainerView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // Comments container view
            commentsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            commentsContainerHeightConstraint!,
            
            // Comments header view
            commentsHeaderView.topAnchor.constraint(equalTo: commentsContainerView.topAnchor),
            commentsHeaderView.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor),
            commentsHeaderView.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor),
            commentsHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            // Handle bar
            handleBarView.centerXAnchor.constraint(equalTo: commentsHeaderView.centerXAnchor),
            handleBarView.topAnchor.constraint(equalTo: commentsHeaderView.topAnchor, constant: 8),
            handleBarView.widthAnchor.constraint(equalToConstant: 40),
            handleBarView.heightAnchor.constraint(equalToConstant: 5),
            
            // Close button
            closeButton.trailingAnchor.constraint(equalTo: commentsHeaderView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: commentsHeaderView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            commentsHeaderLabel.leadingAnchor.constraint(equalTo: commentsHeaderView.leadingAnchor, constant: 16),
            commentsHeaderLabel.centerYAnchor.constraint(equalTo: commentsHeaderView.centerYAnchor),
            
            // Comments table view
            commentsTableView.topAnchor.constraint(equalTo: commentsHeaderView.bottomAnchor),
            commentsTableView.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor),
            commentsTableView.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor),
            commentsTableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
            
            noCommentsLabel.centerXAnchor.constraint(equalTo: commentsTableView.centerXAnchor),
            noCommentsLabel.centerYAnchor.constraint(equalTo: commentsTableView.centerYAnchor),
            noCommentsLabel.leadingAnchor.constraint(equalTo: commentsTableView.leadingAnchor, constant: 20),
            noCommentsLabel.trailingAnchor.constraint(equalTo: commentsTableView.trailingAnchor, constant: -20),
            
            // Comment input view
            commentInputView.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor),
            commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            commentInputView.heightAnchor.constraint(equalToConstant: 60),
            
            commentTextField.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: commentSendButton.leadingAnchor, constant: -8),
            commentTextField.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            commentTextField.heightAnchor.constraint(equalToConstant: 36),
            
            commentSendButton.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -16),
            commentSendButton.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            commentSendButton.widthAnchor.constraint(equalToConstant: 44),
            commentSendButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupGestures() {
        // Setup double tap to zoom
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnImage(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageScrollView.addGestureRecognizer(doubleTapGesture)
        
        // Setup pinch gesture for zooming
        imageScrollView.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        // Get keyboard animation duration from notification
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        
        // Get keyboard height
        let keyboardHeight = keyboardFrame.height
        
        // Calculate safe area bottom inset
        let safeAreaBottomInset = view.safeAreaInsets.bottom
        
        // Calculate the exact transform needed to position the input view directly above the keyboard
        // No gap between keyboard and input view
        let transformY = -(keyboardHeight - safeAreaBottomInset)
        
        UIView.animate(withDuration: duration) {
            // Position the comment input view directly above the keyboard with no gap
            self.commentInputView.transform = CGAffineTransform(translationX: 0, y: transformY)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset the comment input view position when keyboard hides
        UIView.animate(withDuration: 0.3) {
            self.commentInputView.transform = .identity
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // Calculate new height based on drag
            let newHeight = commentsContainerHeightConstraint!.constant - translation.y
            
            // Limit height between minimum (comment input height) and maximum (full screen)
            let minHeight = commentInputView.frame.height + commentsHeaderView.frame.height
            let maxHeight = view.bounds.height - view.safeAreaInsets.top
            
            commentsContainerHeightConstraint?.constant = min(maxHeight, max(minHeight, newHeight))
            gesture.setTranslation(.zero, in: view)
            view.layoutIfNeeded()
            
        case .ended:
            // Determine final position based on velocity
            let screenHeight = view.bounds.height
            let currentHeight = commentsContainerHeightConstraint!.constant
            
            // Define snap points (1/4, 1/2, 3/4 of screen)
            let quarterHeight = screenHeight * 0.25
            let halfHeight = screenHeight * 0.5
            let threeQuarterHeight = screenHeight * 0.75
            
            var targetHeight: CGFloat
            
            // If swiping down with high velocity, collapse
            if velocity.y > 1000 {
                targetHeight = 0
            }
            // If swiping up with high velocity, expand
            else if velocity.y < -1000 {
                targetHeight = threeQuarterHeight
            }
            // Otherwise snap to closest position
            else {
                if currentHeight < quarterHeight {
                    targetHeight = 0
                } else if currentHeight < halfHeight {
                    targetHeight = halfHeight
                } else {
                    targetHeight = threeQuarterHeight
                }
            }
            
            // If target height is 0, hide the container
            if targetHeight == 0 {
                hideCommentsView()
            } else {
                // Animate to target height
                UIView.animate(withDuration: 0.3) {
                    self.commentsContainerHeightConstraint?.constant = targetHeight
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handleCloseComments() {
        hideCommentsView()
    }
    
    private func hideCommentsView() {
        // Dismiss keyboard if it's showing
        view.endEditing(true)
        
        // Animate hiding the comments view
        UIView.animate(withDuration: 0.3) {
            self.commentsContainerHeightConstraint?.constant = 0
            self.commentsContainerView.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(handleShareButton), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    private func configureWithPost() {
        // Display the parent name from the post data
        if let parentName = post.parents?.first?.name, !parentName.isEmpty {
            userNameLabel.text = parentName
            
            // Load parent profile image if available
            if let parentImageUrl = post.parents?.first?.parentimage_url {
                print("✅ PostDetailsViewController - Found parentimage_url: \(parentImageUrl)")
                if let url = URL(string: parentImageUrl) {
                    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data) {
                                print("✅ PostDetailsViewController - Successfully loaded image")
                                self?.userImageView.image = image
                            } else {
                                print("⚠️ PostDetailsViewController - Failed to load image data")
                                // Fallback to default image
                                self?.userImageView.image = UIImage(systemName: "person.circle.fill")
                                self?.userImageView.tintColor = .systemBlue
                            }
                        }
                    }.resume()
                } else {
                    print("⚠️ PostDetailsViewController - Invalid URL format for parentimage_url")
                }
            } else {
                // Use default image
                userImageView.image = UIImage(systemName: "person.circle.fill")
                userImageView.tintColor = .systemBlue
            }
        } else {
            // If parent name is not available in the post, try to fetch it
            if let userId = post.userId, !userId.isEmpty {
                fetchParentName(for: userId)
            } else {
                userNameLabel.text = "Unknown User"
            }
        }
        
        titleLabel.text = post.postTitle
        contentLabel.text = post.postContent
        timeLabel.text = DateFormatter.formatPostDate(post.createdAt)
        
        // Load post image if available
        if let imageUrlString = post.image_url, let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.postImageView.image = image
                    } else {
                        self?.postImageView.backgroundColor = .systemGray5
                        self?.postImageView.image = UIImage(systemName: "photo")
                        self?.postImageView.tintColor = .systemGray3
                    }
                }
            }.resume()
        } else {
            // Hide image scroll view if no image
            imageScrollView.isHidden = true
            
            // Update constraints
            NSLayoutConstraint.activate([
                interactionView.topAnchor.constraint(equalTo: hashtagsLabel.bottomAnchor, constant: 16)
            ])
        }
        
        // Fetch like counts
        PostsSupabaseManager.shared.fetchPostLikeCount(postId: post.postId) { [weak self] count, error in
            DispatchQueue.main.async {
                self?.likeCountLabel.text = "\(count)"
            }
        }
        
        // Fetch comment counts
        PostsSupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            DispatchQueue.main.async {
                let commentCount = comments?.count ?? 0
                self?.commentCountLabel.text = "\(commentCount)"
            }
        }
    }
    
    private func checkIfPostIsLiked() {
        guard let userId = AuthManager.shared.currentUserID else { return }
        
        PostsSupabaseManager.shared.checkIfUserLiked(postId: post.postId, userId: userId) { [weak self] isLiked, error in
            DispatchQueue.main.async {
                self?.isLiked = isLiked
            }
        }
    }
    
    private func updateLikeButtonAppearance() {
        likeButton.setImage(
            UIImage(systemName: isLiked ? "heart.fill" : "heart"),
            for: .normal
        )
        likeButton.tintColor = isLiked ? .systemRed : .systemGray
    }
    
    // MARK: - Actions
    @objc private func handleDoubleTapOnImage(_ gesture: UITapGestureRecognizer) {
        if imageScrollView.zoomScale > imageScrollView.minimumZoomScale {
            // If already zoomed in, zoom out
            imageScrollView.setZoomScale(imageScrollView.minimumZoomScale, animated: true)
        } else {
            // Zoom in to where the user tapped
            let location = gesture.location(in: postImageView)
            let zoomRect = CGRect(
                x: location.x - (imageScrollView.frame.width / 4),
                y: location.y - (imageScrollView.frame.height / 4),
                width: imageScrollView.frame.width / 2,
                height: imageScrollView.frame.height / 2
            )
            imageScrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    @objc private func handleLikeButton() {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ User not logged in")
            let alert = UIAlertController(
                title: "Login Required",
                message: "Please log in to like posts",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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
            PostsSupabaseManager.shared.addLike(postId: post.postId, userId: userId) { [weak self] success, error in
                if !success {
                    // Revert UI if like failed
                    DispatchQueue.main.async {
                        self?.isLiked = false
                        
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to like post. Please try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        } else {
            // Removing like
            PostsSupabaseManager.shared.removeLike(postId: post.postId, userId: userId) { [weak self] success, error in
                if !success {
                    // Revert UI if unlike failed
                    DispatchQueue.main.async {
                        self?.isLiked = true
                        
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to remove like. Please try again.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
        
        // Update like count
        PostsSupabaseManager.shared.fetchPostLikeCount(postId: post.postId) { [weak self] count, error in
            DispatchQueue.main.async {
                self?.likeCountLabel.text = "\(count)"
            }
        }
    }
    
    @objc private func handleCommentButton() {
        // Show comments view with animation
        showCommentsView()
    }
    
    private func showCommentsView() {
        // Calculate the height for 3/4 of the screen
        let threeQuarterHeight = view.bounds.height * 0.75
        
        // Make sure the view is visible before animation
        commentsContainerView.alpha = 0.0  // Start completely transparent
        view.bringSubviewToFront(commentsContainerView)  // Ensure it's on top
        
        // Update container height constraint
        commentsContainerHeightConstraint?.constant = threeQuarterHeight
        
        // Animate the appearance
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
            self.commentsContainerView.alpha = 1.0
        }
        
        // Don't automatically focus on the text field - let user tap it when ready
    }
    
    @objc private func handleSendComment() {
        guard let commentText = commentTextField.text, !commentText.isEmpty,
              let userId = AuthManager.shared.currentUserID else {
            return
        }
        
        if isInReplyMode, let replyToComment = replyingToComment, let commentId = replyToComment.commentId {
            // We're replying to a specific comment
            PostsSupabaseManager.shared.addCommentReply(
                commentId: commentId,
                postId: post.postId,
                userId: userId,
                content: commentText
            ) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.commentTextField.text = ""
                        self?.simpleCancelReply()
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
            PostsSupabaseManager.shared.addComment(postId: post.postId, userId: userId, content: commentText) { [weak self] success, error in
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
    
    // MARK: - Comment Methods
    private func fetchComments() {
        isLoadingComments = true
        
        PostsSupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            guard let self = self else { return }
            
            self.isLoadingComments = false
            
            if let error = error {
                print("❌ Error fetching comments: \(error.localizedDescription)")
                return
            }
            
            if let comments = comments {
                self.comments = comments
                
                DispatchQueue.main.async {
                    self.commentsTableView.reloadData()
                    self.noCommentsLabel.isHidden = !self.comments.isEmpty
                    self.updateCommentCount()
                }
            }
        }
    }
    
    @objc private func handleShareButton() {
        var items: [Any] = []
        
        // Create post title with content
        let postText = "\(post.postTitle)\n\n\(post.postContent)"
        items.append(postText)
        
        // Add deep link or web link for sharing
        if let deepLink = PostsSupabaseManager.shared.generatePostDeepLink(for: post) {
            items.append(deepLink)
        } else if let webLink = PostsSupabaseManager.shared.generatePostWebLink(for: post) {
            items.append(webLink)
        }
        
        // Add image if available
        if let image = postImageView.image {
            items.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @objc private func handleMoreButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save Post", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.savePost()
        }
        
        let reportAction = UIAlertAction(title: "Report Post", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.reportPost()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(saveAction)
        actionSheet.addAction(reportAction)
        actionSheet.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(actionSheet, animated: true)
    }
    
    // Fetch parent name from Supabase using the user ID
    private func fetchParentName(for userId: String) {
        print("📢 Fetching parent name for user ID: \(userId)")
        
        Task {
            do {
                let client = SupabaseManager.shared.client
                
                let response = try await client.database
                    .from("parents")
                    .select("name")
                    .eq("uid", value: userId)
                    .limit(1)
                    .execute()
                
                if let jsonData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                   let firstParent = jsonData.first,
                   let name = firstParent["name"] as? String {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.userNameLabel.text = name
                        print("✅ Successfully fetched parent name: \(name)")
                    }
                } else {
                    print("⚠️ No parent found for user ID: \(userId)")
                    DispatchQueue.main.async { [weak self] in
                        self?.userNameLabel.text = "Unknown User"
                    }
                }
            } catch {
                print("❌ Error fetching parent data: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.userNameLabel.text = "Unknown User"
                }
            }
        }
    }
    
    private func savePost() {
        // SupabaseManager.savePost already checks for userID internally
        PostsSupabaseManager.shared.savePost(postId: post.postId) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(
                        title: "Success",
                        message: "Post saved successfully",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to save post. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func reportPost() {
        let alert = UIAlertController(
            title: "Report Post",
            message: "Please select a reason for reporting this post",
            preferredStyle: .actionSheet
        )
        
        let reasons = ["Inappropriate content", "Spam", "Harassment", "False information", "Other"]
        
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .default) { [weak self] _ in
                self?.showReportConfirmation(reason: reason)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func showReportConfirmation(reason: String) {
        // Since there's no reportPost function in SupabaseManager, we'll show a confirmation
        // In a real implementation, you would need to add this function to SupabaseManager
        let alert = UIAlertController(
            title: "Confirm Report",
            message: "Are you sure you want to report this post for \(reason)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            // Show success message (in a real app, this would call the API)
            let successAlert = UIAlertController(
                title: "Report Submitted",
                message: "Thank you for your report. We will review it shortly.",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(successAlert, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Reply Functionality
    @objc private func simpleCancelReply() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Clear all reply state
        isInReplyMode = false
        replyingToComment = nil
        
        // Update text field right view
        updateTextFieldForReplyMode(isReplying: false)
        
        // Clear text fields
        commentTextField.text = ""
        // Reset placeholder
        commentTextField.placeholder = "Write a comment..."
    }
    
    private func startReplyToComment(_ comment: Comment) {
        // Store the comment we're replying to
        replyingToComment = comment
        isInReplyMode = true
        
        // Update the text field for reply mode
        updateTextFieldForReplyMode(isReplying: true)
        
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
    
    private func updateTextFieldForReplyMode(isReplying: Bool) {
        if isReplying {
            // Create a new container for the right view
            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            
            // Configure the cancel button
            cancelReplyButton.frame = CGRect(x: 5, y: 0, width: 30, height: 30)
            
            // Add button to the container
            rightViewContainer.addSubview(cancelReplyButton)
            
            // Set as right view
            commentTextField.rightView = rightViewContainer
        } else {
            // Reset to empty right view
            let emptyRightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
            commentTextField.rightView = emptyRightView
        }
    }
    
    private func updateCommentCount() {
        PostsSupabaseManager.shared.fetchComments(for: post.postId) { [weak self] comments, error in
            DispatchQueue.main.async {
                let commentCount = comments?.count ?? 0
                self?.commentCountLabel.text = "\(commentCount)"
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PostDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        let comment = comments[indexPath.row]
        
        // Check if the user has liked this comment
        if let commentId = comment.commentId?.description, let userId = AuthManager.shared.currentUserID {
            PostsSupabaseManager.shared.checkIfUserLikedComment(commentId: commentId, userId: userId) { isLiked, _ in
                DispatchQueue.main.async {
                    cell.configure(with: comment, isLiked: isLiked)
                }
            }
        } else {
            cell.configure(with: comment, isLiked: false)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - CommentCellDelegate
extension PostDetailsViewController: CommentCellDelegate {
    func didTapLikeButton(for comment: Comment) {
        guard let userId = AuthManager.shared.currentUserID, let commentId = comment.commentId?.description else { return }
        
        // Check if already liked
        PostsSupabaseManager.shared.checkIfUserLikedComment(commentId: commentId, userId: userId) { [weak self] isLiked, _ in
            if isLiked {
                // Unlike
                PostsSupabaseManager.shared.removeCommentLike(commentId: commentId, userId: userId) { success, _ in
                    if success {
                        DispatchQueue.main.async {
                            self?.fetchComments() // Refresh comments to update like count
                        }
                    }
                }
            } else {
                // Like
                PostsSupabaseManager.shared.addCommentLike(commentId: commentId, userId: userId) { success, _ in
                    if success {
                        DispatchQueue.main.async {
                            self?.fetchComments() // Refresh comments to update like count
                        }
                    }
                }
            }
        }
    }
    
    func didTapReplyButton(for comment: Comment) {
        startReplyToComment(comment)
    }
    
    func didTapMore(for comment: Comment) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Only allow reporting if not the user's own comment
        if comment.userId != AuthManager.shared.currentUserID {
            alert.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
                self?.didTapReport(for: comment)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func didTapReport(for comment: Comment) {
        let alert = UIAlertController(
            title: "Report Comment",
            message: "Please select a reason for reporting this comment",
            preferredStyle: .actionSheet
        )
        
        let reasons = ["Inappropriate content", "Spam", "Harassment", "False information", "Other"]
        
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .default) { [weak self] _ in
                // Show confirmation since there's no actual reportComment function
                let confirmAlert = UIAlertController(
                    title: "Report Submitted",
                    message: "Thank you for your report. We will review it shortly.",
                    preferredStyle: .alert
                )
                confirmAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(confirmAlert, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        
        let postId = post.postId
        print("🔄 Using post ID: \(postId)")
        
        // Check if postId is empty
        if postId.isEmpty {
            print("❌ ERROR: Post ID is empty")
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
                PostsSupabaseManager.shared.fetchRepliesForComment(commentId: commentId) { [weak self] replies, error in
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
}

// MARK: - UIScrollViewDelegate
extension PostDetailsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return postImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image in the scroll view as it zooms
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

// MARK: - Full Screen Image Viewer
extension PostDetailsViewController {
    @objc private func handleImageTap() {
        guard let image = postImageView.image else { return }
        
        // Create a full screen image viewer
        let fullScreenVC = FullScreenImageViewController(image: image)
        fullScreenVC.modalPresentationStyle = .fullScreen
        fullScreenVC.modalTransitionStyle = .crossDissolve
        present(fullScreenVC, animated: true)
    }
}

// Full Screen Image View Controller
class FullScreenImageViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .black
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.8
        return button
    }()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add scroll view and image view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)
        
        // Add tap gesture for dismissal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        // Add close button action
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Set scroll view delegate
        scrollView.delegate = self
    }
    
    @objc private func handleTap() {
        // Toggle UI visibility
        let newAlpha: CGFloat = closeButton.alpha > 0 ? 0 : 0.8
        
        UIView.animate(withDuration: 0.3) {
            self.closeButton.alpha = newAlpha
        }
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
}

// MARK: - UIScrollViewDelegate for Full Screen Image
extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Center the image in the scroll view as it zooms
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
