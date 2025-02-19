import UIKit

protocol IntervalTableViewCellDelegate: AnyObject {
    func didTapAddButton(for interval: String, isSelected: Bool)
}

class IntervalTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let intervalLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var currentInterval: String?
    weak var delegate: IntervalTableViewCellDelegate?
    private var isSelectedInterval: Bool = false // State of the button

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(intervalLabel)
        contentView.addSubview(actionButton)

        // Configure Label
        intervalLabel.font = UIFont.systemFont(ofSize: 16)
        intervalLabel.textColor = .black

        // Configure Button
        actionButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        actionButton.tintColor = .systemBlue
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        // Constraints
        NSLayoutConstraint.activate([
            intervalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            intervalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.widthAnchor.constraint(equalToConstant: 30),
            actionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - Configure Cell
    func configure(with interval: String, isSelected: Bool) {
        currentInterval = interval
        intervalLabel.text = interval
        isSelectedInterval = isSelected
        updateButtonState()
    }

    // MARK: - Button State
    private func updateButtonState() {
        let buttonImage = isSelectedInterval ? "checkmark.circle" : "plus.circle"
        actionButton.setImage(UIImage(systemName: buttonImage), for: .normal)
    }

    // MARK: - Button Action
    @objc private func actionButtonTapped() {
        guard let interval = currentInterval else { return }
        isSelectedInterval.toggle() // Toggle the state
        updateButtonState()
        delegate?.didTapAddButton(for: interval, isSelected: isSelectedInterval)
    }
}
