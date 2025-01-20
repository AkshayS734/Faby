import UIKit
class MilestoneCardCell: UICollectionViewCell {
    static let identifier = "MilestoneCardCell"
    
    private let milestoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let queryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // Prevents it from being squished horizontally
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal) // Prevents it from being stretched horizontally
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.right")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(milestoneImageView)
        contentView.addSubview(queryLabel)
        contentView.addSubview(chevronButton)
        contentView.backgroundColor = .white
        // Layout
        milestoneImageView.translatesAutoresizingMaskIntoConstraints = false
        queryLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            milestoneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            milestoneImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            milestoneImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            milestoneImageView.widthAnchor.constraint(equalToConstant: 100),  // Set width explicitly or use proportional sizing
            
            queryLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 16),
            queryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            queryLabel.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor, constant: -8),
                
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            chevronButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronButton.widthAnchor.constraint(equalToConstant: 20),
            chevronButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with milestone: GrowthMilestone) {
//        print("\(milestone.image)")
//        print("\(milestone.query)")
        milestoneImageView.image = UIImage(named: milestone.image)
        queryLabel.text = milestone.query
    }
}
