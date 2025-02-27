import UIKit

class CreateCustomBiteViewController: UIViewController {

    // UI Elements
    let biteNameTextField = UITextField()
    let mealSelectionLabel = UILabel()
    let chooseMealButton = UIButton(type: .system)
    let startTimePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    
    var onSave: ((FeedingMeal, String) -> Void)?
    var selectedMeal: FeedingMeal?
    var selectedStartTime: String?
    var selectedEndTime: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Create Custom Bite"

        // Save Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))

        // Bite Name Label
        let biteNameLabel = UILabel()
        biteNameLabel.text = "Name the Bites"
        biteNameLabel.font = UIFont.boldSystemFont(ofSize: 16)

        // Bite Name TextField
        biteNameTextField.borderStyle = .roundedRect
        biteNameTextField.placeholder = "Enter bite name"

        // Meal Selection Label
        mealSelectionLabel.text = "No meal selected"
        mealSelectionLabel.textColor = .gray
        mealSelectionLabel.textAlignment = .center
        mealSelectionLabel.font = UIFont.systemFont(ofSize: 14)

        // Choose Meal Button
        chooseMealButton.setTitle("Choose Meal", for: .normal)
        chooseMealButton.setTitleColor(.systemBlue, for: .normal)
        chooseMealButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        chooseMealButton.addTarget(self, action: #selector(chooseMealTapped), for: .touchUpInside)

        // Start Time Picker
        let startLabel = UILabel()
        startLabel.text = "Start Time"
        startLabel.font = UIFont.boldSystemFont(ofSize: 16)

        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.addTarget(self, action: #selector(startTimeChanged(_:)), for: .valueChanged)

        // End Time Picker
        let endLabel = UILabel()
        endLabel.text = "End Time"
        endLabel.font = UIFont.boldSystemFont(ofSize: 16)

        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.addTarget(self, action: #selector(endTimeChanged(_:)), for: .valueChanged)

        // Apply Button (Looks more iOS-native)
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        // StackView for layout
        let stackView = UIStackView(arrangedSubviews: [
            biteNameLabel, biteNameTextField,
            mealSelectionLabel, chooseMealButton,
            startLabel, startTimePicker,
            endLabel, endTimePicker,
            applyButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            startTimePicker.heightAnchor.constraint(equalToConstant: 100),
            endTimePicker.heightAnchor.constraint(equalToConstant: 100),

            applyButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc private func startTimeChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        selectedStartTime = formatter.string(from: sender.date)
    }

    @objc private func endTimeChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        selectedEndTime = formatter.string(from: sender.date)
    }

    @objc private func chooseMealTapped() {
        let mealListVC = MealListViewController()
        mealListVC.onMealSelected = { [weak self] meal in
            self?.selectedMeal = meal
            self?.mealSelectionLabel.text = "Selected: \(meal.name)"
            self?.mealSelectionLabel.textColor = .black
        }
        navigationController?.pushViewController(mealListVC, animated: true)
    }

    @objc private func saveTapped() {
        guard let biteName = biteNameTextField.text, !biteName.isEmpty,
              let meal = selectedMeal,
              let startTime = selectedStartTime,
              let endTime = selectedEndTime else {
            showAlert(title: "⚠️ Error", message: "Please fill all fields!")
            return
        }

        let newBiteType = BiteType.custom(biteName)
        let newItem = FeedingMeal(
            name: meal.name,
            description: meal.description,
            image: meal.image,
            category: newBiteType,
            region: meal.region,
            ageGroup: meal.ageGroup
        )

        let timeInterval = "\(startTime) - \(endTime)"

        print("✅ Save tapped, new meal: \(newItem.name) with category: \(newBiteType.rawValue), Time: \(timeInterval)")

        onSave?(newItem, timeInterval)

        showAlert(title: "🎉 Success", message: "\"\(newItem.name)\" has been added to MyBowl!")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
