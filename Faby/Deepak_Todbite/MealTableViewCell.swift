import UIKit

class MealTableViewCell: UITableViewCell {

    // UI Elements
    let mealImageView = UIImageView()
    let mealNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        // Configure Image View
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.clipsToBounds = true
        mealImageView.layer.cornerRadius = 8
        mealImageView.translatesAutoresizingMaskIntoConstraints = false

        // Configure Label
        mealNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        mealNameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack View for Layout
        let stackView = UIStackView(arrangedSubviews: [mealImageView, mealNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 50),
            mealImageView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with meal: FeedingMeal) {
        mealImageView.image = UIImage(named: meal.image)
        mealNameLabel.text = meal.name
    }
}
