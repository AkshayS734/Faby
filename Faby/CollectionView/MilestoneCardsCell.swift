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

    private let queryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
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

        milestoneImageView.translatesAutoresizingMaskIntoConstraints = false
        queryLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            milestoneImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            milestoneImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            milestoneImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            milestoneImageView.widthAnchor.constraint(equalToConstant: 80),
            
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
//        print("\(milestone.image)")
//        print("\(milestone.query)")
        milestoneImageView.image = UIImage(named: milestone.image)
        queryLabel.text = milestone.query
        layoutIfNeeded()
        applyLeftSideCornerRadius()
    }
}
