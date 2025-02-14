import UIKit

class MilestoneCardCell: UICollectionViewCell {
    static let identifier = "MilestoneCardCell"
    
    private let milestoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
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
            milestoneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            milestoneImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            milestoneImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            milestoneImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: milestoneAchievedMark.leadingAnchor, constant: -8),
            
            queryLabel.leadingAnchor.constraint(equalTo: milestoneImageView.trailingAnchor, constant: 16),
            queryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            queryLabel.trailingAnchor.constraint(lessThanOrEqualTo: milestoneAchievedMark.leadingAnchor, constant: -8),
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
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if milestoneImageView.bounds.width > 0 && milestoneImageView.bounds.height > 0 {
            applyLeftSideCornerRadius()
        }
    }
    
    private func applyLeftSideCornerRadius() {
        let cornerRadius: CGFloat = 8
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: milestoneImageView.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: milestoneImageView.bounds.width, y: milestoneImageView.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: milestoneImageView.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi / 2, clockwise: true)
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        milestoneImageView.layer.mask = shapeLayer
        milestoneImageView.clipsToBounds = false
    }
    
    func configure(with milestone: GrowthMilestone) {
        milestoneImageView.image = UIImage(named: milestone.image)
        titleLabel.text = milestone.subtitle
        queryLabel.text = milestone.query
        
        if milestone.isAchieved {
            milestoneAchievedMark.isHidden = false
            chevronButton.isHidden = true
        } else {
            milestoneAchievedMark.isHidden = true
            chevronButton.isHidden = false
        }
    }
}
