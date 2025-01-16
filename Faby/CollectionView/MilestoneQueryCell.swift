import UIKit

class MilestoneQueryCell: UICollectionViewCell {
    
    static let identifier = "MilestoneQueryCell"
    
    private let milestoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let queryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .gray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(milestoneImageView)
        contentView.addSubview(queryLabel)
        contentView.addSubview(chevronImageView)
        
        milestoneImageView.translatesAutoresizingMaskIntoConstraints = false
        queryLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            milestoneImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            milestoneImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor),
            milestoneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            queryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            queryLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 10),
            queryLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -10),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with milestone: GrowthMilestone) {
        milestoneImageView.image = UIImage(named: milestone.image)
        queryLabel.text = milestone.query
    }
}

