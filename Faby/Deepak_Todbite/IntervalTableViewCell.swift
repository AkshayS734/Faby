import UIKit

// ✅ Define the Protocol
protocol SectionExpandableDelegate: AnyObject {
    func didTapExpandCollapse(for section: Int)
}

class IntervalTableViewCell: UITableViewCell {
    
    weak var delegate: SectionExpandableDelegate?
    private var sectionIndex: Int = 0  // Track section index

    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(sectionLabel)
        contentView.addSubview(expandButton)
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sectionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            expandButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            expandButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        expandButton.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)
    }

    func configure(with title: String, isExpanded: Bool, section: Int) {
        sectionLabel.text = title
        expandButton.setImage(UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down"), for: .normal)
        sectionIndex = section
    }

    @objc private func toggleSection() {
        delegate?.didTapExpandCollapse(for: sectionIndex)
    }
}
