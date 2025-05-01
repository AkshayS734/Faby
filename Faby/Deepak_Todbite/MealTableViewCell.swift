import UIKit

class MealTableViewCell: UITableViewCell {

 
    let mealImageView = UIImageView()
    let mealNameLabel = UILabel()
    let mealDetailsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.clipsToBounds = true
        mealImageView.layer.cornerRadius = 8
        mealImageView.translatesAutoresizingMaskIntoConstraints = false

       
        mealNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        mealNameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Details label for category and region
        mealDetailsLabel.font = UIFont.systemFont(ofSize: 12)
        mealDetailsLabel.textColor = .darkGray
        mealDetailsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create vertical stack for name and details
        let textStackView = UIStackView(arrangedSubviews: [mealNameLabel, mealDetailsLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        textStackView.alignment = .leading
     
        // Main horizontal stack with image and text stack
        let mainStackView = UIStackView(arrangedSubviews: [mealImageView, textStackView])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 10
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 50),
            mealImageView.heightAnchor.constraint(equalToConstant: 50),
            
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with meal: FeedingMeal) {
        mealImageView.image = UIImage(named: meal.image)
        mealNameLabel.text = meal.name
        mealDetailsLabel.text = "\(meal.category.rawValue) • \(meal.region.rawValue) Region"
    }
}
