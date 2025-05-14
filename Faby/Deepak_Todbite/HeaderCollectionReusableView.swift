import UIKit

protocol HeaderCollectionReusableViewDelegate: AnyObject {
    func didTapSectionHeader(category: String)
}

class HeaderCollectionReusableView: UICollectionReusableView {
    let headerLabel = UILabel()
    let intervalLabel = UILabel()
    let chevronImageView = UIImageView()
    
    weak var delegate: HeaderCollectionReusableViewDelegate?
    private var category: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerLabel)
        addSubview(intervalLabel)
        addSubview(chevronImageView)

        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerLabel.textColor = .black
        intervalLabel.font = UIFont.systemFont(ofSize: 12)
        intervalLabel.textColor = .darkGray
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = .black

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            intervalLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),
            intervalLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            intervalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            chevronImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            chevronImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 0),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // Add tap gesture recognizer to the entire header view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    func configure(with title: String, interval: String) {
        headerLabel.text = title
        intervalLabel.text = interval
        category = title
    }
    
    @objc private func handleTap() {
        guard let category = category else { return }
        delegate?.didTapSectionHeader(category: category)
    }
}
