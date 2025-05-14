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
        
        // Check if this cell represents today
        let isToday = dateText == getFormattedTodayDate()
        
        if isSelected || isToday {
            // Use a more vibrant blue for today's date
            contentView.backgroundColor = isToday ? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0) : UIColor.systemBlue
            dateLabel.textColor = .white
            contentView.layer.cornerRadius = 10
            contentView.layer.masksToBounds = true
            
            // Make today's date stand out more with a slight shadow
            if isToday {
                contentView.layer.shadowColor = UIColor.black.cgColor
                contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
                contentView.layer.shadowRadius = 4
                contentView.layer.shadowOpacity = 0.3
                contentView.layer.masksToBounds = false
            }
        } else {
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.layer.cornerRadius = 10
            dateLabel.textColor = .black
            contentView.layer.shadowOpacity = 0
        }
    }
    
    // Helper method to get today's formatted date string
    private func getFormattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        return formatter.string(from: Date())
    }

}
