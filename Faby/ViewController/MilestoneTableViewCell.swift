import UIKit

class MilestoneTableViewCell: UITableViewCell {
    private let milestoneImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        milestoneImageView.contentMode = .scaleAspectFill
        milestoneImageView.layer.cornerRadius = 8
        milestoneImageView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 1
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        dateLabel.numberOfLines = 1
        
        let stackView = UIStackView(arrangedSubviews: [milestoneImageView, titleLabel, dateLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            milestoneImageView.widthAnchor.constraint(equalToConstant: 50),
            milestoneImageView.heightAnchor.constraint(equalTo: milestoneImageView.widthAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with milestone: GrowthMilestone, achievedDate: Date? = nil) {
        titleLabel.text = milestone.title
        
        if let date = achievedDate {
            dateLabel.text = "Achieved on \(date.formatted(date: .abbreviated, time: .omitted))"
        } else {
            dateLabel.text = "Not yet achieved"
        }
        
        if let userImagePath = milestone.userImagePath,
           let userImage = UIImage(contentsOfFile: userImagePath) {
            milestoneImageView.image = userImage
        } else {
            milestoneImageView.image = UIImage(named: milestone.image) ?? UIImage(named: "defaultMilestone")
        }
    }
}
