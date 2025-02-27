import UIKit

class DateCell: UICollectionViewCell {
    static let identifier = "DateCell"

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium) // ✅ Adjusted font
        label.numberOfLines = 1 // ✅ Prevent overlapping
        label.minimumScaleFactor = 0.7 // ✅ Allows text to shrink if needed
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dateLabel)
        contentView.backgroundColor = UIColor.systemGray5 // ✅ Better UI
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        contentView.layer.cornerRadius = 10 // ✅ Rounded edges
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with dateText: String) {
        dateLabel.text = dateText
    }
}
