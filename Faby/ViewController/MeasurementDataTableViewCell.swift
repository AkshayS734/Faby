import UIKit
class MeasurementDataTableViewCell: UITableViewCell {
    private let valueLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [valueLabel, dateLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(value: Double, unit: String, date: Date) {
        valueLabel.text = "\(String(format: "%.2f", value)) \(unit)"
        dateLabel.text = formatDate(date)
    }
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM, yyyy"
    return formatter.string(from: date)
}
