import UIKit

protocol SectionItemTableViewCellDelegate: AnyObject {
    func didTapAddButton(for item: Item)
}

class SectionItemTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let itemImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let addButton = UIButton(type: .system)

    // MARK: - Properties
    weak var delegate: SectionItemTableViewCellDelegate? // Delegate reference
    private var currentItem: Item?

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure Item Image View
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        itemImageView.layer.cornerRadius = 8
        contentView.addSubview(itemImageView)

        // Configure Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)

        // Configure Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 2
        contentView.addSubview(descriptionLabel)

        // Configure Add Button
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.square.fill"), for: .normal)
        addButton.tintColor = .gray
        //
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)

        // Add Constraints
        NSLayoutConstraint.activate([
            // Item Image View Constraints
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),

            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -16),

            // Description Label Constraints
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),

            // Add Button Constraints
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - Configuration
    func configure(with item: Item) {
        currentItem = item
        itemImageView.image = UIImage(named: item.image)
        titleLabel.text = item.name
        descriptionLabel.text = item.description
    }

    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard let item = currentItem else { return }
        delegate?.didTapAddButton(for: item)
    }
}
