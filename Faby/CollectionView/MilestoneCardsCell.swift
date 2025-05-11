import UIKit

class MilestoneCardCell: UICollectionViewCell {
    static let identifier = "MilestoneCardCell"
    
    private let milestoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let queryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.right")
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    var milestoneAchievedMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(milestoneImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(queryLabel)
        contentView.addSubview(milestoneAchievedMark)
        contentView.addSubview(chevronButton)
        contentView.backgroundColor = .white
        
        milestoneImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        queryLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        milestoneAchievedMark.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            milestoneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            milestoneImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            milestoneImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            milestoneImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: milestoneAchievedMark.leadingAnchor, constant: -8),
            
            queryLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 16),
            queryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            queryLabel.trailingAnchor.constraint(lessThanOrEqualTo: milestoneAchievedMark.leadingAnchor, constant: -15),
            queryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            milestoneAchievedMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            milestoneAchievedMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            milestoneAchievedMark.widthAnchor.constraint(equalToConstant: 25),
            milestoneAchievedMark.heightAnchor.constraint(equalToConstant: 25),
            
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            chevronButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronButton.widthAnchor.constraint(equalToConstant: 20),
            chevronButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(with milestone: GrowthMilestone) {
//        milestoneImageView.image = UIImage(named: milestone.image)
        titleLabel.text = milestone.subtitle
        queryLabel.text = milestone.query
        milestoneAchievedMark.isHidden = !milestone.isAchieved
        chevronButton.isHidden = milestone.isAchieved
        let imagePath = milestone.image
//        print("📦 Attempting to load path: \(imagePath)")

        SupabaseManager.shared.loadImageFromPublicBucket(
            path: imagePath,
            bucket: "milestone-images"
        ) { [weak self] image in
            DispatchQueue.main.async {
                self?.milestoneImageView.image = image
            }
        }
    }
}
