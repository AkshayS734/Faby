import UIKit

protocol IntervalSelectionCellDelegate: AnyObject {
    func didUpdateIntervals(for itemName: String, selectedIntervals: [String])
}

class IntervalSelectionCell: UITableViewCell {

    weak var delegate: IntervalSelectionCellDelegate?

    private let itemNameLabel = UILabel()
    private var intervalButtons: [UIButton] = []
    private var selectedIntervals: [String] = []
    private var itemName: String = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemNameLabel)

        NSLayoutConstraint.activate([
            itemNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            itemNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with itemName: String, intervals: [String], selectedIntervals: [String]) {
        self.itemName = itemName
        self.selectedIntervals = selectedIntervals
        itemNameLabel.text = itemName

        // Clear previous buttons
        intervalButtons.forEach { $0.removeFromSuperview() }
        intervalButtons.removeAll()

        // Add interval buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        intervals.forEach { interval in
            let button = UIButton(type: .system)
            button.setTitle(interval, for: .normal)
            button.backgroundColor = selectedIntervals.contains(interval) ? .systemBlue : .lightGray
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(intervalTapped(_:)), for: .touchUpInside)
            intervalButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @objc private func intervalTapped(_ sender: UIButton) {
        guard let interval = sender.title(for: .normal) else { return }

        if selectedIntervals.contains(interval) {
            selectedIntervals.removeAll { $0 == interval }
            sender.backgroundColor = .lightGray
        } else {
            selectedIntervals.append(interval)
            sender.backgroundColor = .systemBlue
        }

        delegate?.didUpdateIntervals(for: itemName, selectedIntervals: selectedIntervals)
    }
}
