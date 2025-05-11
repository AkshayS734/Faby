import UIKit


class FeedingHistoryCell: UITableViewCell {
    
    private let mealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func configure(category: String, time: String, foodName: String, imageName: String) {
        titleLabel.text = foodName
        subtitleLabel.text = "\(category) - \(time)"
        
        // First try loading as a local asset
        if let image = UIImage(named: imageName) {
            mealImageView.image = image
            setupUI()
            return
        }
        
        // Then try loading from URL if it looks like a URL
        if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            loadImageFromURL(imageUrlString: imageName)
        } else if imageName.contains("/") {
            // Might be a local file path
            if let image = UIImage(contentsOfFile: imageName) {
                mealImageView.image = image
            } else {
                mealImageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
            }
        } else {
            // Default placeholder
            mealImageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        }
        
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(mealImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            mealImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            mealImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mealImageView.widthAnchor.constraint(equalToConstant: 50),
            mealImageView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 10),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func loadImageFromURL(imageUrlString: String) {
        // Show a placeholder or loading indicator while fetching
        mealImageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        
        guard let url = URL(string: imageUrlString) else { return }
        
        // Create a URLSession task to fetch the image
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.mealImageView.image = image
            }
        }
        
        task.resume()
    }
}

