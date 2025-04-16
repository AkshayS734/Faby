import UIKit

class DateCell: UICollectionViewCell {
    static let identifier = "DateCell"

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dateLabel)
        contentView.backgroundColor = UIColor.white
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

 
    func configure(with dateText: String, isSelected: Bool, hasPlan: Bool) {
        dateLabel.text = dateText

        if isSelected {
            contentView.backgroundColor = UIColor.systemOrange
            dateLabel.textColor = .white
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
        } else {
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.layer.cornerRadius = 10
            dateLabel.textColor = .black
        }
    }

}
