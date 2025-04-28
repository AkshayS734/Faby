import UIKit
import SwiftUI

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
    
    func updateScheduledDates(_ dates: [Date]) {
        scheduledDates.removeAll()
        
        let calendar = Calendar.current
        for date in dates {
                if let normalizedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                    scheduledDates.insert(normalizedDate)
                print("✅ Successfully added date indicator for: \(date)")
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
                                y: cell.bounds.height - dotSize - 4,
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
    private let vaccinationsTableView = UITableView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
        
        private var calendarWithIndicators: CalendarWithIndicators?
        private var vaccinations: [VaccineSchedule] = []
        private var filteredVaccinations: [VaccineSchedule] = []
    private var currentBabyId: UUID {
        return UserDefaultsManager.shared.currentBabyId ?? UUID()
    }
        
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
    
    private var vaccinationListHostingController: UIHostingController<VaccinationListView>?
        
        // MARK: - Lifecycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
        print("DEBUG: VaccineReminderViewController viewDidLoad called")
            setupUI()
        setupActivityIndicator()
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
        setupTableView()
        setupEmptyStateView()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
    
    private func setupTableView() {
        vaccinationsTableView.translatesAutoresizingMaskIntoConstraints = false
        vaccinationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "VaccineCell")
        vaccinationsTableView.delegate = self
        vaccinationsTableView.dataSource = self
        vaccinationsTableView.backgroundColor = .clear
        vaccinationsTableView.separatorStyle = .none
        vaccinationsTableView.showsVerticalScrollIndicator = false
        contentView.addSubview(vaccinationsTableView)
        
        NSLayoutConstraint.activate([
            vaccinationsTableView.topAnchor.constraint(equalTo: vaccinationsStackView.bottomAnchor, constant: 8),
            vaccinationsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vaccinationsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            vaccinationsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            vaccinationsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        contentView.addSubview(emptyStateView)
        
        let emptyLabel = UILabel()
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No vaccinations scheduled"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyStateView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: vaccinationsStackView.bottomAnchor, constant: 40),
            emptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyStateView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
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
            vaccinationsStackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        // MARK: - Data Loading and Display
        private func loadVaccinations() {
        print("📋 Loading vaccinations for all babies")
        activityIndicator.startAnimating()
        
        Task {
            do {
                // Fetch all scheduled vaccines (no baby filter)
                let scheduledVaccines = try await VaccineScheduleManager.shared.fetchAllSchedules()
                print("✅ Fetched \(scheduledVaccines.count) scheduled vaccines (all babies)")
                
                // Get administered vaccines (optional, can be filtered if needed)
                let administeredVaccines: [VaccineAdministered] = []
                
                // Process and combine records
                let combinedRecords = processVaccinationRecords(
                    scheduledVaccines: scheduledVaccines,
                    administeredVaccines: administeredVaccines
                )
                
                // Update calendar with vaccine dates
                let vaccineDates = combinedRecords.map { $0.date }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.vaccinations = combinedRecords
                    self.filteredVaccinations = combinedRecords
                    self.calendarWithIndicators?.updateScheduledDates(vaccineDates)
                    self.displayVaccinations(combinedRecords)
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("❌ Error loading vaccinations: \(error)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.showErrorAlert(message: "Unable to load vaccination schedules. Please try again later.")
                    self.vaccinations = []
                    self.filteredVaccinations = []
                    self.displayVaccinations([])
                }
                }
            }
        }
        
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func processVaccinationRecords(
        scheduledVaccines: [VaccineSchedule],
        administeredVaccines: [VaccineAdministered]
    ) -> [VaccineSchedule] {
        var result: [VaccineSchedule] = []
        
        // Add scheduled vaccines that are not administered
        result.append(contentsOf: scheduledVaccines.filter { !$0.isAdministered })
        
        // Convert administered vaccines to the same model for display
        for administered in administeredVaccines {
            // Find the matching scheduled vaccine to get more details
            if let matchingSchedule = scheduledVaccines.first(where: { $0.id == administered.scheduleId }) {
                // Create a new schedule record with administered status
                let administeredSchedule = VaccineSchedule(
                    id: administered.id,
                    babyID: administered.babyId,
                    vaccineId: administered.vaccineId,
                    hospital: matchingSchedule.hospital,
                    date: administered.administeredDate,
                    location: matchingSchedule.location,
                    isAdministered: true
                )
                result.append(administeredSchedule)
            }
        }
        
        // Sort by date (newest first)
        result.sort { (a, b) -> Bool in
            return a.date > b.date
        }
        
        return result
    }
    
    private func displayVaccinations(_ vaccinationsToDisplay: [VaccineSchedule]? = nil) {
        let vaccines = vaccinationsToDisplay ?? filteredVaccinations
        
        // Remove any existing vaccination list view
        vaccinationListHostingController?.view.removeFromSuperview()
        vaccinationListHostingController?.removeFromParent()
        
        // Create and add the new SwiftUI vaccination list view
        let vaccinationListView = VaccinationListView(vaccinations: vaccines)
        let hostingController = UIHostingController(rootView: vaccinationListView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Setup constraints for the hosting controller
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        vaccinationListHostingController = hostingController
        }
        
        // MARK: - Date Selection
        @objc private func didSelectDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
            filterVaccinationsForDate(selectedDate)
        }
        
    private func filterVaccinationsForDate(_ selectedDate: Date) {
            let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            
            filteredVaccinations = vaccinations.filter { vaccination in
            let vaccinationComponents = calendar.dateComponents([.year, .month, .day], from: vaccination.date)
                
                return selectedComponents.year == vaccinationComponents.year &&
                selectedComponents.month == vaccinationComponents.month &&
                selectedComponents.day == vaccinationComponents.day
            }
            
            displayVaccinations(filteredVaccinations)
        scheduledVaccinationsLabel.text = "Vaccinations for \(dateFormatter.string(from: selectedDate))"
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
                // Get vaccine name from VaccineScheduleManager
                let vaccineName = "Vaccine" // Replace with actual logic to get vaccine name
                
                return vaccineName.lowercased().contains(searchText.lowercased()) ||
                    $0.hospital.lowercased().contains(searchText.lowercased()) ||
                    $0.location.lowercased().contains(searchText.lowercased()) ||
                dateFormatter.string(from: $0.date).lowercased().contains(searchText.lowercased())
                }
                displayVaccinations(filteredVaccinations)
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            filteredVaccinations = vaccinations
            displayVaccinations(filteredVaccinations)
        }
    }

// MARK: - UITableViewDelegate, UITableViewDataSource
extension VaccineReminderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVaccinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath)
        let vaccination = filteredVaccinations[indexPath.row]
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        
        // Get vaccine name - hardcoded for now until we have proper database alignment
        let vaccineName = getVaccineName(for: vaccination.vaccineId)
        
        content.text = vaccineName
        
        // Format date
        let dateString = dateFormatter.string(from: vaccination.date)
        
        // Add status indicator
        if vaccination.isAdministered {
            content.secondaryAttributedText = NSAttributedString(
                string: "Administered • \(vaccination.hospital) • \(dateString)",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
            )
        } else {
            content.secondaryText = "Scheduled • \(vaccination.hospital) • \(dateString)"
        }
        
        cell.contentConfiguration = content
        cell.backgroundColor = .secondarySystemBackground
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    // Helper method to get vaccine name
    private func getVaccineName(for vaccineId: UUID) -> String {
        // This is a hardcoded solution since we can't fetch from the database right now
        // In a real implementation, you would fetch this from your database
        let vaccineNames = [
            "DTaP (Dose 1)",
            "Hepatitis B (Dose 1)",
            "Rotavirus",
            "Polio (Dose 1)",
            "Hib (Dose 1)",
            "Pneumococcal (Dose 1)"
        ]
        
        // Use the last 1 digit of the UUID as an index to select a vaccine name
        if let lastChar = vaccineId.uuidString.last, 
           let index = Int(String(lastChar), radix: 16) {
            return vaccineNames[index % vaccineNames.count]
        }
        
        return "Vaccine"
    }
}


