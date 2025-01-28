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
        // Configure itemImageView
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemImageView)

        // Configure nameLabel
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        // Configure descriptionLabel
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Configure moreOptionsButton
        moreOptionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreOptionsButton.tintColor = .darkGray
        moreOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moreOptionsButton)

        // Add constraints
        NSLayoutConstraint.activate([
            // itemImageView Constraints
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),

            // nameLabel Constraints
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: moreOptionsButton.leadingAnchor, constant: -8),

            // descriptionLabel Constraints
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // moreOptionsButton Constraints
            moreOptionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreOptionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moreOptionsButton.widthAnchor.constraint(equalToConstant: 24),
            moreOptionsButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with item: Item) {
        itemImageView.image = UIImage(named: item.image)
        nameLabel.text = item.name
        descriptionLabel.text = item.description
    }
}
