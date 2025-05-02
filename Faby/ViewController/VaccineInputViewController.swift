import UIKit

class VaccineInputViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    private let vaccineManager = VaccineManager.shared
    private var selectedVaccines: [String] = []
    private var vaccineData: [Vaccine] = []
    private var filteredVaccineData: [Vaccine] = []
    private var cachedVaccines: [String: [Vaccine]] = [:] // Cache for each time period
    private var searchText: String = "" {
        didSet {
            filterVaccines()
        }
    }
    
    // Dictionary to store selected dates for vaccines
    private var selectedDates: [String: Date] = [:]
    
    private var currentPeriod: String = "Birth" {
        didSet {
            loadVaccinesForPeriod(currentPeriod)
        }
    }
    
    // Time periods for category buttons
    private let timePeriods = ["Birth", "6 weeks", "10 weeks", "14 weeks", "9-12 months", "16-24 months"]
    
    // MARK: - UI Components
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
//        label.text = "Mark the vaccines your child have recieved:"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data Loading
    private func loadVaccinesForPeriod(_ period: String) {
        Task {
            do {
                print("🔍 Loading vaccines for period: \(period)")
                
                await MainActor.run {
                    self.tableView.isHidden = true
                    self.emptyStateLabel.text = "Loading vaccines..."
                    self.emptyStateLabel.isHidden = false
                }

                // Check cache first
                if let cachedData = cachedVaccines[period] {
                    print("✅ Using cached data for period: \(period)")
                    await MainActor.run {
                        self.vaccineData = cachedData
                        self.filterVaccines()
                        self.updateUI()
                    }
                    return
                }

                // Fetch all vaccines if not cached
                let allVaccines = try await FetchingVaccines.shared.fetchAllVaccines()
                print("✅ Fetched \(allVaccines.count) total vaccines")

                // Filter vaccines based on period
                let weekRange = getWeekRange(for: period)
                let filteredVaccines = allVaccines.filter { vaccine in
                    if period == "Birth" || period == "6 weeks" || period == "10 weeks" || period == "14 weeks" {
                        return vaccine.startWeek == weekRange.start
                    } else {
                        return vaccine.startWeek >= weekRange.start &&
                               vaccine.startWeek <= weekRange.end
                    }
                }

                // Cache the results
                cachedVaccines[period] = filteredVaccines
                print("✅ Cached \(filteredVaccines.count) vaccines for period \(period)")
                
                // Update UI on main thread
                await MainActor.run {
                    self.vaccineData = filteredVaccines
                    self.filterVaccines()
                    self.updateUI()
                }
            } catch {
                print("❌ Error loading vaccines: \(error)")
                await MainActor.run {
                    self.emptyStateLabel.text = "Failed to load vaccines"
                    self.emptyStateLabel.isHidden = false
                    self.tableView.isHidden = true
                }
            }
        }
    }

    private func filterVaccines() {
        let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchQuery.isEmpty {
            filteredVaccineData = vaccineData
        } else {
            filteredVaccineData = vaccineData.filter { vaccine in
                vaccine.name.lowercased().contains(searchQuery) ||
                vaccine.description.lowercased().contains(searchQuery)
            }
        }
        
        updateUI()
    }
    
    private func updateUI() {
        if filteredVaccineData.isEmpty {
            emptyStateLabel.text = searchText.isEmpty ?
                "No vaccines available for \(currentPeriod)" :
                "No vaccines found for '\(searchText)'"
            emptyStateLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
        }
        tableView.reloadData()
    }

    private func getWeekRange(for period: String) -> (start: Int, end: Int) {
        switch period {
        case "Birth":
            return (0, 0)    // Only vaccines starting at week 0
        case "6 weeks":
            return (6, 6)    // Only vaccines starting at week 6
        case "10 weeks":
            return (10, 10)  // Only vaccines starting at week 10
        case "14 weeks":
            return (14, 14)  // Only vaccines starting at week 14
        case "9-12 months":
            return (36, 48)  // 9-12 months in weeks
        case "16-24 months":
            return (64, 96)  // 16-24 months in weeks
        default:
            return (0, 0)    // Default to birth period
        }
    }

    private func getTimingText(startWeek: Int) -> String {
        if startWeek == 0 {
            return "At birth"
        } else if startWeek < 4 {
            return "\(startWeek) weeks"
        } else if startWeek == 4 {
            return "1 month"
        } else if startWeek < 52 {
            return "\(startWeek/4) months"
        } else {
            let months = startWeek / 4
            return "\(months) months"
        }
    }

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark the vaccines your child has received"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search vaccines..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .secondarySystemBackground
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No vaccines available"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        setupConstraints()
        setupCategoryButtons()
        setupTableView()
        
        // Set search bar delegate
        searchBar.delegate = self
        
        // Set background colors
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Initial load of vaccines
        loadVaccinesForPeriod(currentPeriod)
    }
    
    // MARK: - Navigation Setup
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "VacciTime"
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(contentView)
        [titleLabel, subtitleLabel, searchBar, categoryScrollView, tableView, emptyStateLabel].forEach {
            contentView.addSubview($0)
        }
        categoryScrollView.addSubview(categoryStackView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 40),
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor, constant: -16),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor),
            tableView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func setupCategoryButtons() {
        // Clear existing buttons
        categoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new buttons with updated labels
        timePeriods.enumerated().forEach { index, title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .callout).pointSize, weight: .medium)
            button.backgroundColor = index == 0 ? .systemBlue : .secondarySystemBackground
            button.setTitleColor(index == 0 ? .white : .secondaryLabel, for: .normal)
            button.layer.cornerRadius = 16
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.tag = index
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            
            // Add shadow for selected state
            if index == 0 {
                button.layer.shadowColor = UIColor.systemBlue.cgColor
                button.layer.shadowOpacity = 0.3
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
            }
            
            categoryStackView.addArrangedSubview(button)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VaccineCell.self, forCellReuseIdentifier: "VaccineCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    // MARK: - Actions
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        // Update button appearances
        categoryStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                let isSelected = button.tag == sender.tag
                button.backgroundColor = isSelected ? .systemBlue : .secondarySystemBackground
                button.setTitleColor(isSelected ? .white : .secondaryLabel, for: .normal)
                
                // Update shadow
                button.layer.shadowOpacity = isSelected ? 0.3 : 0
                if isSelected {
                    button.layer.shadowColor = UIColor.systemBlue.cgColor
                    button.layer.shadowOffset = CGSize(width: 0, height: 2)
                    button.layer.shadowRadius = 4
                }
            }
        }
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        // Load vaccines for selected period
        let period = timePeriods[sender.tag]
        currentPeriod = period
    }

    // 1. Simplified saveButtonTapped method without baby ID check
    // Update the saveButtonTapped method in VaccineInputViewController to pass selected dates to the SelectedVaccinesViewController

    @objc private func saveButtonTapped() {
        // Check if any vaccines are selected
//        if selectedVaccines.isEmpty {
//            showAlert(title: "No Vaccines Selected", message: "Please select at least one vaccine before saving.")
//            return
//        }
        
        // Get selected vaccine objects
        let selectedVaccineObjects = vaccineData.filter { selectedVaccines.contains($0.name) }
        
        // Navigate to selected vaccines review screen with selected dates
        let selectedVaccinesVC = SelectedVaccinesViewController(
            selectedVaccines: selectedVaccineObjects,
            selectedDates: selectedDates // Pass the dictionary of selected dates
        )
        navigationController?.pushViewController(selectedVaccinesVC, animated: true)
    }
    // 3. Ensure the navigation bar is correctly set up and the button is visible
//    private func configureNavigationBar() {
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.title = "VacciTime"
//        
//        // Make sure the saveButton is more prominent
//        let saveButton = UIBarButtonItem(
//            title: "Save",
//            style: .done,
//            target: self,
//            action: #selector(saveButtonTapped)
//        )
//        // Set a more visible color
//        saveButton.tintColor = .systemBlue
//        navigationItem.rightBarButtonItem = saveButton
//        
//        if #available(iOS 13.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithDefaultBackground() // Use default background instead of transparent
//            appearance.backgroundColor = .systemBackground
//            appearance.shadowColor = .systemGray5  // Add a subtle shadow for better visibility
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
//            navigationController?.navigationBar.standardAppearance = appearance
//            navigationController?.navigationBar.compactAppearance = appearance
//            navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        }
//    }
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear cache if memory is low
        cachedVaccines.removeAll()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension VaccineInputViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredVaccineData.count
        emptyStateLabel.isHidden = count > 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as? VaccineCell else {
            return UITableViewCell()
        }
        
        let vaccine = filteredVaccineData[indexPath.row]
        
        // Check if we have a scheduled date for this vaccine
        let scheduledDate = selectedDates[vaccine.name]
        
        cell.configure(
            with: vaccine.name,
            timing: getTimingText(startWeek: vaccine.startWeek),
            description: vaccine.description,
            isSelected: selectedVaccines.contains(vaccine.name),
            scheduledDate: scheduledDate
        )
        cell.delegate = self
        
        return cell
    }
}

// MARK: - VaccineCellDelegate implementation
extension VaccineInputViewController: VaccineCellDelegate {
    func didTapCheckbox(for vaccine: String) {
        if selectedVaccines.contains(vaccine) {
            selectedVaccines.removeAll { $0 == vaccine }
        } else {
            selectedVaccines.append(vaccine)
        }
        tableView.reloadData()
    }
    
    func didTapScheduleButton(for vaccine: String) {
        let selectedVaccineObjects = vaccineData.filter { $0.name == vaccine }
        guard let selectedVaccine = selectedVaccineObjects.first else { return }
        
        // Create date picker alert
        let alertController = UIAlertController(title: "Schedule Vaccination", message: "Select a date for \(vaccine)", preferredStyle: .actionSheet)
        
        // Create custom view for date picker
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.bounds.width - 16, height: 300))
        
        // Create and configure date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date() // Can't schedule in the past
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date()) // Max 2 years in future
        datePicker.frame = customView.bounds
        customView.addSubview(datePicker)
        
        // Add custom view to alert
        alertController.view.addSubview(customView)
        
        // Adjust alert height to accommodate date picker
        let heightConstraint = NSLayoutConstraint(
            item: alertController.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 500
        )
        alertController.view.addConstraint(heightConstraint)
        
        // Add actions
        let scheduleAction = UIAlertAction(title: "Schedule", style: .default) { [weak self] _ in
            self?.handleDateSelection(date: datePicker.date, for: selectedVaccine)
        }
        
        // Add a remove action if a date is already scheduled
        if selectedDates[vaccine] != nil {
            let removeAction = UIAlertAction(title: "Remove Date", style: .destructive) { [weak self] _ in
                self?.selectedDates.removeValue(forKey: vaccine)
                self?.tableView.reloadData()
            }
            alertController.addAction(removeAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(scheduleAction)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    
    private func handleDateSelection(date: Date, for vaccine: Vaccine) {
        // Store the selected date for the vaccine
        selectedDates[vaccine.name] = date
        
        // Reload the table to show the selected date
        tableView.reloadData()
        
        // Show success message
        showSuccessAlert(for: vaccine.name, on: date)
    }
    
    private func showSuccessAlert(for vaccineName: String, on date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let alert = UIAlertController(
            title: "Vaccination Scheduled",
            message: "\(vaccineName) has been scheduled for \(dateFormatter.string(from: date))",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - VaccineCell
protocol VaccineCellDelegate: AnyObject {
    func didTapCheckbox(for vaccine: String)
    func didTapScheduleButton(for vaccine: String)
}

class VaccineCell: UITableViewCell {
    weak var delegate: VaccineCellDelegate?
    private var vaccineName: String = ""
    
    // Container view with iOS-style design
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .semibold)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let normalImage = UIImage(systemName: "circle", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let calendarImage = UIImage(systemName: "calendar", withConfiguration: config)
        
        button.setImage(calendarImage, for: .normal)
        button.setTitle(" Add vaccination date", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        button.tintColor = .systemBlue
        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            timingLabel,
            descriptionLabel,
            scheduleButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(stackView)
        containerView.addSubview(checkmarkButton)
        
        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            checkmarkButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            checkmarkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with vaccine: String, timing: String, description: String, isSelected: Bool, scheduledDate: Date? = nil) {
        vaccineName = vaccine
        titleLabel.text = vaccine
        timingLabel.text = timing
        descriptionLabel.text = description
        checkmarkButton.isSelected = isSelected
        checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray3
        
        // Update schedule button based on whether a date is selected
        if let date = scheduledDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateString = dateFormatter.string(from: date)
            
            // Show the date instead of "Add vaccination date"
            let calendarConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            let calendarImage = UIImage(systemName: "calendar.badge.clock", withConfiguration: calendarConfig)
            scheduleButton.setImage(calendarImage, for: .normal)
            scheduleButton.setTitle(" \(dateString)", for: .normal)
            scheduleButton.tintColor = .systemGreen
        } else {
            // Reset to default state
            let calendarConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            let calendarImage = UIImage(systemName: "calendar", withConfiguration: calendarConfig)
            scheduleButton.setImage(calendarImage, for: .normal)
            scheduleButton.setTitle(" Add vaccination date", for: .normal)
            scheduleButton.tintColor = .systemBlue
        }
    }
    
    @objc private func scheduleButtonTapped() {
        delegate?.didTapScheduleButton(for: vaccineName)
    }
    
    
    @objc private func checkmarkTapped() {
        checkmarkButton.isSelected.toggle()
        checkmarkButton.tintColor = checkmarkButton.isSelected ? .systemBlue : .systemGray3
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        delegate?.didTapCheckbox(for: vaccineName)
    }
    
//    @objc private func removeScheduleButtonTapped() {
//        delegate?.didTapRemoveScheduleButton(for: vaccineName)
//    }
}
