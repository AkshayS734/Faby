import UIKit

class VaccineReminderViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    let scrollView = UIScrollView()
    let contentView = UIView()
    let calendarView = UIView()
    let scheduledVaccinationsLabel = UILabel()
    let vaccinationsStackView = UIStackView()
    var vaccines: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        // Configure Navigation Bar
//        navigationItem.title = "This Month"
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        navigationItem.rightBarButtonItem = searchButton
        
        // Setup UI
        setupScrollView()
        setupCalendarView()
        setupScheduledVaccinations()
    }
    
    // MARK: - Setup Methods
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func setupCalendarView() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.backgroundColor = .systemGroupedBackground
        contentView.addSubview(calendarView)
        
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
        calendarView.addSubview(datePicker)
        
        // Set the font to match Apple's default font
            if let font = UIFont(name: "SFProText-Regular", size: 16) {
                datePicker.setValue(font, forKeyPath: "textFont")
            }
        
        NSLayoutConstraint.activate([
            // Position calendarView close to the top of the contentView
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0), // No extra margin
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 350),
            
            // Align datePicker to fill the calendarView
            datePicker.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 0),
            datePicker.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc private func didSelectDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        print("Selected Date: \(dateFormatter.string(from: selectedDate))")
        
        // Optional: Update the label or handle scheduling logic based on the selected date
    }
    private func setupScheduledVaccinations() {
        scheduledVaccinationsLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduledVaccinationsLabel.text = "Scheduled Vaccinations"
        scheduledVaccinationsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        contentView.addSubview(scheduledVaccinationsLabel)
        
        vaccinationsStackView.translatesAutoresizingMaskIntoConstraints = false
        vaccinationsStackView.axis = .vertical
        vaccinationsStackView.spacing = 10
        contentView.addSubview(vaccinationsStackView)
        
        NSLayoutConstraint.activate([
            // Position "Scheduled Vaccinations" section right below calendarView
            scheduledVaccinationsLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 10),
            scheduledVaccinationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scheduledVaccinationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            vaccinationsStackView.topAnchor.constraint(equalTo: scheduledVaccinationsLabel.bottomAnchor, constant: 10),
            vaccinationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            vaccinationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            vaccinationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    
        
        
        // Fetch the saved vaccination data from UserDefaults
        if let savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] {
            // Iterate over the saved data and add vaccination cards
            for vaccination in savedData {
                if let title = vaccination["hospital"], let date = vaccination["date"], let location = vaccination["address"] {
                    addVaccinationCard(title: title, date: date, location: location)
                }
            }
        }
    }

    private func addVaccinationCard(title: String, date: String, location: String) {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        let locationLabel = UILabel()
        locationLabel.text = location
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = .gray
        
        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.tintColor = UIColor(hex: "#0076BA") // Custom color
        checkmarkButton.addTarget(self, action: #selector(didToggleCheckmark(_:)), for: .touchUpInside)
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)
        card.addSubview(checkmarkButton)
        
        vaccinationsStackView.addArrangedSubview(card)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            
            checkmarkButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            checkmarkButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Set the button's selected state based on stored data
        if isVaccinationCompleted(title: title, date: date, location: location) {
            checkmarkButton.isSelected = true
        }
    }

    @objc private func didToggleCheckmark(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Find the vaccination info based on its card index
        guard let card = sender.superview,
              let stackView = card.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
              let titleLabel = stackView.arrangedSubviews[0] as? UILabel,
              let dateLabel = stackView.arrangedSubviews[1] as? UILabel,
              let locationLabel = stackView.arrangedSubviews[2] as? UILabel else {
            return
        }
        
        let title = titleLabel.text ?? ""
        let date = dateLabel.text ?? ""
        let location = locationLabel.text ?? ""
        
        // Update completion status in UserDefaults
        updateVaccinationCompletion(title: title, date: date, location: location, isCompleted: sender.isSelected)
    }
    
    private func storeVaccinationDetails(childName: String, vaccines: [String]) {
            let vaccinationDetails: [String: Any] = [
                "childName": childName,
                "vaccines": vaccines,
                "date": Date()  // Store the current date when vaccines were marked as completed
            ]
            
            // Retrieve existing data from UserDefaults
            var existingData = UserDefaults.standard.array(forKey: "ChildrenVaccinations") as? [[String: Any]] ?? []
            
            // Add the new vaccination details to the list
            existingData.append(vaccinationDetails)
            
            // Store the updated data back into UserDefaults
            UserDefaults.standard.set(existingData, forKey: "ChildrenVaccinations")
            
            print("Vaccination details saved for \(childName): \(vaccines)")
        }

    // Function to check if a vaccination is completed
    private func isVaccinationCompleted(title: String, date: String, location: String) -> Bool {
        if let savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: Any]] {
            for vaccination in savedData {
                if let savedTitle = vaccination["hospital"] as? String,
                   let savedDate = vaccination["date"] as? String,
                   let savedLocation = vaccination["address"] as? String,
                   let isCompleted = vaccination["isCompleted"] as? Bool,
                   savedTitle == title, savedDate == date, savedLocation == location {
                    return isCompleted
                }
            }
        }
        return false
    }

    // Function to update vaccination completion status
    private func updateVaccinationCompletion(title: String, date: String, location: String, isCompleted: Bool) {
        var savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: Any]] ?? []
        
        if let index = savedData.firstIndex(where: {
            $0["hospital"] as? String == title &&
            $0["date"] as? String == date &&
            $0["address"] as? String == location
        }) {
            savedData[index]["isCompleted"] = isCompleted
        } else {
            // Add new vaccination data if not already present
            let newVaccination = ["hospital": title, "date": date, "address": location, "isCompleted": isCompleted] as [String: Any]
            savedData.append(newVaccination)
        }
        
        UserDefaults.standard.set(savedData, forKey: "VaccinationSchedules")
    }
    // MARK: - Actions
    
    @objc private func didTapSearch() {
        print("Search tapped")
        // Implement search functionality
    }
}
