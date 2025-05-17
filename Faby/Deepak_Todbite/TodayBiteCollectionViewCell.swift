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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        // Add shadow to text labels for better visibility
        [titleLabel, mealTypeLabel, timeLabel].forEach { label in
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOffset = CGSize(width: 0, height: 2)
            label.layer.shadowRadius = 4
            label.layer.shadowOpacity = 0.7
            label.layer.masksToBounds = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add card view to content view
        contentView.addSubview(cardView)
        
        // Add components to card view
        cardView.addSubview(imageView)
        cardView.addSubview(overlayView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(mealTypeLabel)
        cardView.addSubview(timeLabel)

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

            // Title label centered on the image
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Meal type label below title
            mealTypeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            mealTypeLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            mealTypeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            mealTypeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Time label below meal type
            timeLabel.topAnchor.constraint(equalTo: mealTypeLabel.bottomAnchor, constant: 4),
            timeLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with bite: TodayBite) {
        // Set the meal title
        titleLabel.text = bite.title
        
        // Set the meal type (display category name)
        if let category = bite.category {
            mealTypeLabel.text = category
            
            // All text is white when overlaid on image
            mealTypeLabel.textColor = .white
        } else {
            mealTypeLabel.text = ""
        }
        
        // Set the time range
        timeLabel.text = bite.time
        
        // Set a placeholder image while loading
        imageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        
        let imageName = bite.imageName
        
        // Handle different image source types
        if let image = UIImage(named: imageName) {
            // Local asset case
            imageView.image = image
        } else if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            // URL case - load asynchronously
            loadImageFromURL(imageUrl: imageName)
        } else if imageName.contains("/") {
            // Local file path case
            if let image = UIImage(contentsOfFile: imageName) {
                imageView.image = image
            }
        } else {
            // If none of the above worked, keep the placeholder
            imageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        }
    }
    
    private func loadImageFromURL(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        task.resume()
    }
}
