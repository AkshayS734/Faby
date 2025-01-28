import UIKit

class CreatePlanViewController: UIViewController {
    // MARK: - UI Components
    private let fromDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Start Date", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray6
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let toDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select End Date", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray6
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let intervalsLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Intervals"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let tableView = UITableView()
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Plan", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    var intervals = ["EarlyBite", "NourishBite", "MidDayBite", "SnackBite", "NightBite"]
    var selectedItems: [String] = []
    var selectedFromDate: Date?
    var selectedToDate: Date?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        [fromDateButton, toDateButton, intervalsLabel, tableView, submitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        // Configure TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IntervalTableViewCell.self, forCellReuseIdentifier: "IntervalCell")

        // Add constraints
        NSLayoutConstraint.activate([
            fromDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fromDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fromDateButton.widthAnchor.constraint(equalToConstant: 150),
            fromDateButton.heightAnchor.constraint(equalToConstant: 40),

            toDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toDateButton.widthAnchor.constraint(equalToConstant: 150),
            toDateButton.heightAnchor.constraint(equalToConstant: 40),

            intervalsLabel.topAnchor.constraint(equalTo: fromDateButton.bottomAnchor, constant: 20),
            intervalsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: intervalsLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),

            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add actions
        fromDateButton.addTarget(self, action: #selector(selectFromDate), for: .touchUpInside)
        toDateButton.addTarget(self, action: #selector(selectToDate), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitPlan), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func selectFromDate() {
        showDatePicker { selectedDate in
            self.selectedFromDate = selectedDate
            self.fromDateButton.setTitle(self.formatDate(selectedDate), for: .normal)
        }
    }

    @objc private func selectToDate() {
        showDatePicker { selectedDate in
            self.selectedToDate = selectedDate
            self.toDateButton.setTitle(self.formatDate(selectedDate), for: .normal)
        }
    }

    @objc private func submitPlan() {
        guard let fromDate = selectedFromDate, let toDate = selectedToDate else {
            showAlert(title: "Error", message: "Please select both start and end dates.")
            return
        }

        if selectedItems.isEmpty {
            showAlert(title: "Error", message: "Please select at least one interval.")
            return
        }

        // Combine selected intervals into a single string
        let intervalList = selectedItems.joined(separator: ", ")
        let message = """
        Your plan is set from \(formatDate(fromDate)) to \(formatDate(toDate)) for intervals: \(intervalList).
        """
        showAlert(title: "Plan Created", message: message)
    }

    private func showDatePicker(completion: @escaping (Date) -> Void) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels

        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50),
            datePicker.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -120)
        ])

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            completion(datePicker.date)
        }))

        present(alert, animated: true)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension CreatePlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath) as? IntervalTableViewCell else {
            return UITableViewCell()
        }
        let interval = intervals[indexPath.row]
        let isSelected = selectedItems.contains(interval)
        cell.configure(with: interval, isSelected: isSelected)
        cell.delegate = self
        return cell
    }
}

// MARK: - IntervalCell Delegate
extension CreatePlanViewController: IntervalTableViewCellDelegate {
    func didTapAddButton(for interval: String, isSelected: Bool) {
        if isSelected {
            selectedItems.append(interval)
        } else {
            selectedItems.removeAll { $0 == interval }
        }
        print("Selected items: \(selectedItems)")
    }
}
