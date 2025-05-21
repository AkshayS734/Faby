import UIKit

class TodayBiteCollectionViewCell: UICollectionViewCell {
    
    // Card container
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = .systemGray6 // Light gray background while loading
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Text background gradient for better visibility
    private let textBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Shimmer effect view
    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // Shimmer animation view
    private let shimmerLayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var shimmerLayer: CAGradientLayer?
    private var imageLoadTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGradient()
        
        // Add shadow to text labels for better visibility
        [titleLabel, mealTypeLabel, timeLabel].forEach { label in
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: 0, height: 2)
            label.layer.shadowRadius = 4
            label.layer.shadowOpacity = 0.7
            label.layer.masksToBounds = false
        }
        
        // Set up shimmer layer
        setupShimmerLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        mealTypeLabel.text = ""
        timeLabel.text = ""
        
        // Cancel any ongoing image loading task
        imageLoadTask?.cancel()
        imageLoadTask = nil
        
        // Stop shimmer animation
        stopShimmerAnimation()
    }

    private func setupUI() {
        // Add card view to content view
        contentView.addSubview(cardView)
        
        // Add components to card view
        cardView.addSubview(imageView)
        cardView.addSubview(overlayView)
        cardView.addSubview(textBackgroundView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(mealTypeLabel)
        cardView.addSubview(timeLabel)
        
        // Add shimmer view
        cardView.addSubview(shimmerView)
        shimmerView.addSubview(shimmerLayerView)

        NSLayoutConstraint.activate([
            // Card view constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Image view fills the entire card
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            // Overlay view covers the image
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            // Text background gradient view (covers bottom half)
            textBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            textBackgroundView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            textBackgroundView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            textBackgroundView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.5),

            // Title label positioned at bottom left
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: mealTypeLabel.topAnchor, constant: -4),
            
            // Meal type label below title
            mealTypeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mealTypeLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -20),
            mealTypeLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4),

            // Time label at the bottom
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -20),
            timeLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            // Shimmer view constraints (same as image view)
            shimmerView.topAnchor.constraint(equalTo: cardView.topAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            // Shimmer layer view
            shimmerLayerView.topAnchor.constraint(equalTo: shimmerView.topAnchor),
            shimmerLayerView.leadingAnchor.constraint(equalTo: shimmerView.leadingAnchor),
            shimmerLayerView.trailingAnchor.constraint(equalTo: shimmerView.trailingAnchor),
            shimmerLayerView.bottomAnchor.constraint(equalTo: shimmerView.bottomAnchor)
        ])
    }
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer?.locations = [0.0, 0.5, 1.0]
        gradientLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        if let gradientLayer = gradientLayer {
            textBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private func setupShimmerLayer() {
        shimmerLayer = CAGradientLayer()
        shimmerLayer?.colors = [
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.systemGray6.cgColor
        ]
        shimmerLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer?.locations = [0, 0.25, 0.5, 0.75, 1]
        shimmerLayer?.frame = shimmerLayerView.bounds
        
        // Add the shimmer layer to the view
        if let shimmerLayer = shimmerLayer {
            shimmerLayerView.layer.addSublayer(shimmerLayer)
        }
    }
    
    // Start shimmer animation
    private func startShimmerAnimation() {
        // Show shimmer view
        shimmerView.isHidden = false
        
        // Hide image temporarily
        imageView.alpha = 0
        overlayView.alpha = 0
        
        // Update layer frame
        shimmerLayer?.frame = shimmerLayerView.bounds
        
        // Create animation
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.75, -0.5, -0.25, 0]
        animation.toValue = [1, 1.25, 1.5, 1.75, 2]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        // Add animation
        shimmerLayer?.add(animation, forKey: "shimmerAnimation")
    }
    
    // Stop shimmer animation
    private func stopShimmerAnimation() {
        // Show image
        imageView.alpha = 1
        overlayView.alpha = 1
        
        // Hide shimmer view
        shimmerView.isHidden = true
        
        // Remove animation
        shimmerLayer?.removeAllAnimations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shimmer layer frame when layout changes
        shimmerLayer?.frame = shimmerLayerView.bounds
        
        // Update gradient layer frame
        gradientLayer?.frame = textBackgroundView.bounds
    }

    func configure(with bite: TodayBite) {
        // Set text content
        titleLabel.text = bite.title
        if let category = bite.category {
            mealTypeLabel.text = category
            mealTypeLabel.textColor = .white
        } else {
            mealTypeLabel.text = ""
        }
        timeLabel.text = bite.time
        
        // Start shimmer immediately
        startShimmerAnimation()
        
        // Get the image name/URL
        let imageName = bite.imageName
        
        // Set a placeholder color while loading
        imageView.backgroundColor = .systemGray6
        
        // Handle different image source types
        if let image = UIImage(named: imageName) {
            // Local asset case - show immediately
            self.imageView.image = image
            self.stopShimmerAnimation()
        } else if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            // URL case - load asynchronously
            loadImageFromURL(imageUrl: imageName)
        } else if imageName.contains("/") {
            // Local file path case
            if let image = UIImage(contentsOfFile: imageName) {
                self.imageView.image = image
                self.stopShimmerAnimation()
            } else {
                // If file can't be loaded, use fallback image
                self.imageView.image = UIImage(systemName: "photo")
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.tintColor = .systemGray3
                self.stopShimmerAnimation()
            }
        } else {
            // If none of the above worked, use system photo icon
            self.imageView.image = UIImage(systemName: "photo")
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.tintColor = .systemGray3
            self.stopShimmerAnimation()
        }
    }
    
    private func loadImageFromURL(imageUrl: String) {
        // Cancel any previous loading task
        imageLoadTask?.cancel()
        
        guard let url = URL(string: imageUrl) else {
            // Invalid URL, show fallback image
            self.imageView.image = UIImage(systemName: "photo")
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.tintColor = .systemGray3
            self.stopShimmerAnimation()
            return
        }
        
        // Create loading task
        imageLoadTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self, 
                      error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    // Error loading image, show fallback
                    self?.imageView.image = UIImage(systemName: "photo")
                    self?.imageView.contentMode = .scaleAspectFit
                    self?.imageView.tintColor = .systemGray3
                    self?.stopShimmerAnimation()
                    return
                }
                
                // Successfully loaded image
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = image
                
                // Fade in image
                UIView.animate(withDuration: 0.3) {
                    self.stopShimmerAnimation()
                }
            }
        }
        
        // Start the task
        imageLoadTask?.resume()
    }
}
