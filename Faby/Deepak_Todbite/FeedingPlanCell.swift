import UIKit

class FeedingPlanCell: UITableViewCell {
    // MARK: - UI Elements
     let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        // Add image view constraints
        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 50),
            mealImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add subviews to stack view
        contentStackView.addArrangedSubview(mealImageView)
        contentStackView.addArrangedSubview(mealNameLabel)
        
        // Add stack view to content view
        contentView.addSubview(contentStackView)
        
        // Add stack view constraints
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
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
