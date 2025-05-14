import UIKit

class TodayBiteCollectionViewCell: UICollectionViewCell {
    
    // Card container
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.systemGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add card view to content view
        contentView.addSubview(cardView)
        
        // Add components to card view
        cardView.addSubview(imageView)
        cardView.addSubview(mealTypeLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            // Card view constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Image view constraints - top part of card
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            // Title label (name of the meal) - now first
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            // Meal type label (NourishBite, MidDayBite, etc) - now second
            mealTypeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            mealTypeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mealTypeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            // Time label (10:00 AM - 10:30 AM) - now third
            timeLabel.topAnchor.constraint(equalTo: mealTypeLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with bite: TodayBite) {
        // Set the meal title
        titleLabel.text = bite.title
        
        // Set the meal type (display category name)
        if let category = bite.category {
            mealTypeLabel.text = category
            
            // Set appropriate color based on meal type
            switch category {
            case "NourishBite":
                mealTypeLabel.textColor = .black
            case "EarlyBite":
                mealTypeLabel.textColor = .black
            case "MidDayBite":
                mealTypeLabel.textColor = .black
            case "SnackBite":
                mealTypeLabel.textColor = .black
            case "NightBite":
                mealTypeLabel.textColor = .black
            default:
                mealTypeLabel.textColor = .black
            }
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
