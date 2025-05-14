import UIKit

class TodBiteTableViewCell: UITableViewCell {
    
    let itemImageView = UIImageView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let moreOptionsButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Create card container view
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Configure itemImageView
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(itemImageView)
        
        // Configure nameLabel - cleaner font style from second image
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // Configure descriptionLabel - lighter font style from second image
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descriptionLabel)
        
        // Configure moreOptionsButton
        moreOptionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreOptionsButton.tintColor = .darkGray
        moreOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(moreOptionsButton)
        
        // Apply card view constraints
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Add constraints for the elements inside the card
        NSLayoutConstraint.activate([
            // itemImageView Constraints
            itemImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // nameLabel Constraints
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: moreOptionsButton.leadingAnchor, constant: -8),
            
            // descriptionLabel Constraints
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            // moreOptionsButton Constraints
            moreOptionsButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            moreOptionsButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            moreOptionsButton.widthAnchor.constraint(equalToConstant: 24),
            moreOptionsButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Set the background color of the content view to match the screenshot
        contentView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        self.selectionStyle = .none // Disable the selection highlighting
    }
    
    func configure(with item: FeedingMeal) {
        if let url = URL(string: item.image_url) {
                    // Show a placeholder while loading
            itemImageView.image = UIImage(named: "placeholder")
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.itemImageView.image = image
                            }
                        }
                    }.resume()
                } else {
                    itemImageView.image = UIImage(named: "placeholder")
                }
        nameLabel.text = item.name
        descriptionLabel.text = item.description
    }
}
