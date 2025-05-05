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
}

// MARK: - Main View Controller
class VaccineReminderViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let calendarContainer = UIView()
    private let vaccineListContainer = UIView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var calendarWithIndicators: CalendarWithIndicators?
    private var vaccinations: [VaccineSchedule] = []
    private var filteredVaccinations: [VaccineSchedule] = []
    
    // Header views
    private let headerView = UIView()
    private let scheduledVaccinationsLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)
    
    // Animation properties
    private var calendarHeightConstraint: NSLayoutConstraint?
    private var calendarTopConstraint: NSLayoutConstraint?
    private var calendarMinimizedHeight: CGFloat = 120
    private var calendarFullHeight: CGFloat = 350
    private var lastContentOffset: CGFloat = 0
    private var isCalendarMinimized = false
    
    private var currentBabyId: UUID {
        return UserDefaultsManager.shared.currentBabyId ?? UUID()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var vaccinationListHostingController: UIHostingController<VaccineScheduleListView>?
    
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
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
        setupScrollView()
        setupCalendarView()
        setupHeaderView()
        setupVaccineListContainer()
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
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(didTapSearch)
        )
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        
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
        
        // Add tap gesture to dismiss calendar when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideCalendar))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    private func setupCalendarView() {
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.backgroundColor = .systemBackground
        calendarContainer.layer.cornerRadius = 12
        calendarContainer.clipsToBounds = true
        calendarContainer.layer.shadowColor = UIColor.black.cgColor
        calendarContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        calendarContainer.layer.shadowRadius = 4
        calendarContainer.layer.shadowOpacity = 0.1
        calendarContainer.layer.masksToBounds = false
        contentView.addSubview(calendarContainer)
        
        let datePicker = CalendarWithIndicators(frame: .zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(didSelectDate(_:)), for: .valueChanged)
        calendarContainer.addSubview(datePicker)
        
        self.calendarWithIndicators = datePicker
        
        calendarTopConstraint = calendarContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        calendarHeightConstraint = calendarContainer.heightAnchor.constraint(equalToConstant: calendarFullHeight)
        
        NSLayoutConstraint.activate([
            calendarTopConstraint!,
            calendarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            calendarHeightConstraint!,
            
            datePicker.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor)
        ])
    }
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        scheduledVaccinationsLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduledVaccinationsLabel.text = "Scheduled Vaccinations"
        scheduledVaccinationsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        headerView.addSubview(scheduledVaccinationsLabel)
        
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 16)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        headerView.addSubview(seeAllButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 24),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 30),
            
            scheduledVaccinationsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            scheduledVaccinationsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    private func setupVaccineListContainer() {
        vaccineListContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vaccineListContainer)
        
        NSLayoutConstraint.activate([
            vaccineListContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            vaccineListContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineListContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineListContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            vaccineListContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 500) // Ensure enough space for content
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
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            emptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
    }
    
    // MARK: - Calendar Animation
    private func toggleCalendarSize(minimize: Bool, animated: Bool = true) {
        if isCalendarMinimized == minimize { return }
        
        isCalendarMinimized = minimize
        
        let targetHeight = minimize ? calendarMinimizedHeight : calendarFullHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.calendarHeightConstraint?.constant = targetHeight
                self.view.layoutIfNeeded()
            }
        } else {
            calendarHeightConstraint?.constant = targetHeight
            view.layoutIfNeeded()
        }
    }
    
    @objc private func handleTapOutsideCalendar(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: contentView)
        if !calendarContainer.frame.contains(location) && isCalendarMinimized == false {
            toggleCalendarSize(minimize: true)
        }
    }
    
    // MARK: - Action Handlers
    @objc private func seeAllButtonTapped() {
        // Reset any date filters
        filteredVaccinations = vaccinations
        displayVaccinations(filteredVaccinations)
        scheduledVaccinationsLabel.text = "All Scheduled Vaccinations"
    }
    
    // MARK: - Helper methods for vaccine name resolution
    private func getVaccineName(for vaccineId: UUID) async -> String {
        print("🔍 Getting vaccine name for ID: \(vaccineId)")
        do {
            // Use SupabaseVaccineManager to fetch all vaccines
            let allVaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
            
            // Find the matching vaccine by ID
            if let vaccine = allVaccines.first(where: { $0.id == vaccineId }) {
                print("✅ Found vaccine name from database: \(vaccine.name)")
                return vaccine.name
            }
            
            // Fallback to VaccineManager's static data if needed
            for stage in VaccineManager.shared.vaccineData {
                for vaccineName in stage.vaccines {
                    // This is a simple check - in practice you'd want to match more precisely
                    if vaccineName.contains(vaccineId.uuidString.prefix(8)) {
                        print("✅ Found vaccine name from static data: \(vaccineName)")
                        return vaccineName
                    }
                }
            }
            
            print("⚠️ Could not find name for vaccine ID: \(vaccineId)")
            return "Unknown Vaccine"
        } catch {
            print("❌ Error fetching vaccine name: \(error)")
            
            // Fallback to shortened UUID
            return "Vaccine \(vaccineId.uuidString.prefix(8))"
        }
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
                
                // Process and combine records
                // Filter out administered vaccines before processing
                let filteredScheduledVaccines = scheduledVaccines.filter { !$0.isAdministered }
                let combinedRecords = processVaccinationRecords(
                    scheduledVaccines: filteredScheduledVaccines,
                    administeredVaccines: []
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
            return a.date < b.date // Changed to date ascending (upcoming first)
        }
        
        return result
    }
    
    private func displayVaccinations(_ vaccinationsToDisplay: [VaccineSchedule]? = nil) {
        let vaccines = vaccinationsToDisplay ?? filteredVaccinations
        
        // Create vaccine schedule tuples with names
        var vaccinesWithNames: [(VaccineSchedule, String)] = []
        
        // Create a task group to fetch all vaccine names asynchronously
        Task {
            for vaccine in vaccines {
                // Get the vaccine name using the getVaccineName method
                let vaccineName = await getVaccineName(for: vaccine.vaccineId)
                vaccinesWithNames.append((vaccine, vaccineName))
            }
            
            // Update UI on the main thread once all names are retrieved
            await MainActor.run {
                // Remove any existing vaccination list view
                vaccinationListHostingController?.view.removeFromSuperview()
                vaccinationListHostingController?.removeFromParent()
                
                // Create and add the new SwiftUI vaccination list view with vaccine names
                let vaccinationListView = VaccineScheduleListView(vaccinations: vaccinesWithNames)
                let hostingController = UIHostingController(rootView: vaccinationListView)
                addChild(hostingController)
                hostingController.view.backgroundColor = .systemGroupedBackground
                vaccineListContainer.addSubview(hostingController.view)
                
                // Setup constraints for the hosting controller
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.topAnchor.constraint(equalTo: vaccineListContainer.topAnchor),
                    hostingController.view.leadingAnchor.constraint(equalTo: vaccineListContainer.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: vaccineListContainer.trailingAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: vaccineListContainer.bottomAnchor)
                ])
                
                hostingController.didMove(toParent: self)
                vaccinationListHostingController = hostingController
                
                // Update empty state visibility
                emptyStateView.isHidden = !vaccines.isEmpty
                vaccineListContainer.isHidden = vaccines.isEmpty
                
                // Minimize calendar if vaccines are found
                if !vaccines.isEmpty && !isCalendarMinimized {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.toggleCalendarSize(minimize: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Date Selection
    @objc private func didSelectDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        filterVaccinationsForDate(selectedDate)
        
        // Expand calendar when date is selected
        toggleCalendarSize(minimize: true, animated: true)
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
            // We need to handle search differently since we need to get vaccine names first
            Task {
                var searchResults: [VaccineSchedule] = []
                
                for vaccine in vaccinations {
                    // Get current vaccine name
                    let vaccineName = await getVaccineName(for: vaccine.vaccineId)
                    
                    if vaccineName.lowercased().contains(searchText.lowercased()) ||
                       vaccine.hospital.lowercased().contains(searchText.lowercased()) ||
                       vaccine.location.lowercased().contains(searchText.lowercased()) ||
                       dateFormatter.string(from: vaccine.date).lowercased().contains(searchText.lowercased()) {
                        searchResults.append(vaccine)
                    }
                }
                
                // Update on main thread
                await MainActor.run {
                    self.filteredVaccinations = searchResults
                    self.displayVaccinations(searchResults)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredVaccinations = vaccinations
        displayVaccinations(filteredVaccinations)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Detect scroll direction
        let currentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Automatically minimize calendar when scrolling down
        if currentOffset > lastContentOffset && currentOffset > 50 {
            // Scrolling down
            if !isCalendarMinimized {
                toggleCalendarSize(minimize: true)
            }
        } else if currentOffset < lastContentOffset && currentOffset < 20 {
            // Scrolling up to top - consider expanding calendar
            if isCalendarMinimized {
                toggleCalendarSize(minimize: false)
            }
        }
        
        // Update for next comparison
        lastContentOffset = currentOffset
    }
    
    // Handle tap on calendar to expand/collapse
    @objc private func calendarContainerTapped() {
        toggleCalendarSize(minimize: !isCalendarMinimized)
    }
}

// MARK: - SwiftUI Views
struct VaccineScheduleListView: View {
    let vaccinations: [(VaccineSchedule, String)]
    
    var body: some View {
        if vaccinations.isEmpty {
            VStack {
                Spacer()
                Text("No vaccinations found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vaccinations, id: \.0.id) { tuple in
                        let (vaccination, vaccineName) = tuple
                        VaccinationCard(vaccination: vaccination, vaccineName: vaccineName)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct VaccinationCard: View {
    let vaccination: VaccineSchedule
    let vaccineName: String
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(vaccineName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(vaccination.isAdministered ? "Administered" : "Scheduled")
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(vaccination.isAdministered ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    )
                    .foregroundColor(vaccination.isAdministered ? .green : .blue)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(dateFormatter.string(from: vaccination.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(vaccination.hospital)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !vaccination.location.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    Text(vaccination.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

