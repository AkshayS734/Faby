import UIKit

class VaccineReminderViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    let scrollView = UIScrollView()
    let contentView = UIView()
    let calendarView = UIView()
    let scheduledVaccinationsLabel = UILabel()
    let vaccinationsStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)
        
        vaccinationsStackView.addArrangedSubview(card)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
    }
    // MARK: - Actions
    
    @objc private func didTapSearch() {
        print("Search tapped")
        // Implement search functionality
    }
}
