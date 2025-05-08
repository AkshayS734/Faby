import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let selectionIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        contentView.addSubview(containerView)
        
        // Icon Image View
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold) // Larger, bolder font
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Selection Indicator
        selectionIndicator.backgroundColor = .systemBlue
        selectionIndicator.layer.cornerRadius = 3
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicator.isHidden = true
        containerView.addSubview(selectionIndicator)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            
            selectionIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            selectionIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 20),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 6),
            selectionIndicator.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with title: String, iconName: String, color: UIColor, isSelected: Bool) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        
        // Get a darker version of the color for better text contrast
        let textColor = getDarkerColor(from: color)
        
        // Apply color to the cell
        containerView.backgroundColor = color.withAlphaComponent(0.15)
        iconImageView.tintColor = textColor
        titleLabel.textColor = textColor
        selectionIndicator.backgroundColor = textColor
        
        // Handle selection state
        selectionIndicator.isHidden = !isSelected
        
        if isSelected {
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = textColor.cgColor
            containerView.backgroundColor = color.withAlphaComponent(0.25)
        } else {
            containerView.layer.borderWidth = 0
            containerView.backgroundColor = color.withAlphaComponent(0.15)
        }
    }
    
    // Helper method to get a darker version of a color for better text contrast
    private func getDarkerColor(from color: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        // Make the color darker and more saturated for better visibility
        return UIColor(hue: h, saturation: min(s + 0.3, 1.0), brightness: max(b - 0.3, 0.2), alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
        selectionIndicator.isHidden = true
        containerView.layer.borderWidth = 0
    }
}
