import UIKit


class VaccineReminderViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    let scrollView = UIScrollView()
    let contentView = UIView()
    let calendarView = UIView()
    let scheduledVaccinationsLabel = UILabel()
    let vaccinationsStackView = UIStackView()
    
    // Use the shared storage manager to access vaccination data
    let storageManager = VaccinationStorageManager.shared
    var vaccinations: [VaccineSchedule] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))
        
        setupScrollView()
        setupCalendarView()
        setupScheduledVaccinations()
        
        // Load vaccination data
        loadVaccinations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data when view appears
        loadVaccinations()
    }
    
    // MARK: - Data Loading
    private func loadVaccinations() {
        // Convert the dictionary storage data into VaccineSchedule array
        let storedSchedules = storageManager.getAllSchedules()
        
        vaccinations = storedSchedules.map { schedule in
            return VaccineSchedule(
//                id: schedule.id,
                type: schedule.type,
                hospital: schedule.hospitalName,
                date: schedule.scheduledDate,
                location: schedule.hospitalAddress
            )
        }
        
        displayVaccinations()
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
    
    func setupCalendarView() {
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
            calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 350),
            
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
        
        // Filter vaccinations for selected date
        filterVaccinationsForDate(dateFormatter.string(from: selectedDate))
    }
    
    private func filterVaccinationsForDate(_ selectedDate: String) {
        let filteredVaccinations = vaccinations.filter { $0.date == selectedDate }
        displayVaccinations(filteredVaccinations)
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
            scheduledVaccinationsLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 10),
            scheduledVaccinationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scheduledVaccinationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            vaccinationsStackView.topAnchor.constraint(equalTo: scheduledVaccinationsLabel.bottomAnchor, constant: 10),
            vaccinationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            vaccinationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            vaccinationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func displayVaccinations(_ vaccinationsToDisplay: [VaccineSchedule]? = nil) {
        vaccinationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let vaccinationsToShow = vaccinationsToDisplay ?? vaccinations
        
        for vaccine in vaccinationsToShow {
            addVaccinationCard(vaccineType: vaccine.type,
                             hospital: vaccine.hospital,
                             date: vaccine.date,
                             location: vaccine.location)
        }
    }
    
    private func addVaccinationCard(vaccineType: String, hospital: String, date: String, location: String) {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let vaccineTypeLabel = UILabel()
        vaccineTypeLabel.text = "\(vaccineType) Vaccine"
        vaccineTypeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let hospitalLabel = UILabel()
        hospitalLabel.text = hospital
        hospitalLabel.font = UIFont.systemFont(ofSize: 14)
        hospitalLabel.textColor = .gray
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        let locationLabel = UILabel()
        locationLabel.text = location
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = .gray
        locationLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [vaccineTypeLabel, hospitalLabel, dateLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)
        
        vaccinationsStackView.addArrangedSubview(card)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.isActive = true
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            displayVaccinations()
        } else {
            let filteredVaccinations = vaccinations.filter {
                $0.type.lowercased().contains(searchText.lowercased()) ||
                $0.hospital.lowercased().contains(searchText.lowercased()) ||
                $0.location.lowercased().contains(searchText.lowercased())
            }
            displayVaccinations(filteredVaccinations)
        }
    }
}

// MARK: - UIColor Extension
