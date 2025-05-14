import UIKit
import Supabase

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

        // Save Button in Navbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))

        // Bite Name Label
        let biteNameLabel = UILabel()
        biteNameLabel.text = "Name the Bites"
        biteNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Bite Name TextField - Clean Pill Shape
        configureMinimalistTextField(biteNameTextField)
        biteNameTextField.placeholder = "Enter bite name"

        // Container for meal selection - Clean Pill Shape
        let mealContainer = UIView()
        mealContainer.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        mealContainer.layer.cornerRadius = 16
        mealContainer.clipsToBounds = true
        mealContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Meal Selection Label
        mealSelectionLabel.text = "No meal selected"
        mealSelectionLabel.textColor = .gray
        mealSelectionLabel.textAlignment = .center
        mealSelectionLabel.font = UIFont.systemFont(ofSize: 16)
        mealSelectionLabel.translatesAutoresizingMaskIntoConstraints = false
        mealContainer.addSubview(mealSelectionLabel)
        
        // Meal Selection Container Constraints
        NSLayoutConstraint.activate([
            mealSelectionLabel.topAnchor.constraint(equalTo: mealContainer.topAnchor, constant: 12),
            mealSelectionLabel.leadingAnchor.constraint(equalTo: mealContainer.leadingAnchor, constant: 16),
            mealSelectionLabel.trailingAnchor.constraint(equalTo: mealContainer.trailingAnchor, constant: -16),
            mealSelectionLabel.bottomAnchor.constraint(equalTo: mealContainer.bottomAnchor, constant: -12)
        ])

        // Choose Meal Button
        chooseMealButton.setTitle("Choose Meal", for: .normal)
        chooseMealButton.setTitleColor(.systemBlue, for: .normal)
        chooseMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        chooseMealButton.addTarget(self, action: #selector(chooseMealTapped), for: .touchUpInside)
        
        // No underline or decoration for the button
        chooseMealButton.titleLabel?.attributedText = nil

        // Start Time Label
        let startLabel = UILabel()
        startLabel.text = "Start Time"
        startLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Configure Time Pickers - Clean style
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.addTarget(self, action: #selector(startTimeChanged(_:)), for: .valueChanged)
        configureMinimalistTimePicker(startTimePicker)

        // End Time Label
        let endLabel = UILabel()
        endLabel.text = "End Time"
        endLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.addTarget(self, action: #selector(endTimeChanged(_:)), for: .valueChanged)
        configureMinimalistTimePicker(endTimePicker)
        
        // Simple stack view with proper spacing
        let stackView = UIStackView(arrangedSubviews: [
            biteNameLabel, 
            biteNameTextField,
            mealContainer, 
            chooseMealButton,
            startLabel, 
            startTimePicker,
            endLabel, 
            endTimePicker
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.setCustomSpacing(8, after: biteNameLabel)
        stackView.setCustomSpacing(4, after: mealContainer)
        stackView.setCustomSpacing(24, after: chooseMealButton)
        stackView.setCustomSpacing(8, after: startLabel)
        stackView.setCustomSpacing(24, after: startTimePicker)
        stackView.setCustomSpacing(8, after: endLabel)
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Constraints - match the second image spacing
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            biteNameTextField.heightAnchor.constraint(equalToConstant: 50),
            mealContainer.heightAnchor.constraint(equalToConstant: 50),
            startTimePicker.heightAnchor.constraint(equalToConstant: 110),
            endTimePicker.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    // Helper method for minimalist text fields
    private func configureMinimalistTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        
        // Add padding to the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    // Helper method for minimalist time picker appearance
    private func configureMinimalistTimePicker(_ picker: UIDatePicker) {
        // Style the time picker to match the second image
        picker.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        picker.layer.cornerRadius = 16
        picker.clipsToBounds = true
        
        // Subtle tint color
        picker.tintColor = .systemBlue
        
        // No borders or shadow effects
        picker.layer.borderWidth = 0
        picker.layer.shadowOpacity = 0
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
        // Create a meal selection view controller to show all available meals
        let mealSelectionVC = MealSelectionViewController()
        
        // Get all meals from all categories in the data source
        var allMeals: [FeedingMeal] = []
        
        // Add meals from each bite type
        for category in BiteType.predefinedCases {
            // Get meals for all regions and selected age group
            for region in RegionType.allCases {
                let meals = BiteSampleData.shared.getItems(for: category, in: region, for: .months12to15)
                allMeals.append(contentsOf: meals)
            }
        }
        
        // Add user-added meals if any
        allMeals.append(contentsOf: BiteSampleData.shared.userAddedMeals)
        
        // Remove duplicates (if any meals appear in multiple regions)
        var uniqueMeals: [FeedingMeal] = []
        var mealNames = Set<String>()
        
        for meal in allMeals {
            if !mealNames.contains(meal.name) {
                uniqueMeals.append(meal)
                mealNames.insert(meal.name)
            }
        }
        
        // Setup the meal selection view controller
        mealSelectionVC.allMeals = uniqueMeals
        mealSelectionVC.onMealSelected = { [weak self] selectedMeal in
            self?.selectedMeal = selectedMeal
            self?.mealSelectionLabel.text = "Selected: \(selectedMeal.name)"
            self?.mealSelectionLabel.textColor = .black
        }
        
        // Present the meal selection view
        navigationController?.pushViewController(mealSelectionVC, animated: true)
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
            image: meal.image_url,
            category: newBiteType,
            region: meal.region,
            ageGroup: meal.ageGroup
        )

        let timeInterval = "\(startTime) - \(endTime)"

        print("✅ Save tapped, new meal: \(newItem.name) with category: \(newBiteType.rawValue), Time: \(timeInterval)")

        onSave?(newItem, timeInterval)
        
        // Save to Supabase my_Bowl table
        Task {
            // Get client from SceneDelegate
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                await SupabaseManager.saveToMyBowlDatabase(newItem, using: sceneDelegate.supabase)
            }
        }

        showAlert(title: "🎉 Success", message: "\"\(newItem.name)\" has been added to MyBowl!")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
