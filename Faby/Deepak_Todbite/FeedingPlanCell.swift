import UIKit

class FeedingPlanCell: UITableViewCell {
    // MARK: - UI Elements
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let mealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let mealNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Light gray background
        selectionStyle = .none // Disable selection highlight
        
        // Add card view to content view
        contentView.addSubview(cardView)
        
        // Add image view constraints
        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 60),
            mealImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add subviews to stack view
        contentStackView.addArrangedSubview(mealImageView)
        contentStackView.addArrangedSubview(mealNameLabel)
        
        // Add stack view to card view
        cardView.addSubview(contentStackView)
        
        // Add card view constraints
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Add stack view constraints within card view
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configuration
    func configure(with meal: FeedingMeal) {
        // Always set the name first
        mealNameLabel.text = meal.name
        
        // Set placeholder image
        mealImageView.image = UIImage(named: "placeholder")
        
        // Load the image
        if !meal.image_url.isEmpty {
            if let url = URL(string: meal.image_url), meal.image_url.lowercased().hasPrefix("http") {
                // Remote URL
                URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                    guard let self = self else { return }
                    
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.mealImageView.image = image
                        }
                    } else {
                        print("❌ Error loading image from URL: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }.resume()
            } else {
                // Local asset
                if let localImage = UIImage(named: meal.image_url) {
                    mealImageView.image = localImage
                } else {
                    print("❌ Could not find local image named: \(meal.image_url)")
                }
            }
        }
    }
}
