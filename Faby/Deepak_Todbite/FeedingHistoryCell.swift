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
        
        if let image = UIImage(named: imageName) {
            mealImageView.image = image
        } else {
            mealImageView.image = UIImage(named: "placeholder") // ✅ Placeholder for missing images
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
}
