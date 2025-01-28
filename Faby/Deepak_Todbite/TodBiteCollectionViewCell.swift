import UIKit

// Define the delegate protocol
protocol TodBiteCollectionViewCellDelegate: AnyObject {
    func didTapAddButton(for item: Item, in category: CategoryType)
}

class TodBiteCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    private let addButton = UIButton(type: .system)

    // MARK: - Properties
    weak var delegate: TodBiteCollectionViewCellDelegate?
    private var currentItem: Item?
    private var currentCategory: CategoryType?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellAppearance()
        setupAddButton()
        setupConstraints()
    }

    // MARK: - Cell Setup
    private func setupCellAppearance() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // Configure Image View
        myImageView.layer.cornerRadius = 12
        myImageView.layer.masksToBounds = true
        myImageView.contentMode = .scaleAspectFill

        // Configure Food Name Label
        foodNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        foodNameLabel.textAlignment = .left
        foodNameLabel.textColor = .black
        foodNameLabel.lineBreakMode = .byTruncatingTail
        foodNameLabel.numberOfLines = 1

        // Configure Nutrition Label
        nutritionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        nutritionLabel.textAlignment = .left
        nutritionLabel.textColor = .darkGray
        nutritionLabel.lineBreakMode = .byTruncatingTail
        nutritionLabel.numberOfLines = 1
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

            // Nutrition Label Constraints
            nutritionLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 1),
            nutritionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nutritionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nutritionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Configure Cell
    func configure(with item: Item, category: CategoryType, isAdded: Bool) {
        self.currentItem = item
        self.currentCategory = category

        // Update UI with item details
        foodNameLabel.text = item.name
        nutritionLabel.text = item.description
        myImageView.image = UIImage(named: item.image)

        // Update button state (Plus or Tick)
        let buttonImage = isAdded ? "checkmark.circle.fill" : "plus.square.fill"
        addButton.setImage(UIImage(systemName: buttonImage), for: .normal)
        addButton.tintColor = isAdded ? .systemGreen : .white
    }

    // MARK: - Button Action
    @objc private func addButtonTapped() {
        guard let item = currentItem, let category = currentCategory else { return }
        delegate?.didTapAddButton(for: item, in: category)
    }
}
