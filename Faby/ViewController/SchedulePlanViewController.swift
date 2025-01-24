import UIKit

class SchedulePlanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - UI Components
    private let tableView = UITableView()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)

    // MARK: - Data
    var selectedItems: [Item] = []
    private var scheduleStartDate: Date?
    private var scheduleEndDate: Date?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Schedule Plan"

        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure Date Picker
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        view.addSubview(datePicker)

        // Configure Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        // Configure Save Button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Plan", for: .normal)
        saveButton.addTarget(self, action: #selector(savePlanTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        // Add Constraints
        NSLayoutConstraint.activate([
            // Date Picker
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Table View
            tableView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),

            // Save Button
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Table View DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = selectedItems[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.description
        return cell
    }

    // MARK: - Actions
    @objc private func savePlanTapped() {
        scheduleStartDate = datePicker.date
        scheduleEndDate = Calendar.current.date(byAdding: .day, value: 6, to: datePicker.date)

        guard let startDate = scheduleStartDate, let endDate = scheduleEndDate else {
            showErrorAlert(message: "Please select a valid date range.")
            return
        }

        // Save the schedule
        let schedule = MealSchedule(startDate: startDate, endDate: endDate, meals: selectedItems)
        saveSchedule(schedule)

        // Show success message
        let alert = UIAlertController(title: "Success", message: "Your plan has been scheduled from \(formattedDate(startDate)) to \(formattedDate(endDate)).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Helper Methods
    private func saveSchedule(_ schedule: MealSchedule) {
        // Save logic (e.g., UserDefaults, CoreData, etc.)
        print("Schedule saved: \(schedule)")
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

