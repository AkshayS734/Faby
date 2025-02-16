import UIKit

class FeedingPlanCell: UITableViewCell {

    let mealImageView = UIImageView()
    let mealNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.layer.cornerRadius = 8
        mealImageView.clipsToBounds = true
        mealImageView.translatesAutoresizingMaskIntoConstraints = false

        mealNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mealNameLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mealImageView)
        contentView.addSubview(mealNameLabel)

        NSLayoutConstraint.activate([
            mealImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mealImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mealImageView.widthAnchor.constraint(equalToConstant: 50),
            mealImageView.heightAnchor.constraint(equalToConstant: 50),

            mealNameLabel.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 16),
            mealNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mealNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with meal: FeedingMeal?) {
        mealNameLabel.text = meal?.name ?? "No Meal"
        mealImageView.image = UIImage(named: meal?.name ?? "placeholder")
    }
}
