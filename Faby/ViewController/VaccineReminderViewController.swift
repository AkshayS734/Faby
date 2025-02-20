import UIKit

// MARK: - Custom Calendar with Indicators
class CalendarWithIndicators: UIDatePicker {
    private var scheduledDates: Set<Date> = []
    private var dotLayers: [CALayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.datePickerMode = .date
        self.preferredDatePickerStyle = .inline
        self.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicators()
    }
    
    func updateScheduledDates(_ dates: [String]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        scheduledDates.removeAll()
        
        let calendar = Calendar.current
        for dateString in dates {
            if let date = dateFormatter.date(from: dateString) {
                if let normalizedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                    scheduledDates.insert(normalizedDate)
                }
            }
        }
        
        setNeedsLayout()
    }
    
    @objc private func datePickerValueChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateIndicators()
        }
    }
    
    private func updateIndicators() {
        // Reset any previous color changes
        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()
        
        // Add a short delay to ensure the calendar view has been updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            guard let calendarView = self.findCalendarView() else { return }
            
            // Find all date cells
            let dateCells = self.findDateCells(in: calendarView)
            let calendar = Calendar.current
            
            for cell in dateCells {
                if let dateLabel = self.findDateLabel(in: cell),
                   let dateText = dateLabel.text,
                   let day = Int(dateText) {
                    
                    // Create a date from the current month/year and the day number
                    let components = calendar.dateComponents([.year, .month], from: self.date)
                    if let year = components.year, let month = components.month,
                       let cellDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                        
                        // Check if this date is in our scheduled dates
                        if self.scheduledDates.contains(where: { scheduledDate in
                            let scheduledComponents = calendar.dateComponents([.year, .month, .day], from: scheduledDate)
                            return scheduledComponents.year == year &&
                            scheduledComponents.month == month &&
                            scheduledComponents.day == day
                        }) {
                            // Change text color instead of adding a dot
                            dateLabel.textColor = UIColor(hex: "#0076BA")
                        } else {
                            // Reset to default text color for non-scheduled dates
                            dateLabel.textColor = nil // This uses the system default
                        }
                    }
                }
            }
        }
    }
    private func findCalendarView() -> UIView? {
        return subviews.first { subview in
            subview.subviews.contains { $0 is UICollectionView }
        }
    }
    
    private func findDateCells(in view: UIView) -> [UIView] {
        return view.subviews.flatMap { subview in
            subview.subviews.filter { cell in
                cell.subviews.contains { $0 is UILabel }
            }
        }
    }
    
    private func findDateLabel(in cell: UIView) -> UILabel? {
        return cell.subviews.first { $0 is UILabel } as? UILabel
    }
    
    private func extractDate(from text: String) -> Date? {
        guard let day = Int(text) else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self.date)
        
        return calendar.date(from: DateComponents(year: components.year,
                                                  month: components.month,
                                                  day: day))
    }
    
    private func addDotIndicator(to cell: UIView) {
        let dotLayer = CALayer()
        let dotSize: CGFloat = 6
        
        // Position the dot at the bottom center of the cell
        dotLayer.frame = CGRect(x: (cell.bounds.width - dotSize) / 2,
                                y: cell.bounds.height - dotSize - 4, // Increase this value to move it up more
                                width: dotSize,
                                height: dotSize)
        
        dotLayer.cornerRadius = dotSize / 2
        dotLayer.backgroundColor = UIColor.systemBlue.cgColor
        
        // Add the dot with higher z-index
        dotLayer.zPosition = 1000
        cell.layer.addSublayer(dotLayer)
        dotLayers.append(dotLayer)
    }
}
    // MARK: - Main View Controller
    
    
class VaccineReminderViewController: UIViewController, UISearchBarDelegate {
        
        // MARK: - Properties
        private let scrollView = UIScrollView()
        private let contentView = UIView()
        private let calendarView = UIView()
        private let scheduledVaccinationsLabel = UILabel()
        private let vaccinationsStackView = UIStackView()
        
        private var calendarWithIndicators: CalendarWithIndicators?
        private let storageManager = VaccinationStorageManager.shared
        private var vaccinations: [VaccineSchedule] = []
        private var filteredVaccinations: [VaccineSchedule] = []
        
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
        
        // MARK: - Lifecycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            loadVaccinations()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadVaccinations()
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            view.backgroundColor = UIColor(hex: "#f2f2f7")
            setupNavigationBar()
            setupScrollView()
            setupCalendarView()
            setupScheduledVaccinations()
        }
        
        private func setupNavigationBar() {
            title = "Vaccine Reminders"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .search,
                target: self,
                action: #selector(didTapSearch)
            )
        }
        
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
            calendarView.backgroundColor = .systemBackground
            calendarView.layer.cornerRadius = 12
            contentView.addSubview(calendarView)
            
            let datePicker = CalendarWithIndicators(frame: .zero)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
            calendarView.addSubview(datePicker)
            
            self.calendarWithIndicators = datePicker
            
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                calendarView.heightAnchor.constraint(equalToConstant: 350),
                
                datePicker.topAnchor.constraint(equalTo: calendarView.topAnchor),
                datePicker.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor)
            ])
        }
        
        @objc private func seeAllButtonTapped() {
            // Reset any date filters
            filteredVaccinations = vaccinations
            displayVaccinations(filteredVaccinations)
            scheduledVaccinationsLabel.text = "All Scheduled Vaccinations"
        }
        
        private func setupScheduledVaccinations() {
            // Create a container view for the header
            let headerView = UIView()
            headerView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(headerView)
            
            scheduledVaccinationsLabel.translatesAutoresizingMaskIntoConstraints = false
            scheduledVaccinationsLabel.text = "Scheduled Vaccinations"
            scheduledVaccinationsLabel.font = .systemFont(ofSize: 20, weight: .bold)
            headerView.addSubview(scheduledVaccinationsLabel)
            
            // Add "See All" button
            let seeAllButton = UIButton(type: .system)
            seeAllButton.translatesAutoresizingMaskIntoConstraints = false
            seeAllButton.setTitle("See All", for: .normal)
            seeAllButton.titleLabel?.font = .systemFont(ofSize: 16)
            seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
            headerView.addSubview(seeAllButton)
            
            vaccinationsStackView.translatesAutoresizingMaskIntoConstraints = false
            vaccinationsStackView.axis = .vertical
            vaccinationsStackView.spacing = 10
            contentView.addSubview(vaccinationsStackView)
            
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 24),
                headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                headerView.heightAnchor.constraint(equalToConstant: 30),
                
                scheduledVaccinationsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                scheduledVaccinationsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                
                seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                
                vaccinationsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
                vaccinationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                vaccinationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                vaccinationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
        
        
        // MARK: - Data Loading and Display
        private func loadVaccinations() {
            let storedSchedules = storageManager.getAllSchedules()
            
            vaccinations = storedSchedules.map { schedule in
                return VaccineSchedule(
                    type: schedule.type,
                    hospital: schedule.hospitalName,
                    date: schedule.scheduledDate,
                    location: schedule.hospitalAddress
                )
            }
            
            // Sort vaccinations by date
            vaccinations.sort { (schedule1, schedule2) -> Bool in
                guard let date1 = dateFormatter.date(from: schedule1.date),
                      let date2 = dateFormatter.date(from: schedule2.date) else {
                    return false
                }
                return date1 < date2
            }
            
            // Update calendar indicators
            let scheduledDates = vaccinations.map { $0.date }
            calendarWithIndicators?.updateScheduledDates(scheduledDates)
            
            // Show all vaccinations initially
            filteredVaccinations = vaccinations
            displayVaccinations()
        }
        
        private func displayVaccinations(_ vaccinationsToDisplay: [VaccineSchedule]? = nil) {
            // Clear existing cards
            vaccinationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            let vaccinationsToShow = vaccinationsToDisplay ?? vaccinations
            
            if vaccinationsToShow.isEmpty {
                // Add "No vaccinations" card
                let emptyCard = createEmptyStateCard()
                vaccinationsStackView.addArrangedSubview(emptyCard)
            } else {
                // Add vaccination cards
                for vaccine in vaccinationsToShow {
                    addVaccinationCard(vaccineType: vaccine.type,
                                       hospital: vaccine.hospital,
                                       date: vaccine.date,
                                       location: vaccine.location)
                }
            }
        }
        
        private func createEmptyStateCard() -> UIView {
            let card = UIView()
            card.backgroundColor = .white
            card.layer.cornerRadius = 10
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.1
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = "No vaccinations scheduled for this date"
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(equalToConstant: 80),
                label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
            
            return card
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
            vaccineTypeLabel.font = .systemFont(ofSize: 16, weight: .bold)
            
            let hospitalLabel = UILabel()
            hospitalLabel.text = hospital
            hospitalLabel.font = .systemFont(ofSize: 14)
            hospitalLabel.textColor = .gray
            
            let dateLabel = UILabel()
            dateLabel.text = date
            dateLabel.font = .systemFont(ofSize: 14)
            dateLabel.textColor = .gray
            
            let locationLabel = UILabel()
            locationLabel.text = location
            locationLabel.font = .systemFont(ofSize: 12)
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
        
        // MARK: - Date Selection
        @objc private func didSelectDate(_ sender: UIDatePicker) {
            let selectedDate = dateFormatter.string(from: sender.date)
            filterVaccinationsForDate(selectedDate)
        }
        
        private func filterVaccinationsForDate(_ selectedDate: String) {
            guard let selectedDateValue = dateFormatter.date(from: selectedDate) else { return }
            let calendar = Calendar.current
            let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDateValue)
            
            filteredVaccinations = vaccinations.filter { vaccination in
                guard let vaccinationDate = dateFormatter.date(from: vaccination.date) else { return false }
                let vaccinationComponents = calendar.dateComponents([.year, .month, .day], from: vaccinationDate)
                
                return selectedComponents.year == vaccinationComponents.year &&
                selectedComponents.month == vaccinationComponents.month &&
                selectedComponents.day == vaccinationComponents.day
            }
            
            displayVaccinations(filteredVaccinations)
            scheduledVaccinationsLabel.text = "Vaccinations for \(selectedDate)"
        }
        
        // MARK: - Search
        @objc private func didTapSearch() {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.delegate = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search vaccinations..."
            navigationItem.searchController = searchController
            searchController.isActive = true
        }
        
        // MARK: - UISearchBarDelegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredVaccinations = vaccinations
                displayVaccinations(filteredVaccinations)
            } else {
                filteredVaccinations = vaccinations.filter {
                    $0.type.lowercased().contains(searchText.lowercased()) ||
                    $0.hospital.lowercased().contains(searchText.lowercased()) ||
                    $0.location.lowercased().contains(searchText.lowercased()) ||
                    $0.date.lowercased().contains(searchText.lowercased())
                }
                displayVaccinations(filteredVaccinations)
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            filteredVaccinations = vaccinations
            displayVaccinations(filteredVaccinations)
        }
    }
