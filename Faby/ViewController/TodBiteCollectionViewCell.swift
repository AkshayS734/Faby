import UIKit

// Define the delegate protocol
protocol TodBiteCollectionViewCellDelegate: AnyObject {
    func didTapAddButton(for item: Item, in category: CategoryType)
}

import UIKit

class TodBiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    private let addButton = UIButton(type: .system)

    weak var delegate: TodBiteCollectionViewCellDelegate?

    private var currentItem: Item?
    private var currentCategory: CategoryType?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // Configure Image View
        myImageView.layer.cornerRadius = 12
        myImageView.layer.masksToBounds = true
        myImageView.contentMode = .scaleAspectFill

        // Configure Food Name Label
        foodNameLabel.font = UIFont.boldSystemFont(ofSize: 12) // Bold font for title
        foodNameLabel.textAlignment = .left
        foodNameLabel.textColor = .black
        foodNameLabel.lineBreakMode = .byTruncatingTail // Truncate text with ellipses
        foodNameLabel.numberOfLines = 1 // Restrict to one line

        // Configure Nutrition Label
        nutritionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular) // Regular font for description
        nutritionLabel.textAlignment = .left
        nutritionLabel.textColor = .darkGray
        nutritionLabel.lineBreakMode = .byTruncatingTail // Truncate text with ellipses
        nutritionLabel.numberOfLines = 1 // Restrict to one line

        setupAddButton()
        setupConstraints()
    }

    private func setupAddButton() {
        addButton.setImage(UIImage(systemName: "plus.square.fill"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 15
        addButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor, constant: -5),
            addButton.bottomAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: -5),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        foodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        myImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(foodNameLabel)
        contentView.addSubview(nutritionLabel)

        NSLayoutConstraint.activate([
            // Image View Constraints
            myImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            myImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            myImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            myImageView.heightAnchor.constraint(equalTo: myImageView.widthAnchor),

            // Food Name Label Constraints
            foodNameLabel.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 8),
            foodNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Nutrition Label Constraints with Minimal Spacing
            nutritionLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 1), // Reduced to 1 point
            nutritionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nutritionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nutritionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }


    func configure(with item: Item, category: CategoryType) {
        self.currentItem = item
        self.currentCategory = category

        foodNameLabel.text = item.name
        nutritionLabel.text = item.description
        myImageView.image = UIImage(named: item.image)
    }

    @objc private func addButtonTapped() {
        guard let item = currentItem, let category = currentCategory else { return }
        delegate?.didTapAddButton(for: item, in: category)
    }
}
