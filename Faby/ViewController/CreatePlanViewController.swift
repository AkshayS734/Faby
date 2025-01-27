import UIKit

class CreatePlanViewController: UIViewController {
    // MARK: - Properties
    var selectedItems: [Item] = []
    private let calendarView = UICalendarView()
    private let planTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Single Day", "Week Plan"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    private let submitButton = UIButton(type: .system)
    private let selectedDatesLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a start date"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var startDate: Date?
    private var endDate: Date?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPlanTypeSegmentedControl()
        setupCalendar()
        setupSelectedDatesLabel()
        setupSubmitButton()
    }

    // MARK: - UI Setup
    private func setupPlanTypeSegmentedControl() {
        view.addSubview(planTypeSegmentedControl)

        NSLayoutConstraint.activate([
            planTypeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            planTypeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            planTypeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            planTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])

        planTypeSegmentedControl.addTarget(self, action: #selector(planTypeChanged), for: .valueChanged)
    }

    private func setupCalendar() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        view.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: planTypeSegmentedControl.bottomAnchor, constant: 16),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func setupSelectedDatesLabel() {
        view.addSubview(selectedDatesLabel)

        NSLayoutConstraint.activate([
            selectedDatesLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8),
            selectedDatesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedDatesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupSubmitButton() {
        submitButton.setTitle("Submit Plan", for: .normal)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.addTarget(self, action: #selector(submitPlan), for: .touchUpInside)
        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func planTypeChanged() {
        startDate = nil
        endDate = nil
        updateSelectedDatesLabel()
        print("Plan type changed to: \(planTypeSegmentedControl.selectedSegmentIndex == 0 ? "Single Day" : "Week Plan")")
    }

    @objc private func submitPlan() {
        guard let startDate = startDate else {
            let alert = UIAlertController(title: "Incomplete Selection", message: "Please select a start date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }

        let endDate = self.endDate ?? startDate
        print("Plan created from \(startDate) to \(endDate) with items: \(selectedItems.map { $0.name })")

        let alert = UIAlertController(
            title: "Plan Created",
            message: "Your plan has been successfully created from \(formatDate(startDate)) to \(formatDate(endDate)).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func updateSelectedDatesLabel() {
        if let start = startDate {
            if let end = endDate {
                selectedDatesLabel.text = "From: \(formatDate(start)) to \(formatDate(end))"
            } else {
                selectedDatesLabel.text = "Start: \(formatDate(start))"
            }
        } else {
            selectedDatesLabel.text = "Select a start date"
        }
    }
}

// MARK: - UICalendarViewDelegate
extension CreatePlanViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }

        if planTypeSegmentedControl.selectedSegmentIndex == 0 {
            // Single Day Plan
            startDate = date
            endDate = nil
            print("Single Day selected: \(date)")
        } else {
            // Week Plan
            startDate = date
            endDate = Calendar.current.date(byAdding: .day, value: 6, to: date)
            print("Week Plan from \(startDate!) to \(endDate!)")
        }

        updateSelectedDatesLabel()
    }
}
