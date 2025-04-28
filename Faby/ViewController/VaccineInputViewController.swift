import UIKit

class VaccineInputViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    private let vaccineManager = VaccineManager.shared
    private var selectedVaccines: [String] = []
    private var vaccineData: [Vaccine] = []
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
                // Show loading state
                await MainActor.run {
                    self.tableView.isHidden = true
                    self.emptyStateLabel.text = "Loading vaccines..."
                    self.emptyStateLabel.isHidden = false
                }

                // Get current baby ID
                guard let currentBabyId = UserDefaultsManager.shared.currentBabyId else {
                    print("❌ No baby selected")
                    await MainActor.run {
                        self.emptyStateLabel.text = "No baby selected"
                        self.emptyStateLabel.isHidden = false
                    }
                    return
                }

                // Fetch all vaccines and scheduled vaccines
                let allVaccines = try await FetchingVaccines.shared.fetchAllVaccines()
                print("✅ Fetched \(allVaccines.count) total vaccines")
                let scheduledVaccines = try await VaccineScheduleManager.shared.fetchSchedules(forBaby: currentBabyId)
                print("✅ Fetched \(scheduledVaccines.count) scheduled vaccines")
                let scheduledVaccineIds = scheduledVaccines.map { $0.vaccineId }

                // Filter vaccines based on period
                let weekRange = getWeekRange(for: period)
                let filteredVaccines = allVaccines.filter { vaccine in
                    // For exact week matching
                    if period == "Birth" || period == "6 weeks" || period == "10 weeks" || period == "14 weeks" {
                        return vaccine.startWeek == weekRange.start && !scheduledVaccineIds.contains(vaccine.id)
                    } else {
                        // For month ranges (9-12 months and 16-24 months)
                        return vaccine.startWeek >= weekRange.start &&
                               vaccine.startWeek <= weekRange.end &&
                               !scheduledVaccineIds.contains(vaccine.id)
                    }
                }

                print("✅ Filtered \(filteredVaccines.count) vaccines for period \(period)")
                
                // Update UI on main thread
                await MainActor.run {
                    self.vaccineData = filteredVaccines
                    self.tableView.reloadData()
                    
                    if filteredVaccines.isEmpty {
                        print("ℹ️ No vaccines available for \(period)")
                        self.emptyStateLabel.text = "No vaccines available for \(period)"
                        self.emptyStateLabel.isHidden = false
                        self.tableView.isHidden = true
                    } else {
                        print("🎉 Displaying \(filteredVaccines.count) vaccines for \(period)")
                        self.emptyStateLabel.isHidden = true
                        self.tableView.isHidden = false
                    }
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
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
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
        searchBar.delegate = self;
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
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = index == 0 ? .systemBlue : UIColor.secondarySystemGroupedBackground
            button.setTitleColor(index == 0 ? .white : .systemGray, for: .normal)
            button.layer.cornerRadius = 20
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.tag = index
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            
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
                button.backgroundColor = isSelected ? .systemBlue : UIColor.secondarySystemGroupedBackground
                button.setTitleColor(isSelected ? .white : .systemGray, for: .normal)
            }
        }
        
        // Load vaccines for selected period
        let period = timePeriods[sender.tag]
        currentPeriod = period
    }

    @objc private func saveButtonTapped() {
        Task {
            do {
                guard let babyId = UserDefaultsManager.shared.currentBabyId else {
                    // Show error alert
                    return
                }
                
                // Get selected vaccine objects
                let selectedVaccineObjects = vaccineData.filter { selectedVaccines.contains($0.name) }
                
                // Navigate to selected vaccines review screen
                await MainActor.run {
                    let selectedVaccinesVC = SelectedVaccinesViewController(selectedVaccines: selectedVaccineObjects)
                    navigationController?.pushViewController(selectedVaccinesVC, animated: true)
                }
            } catch {
                print("Error preparing selected vaccines: \(error)")
                // Show error alert
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension VaccineInputViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = vaccineData.count
        emptyStateLabel.isHidden = count > 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as? VaccineCell else {
            return UITableViewCell()
        }
        
        let vaccine = vaccineData[indexPath.row]
        cell.configure(
            with: vaccine.name,
            timing: getTimingText(startWeek: vaccine.startWeek),
            description: vaccine.description,
            isSelected: selectedVaccines.contains(vaccine.name)
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
}

// MARK: - VaccineCell
protocol VaccineCellDelegate: AnyObject {
    func didTapCheckbox(for vaccine: String)
}

class VaccineCell: UITableViewCell {
    weak var delegate: VaccineCellDelegate?
    private var vaccineName: String = ""
    
    // Container view with iOS-style design
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // Create a circular configuration with no background for unselected state
        let normalImage = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
        
        // Create a circular configuration with checkmark for selected state
        let selectedImage = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.tintColor = .systemBlue
        button.backgroundColor = .clear
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
        
        [titleLabel, timingLabel, descriptionLabel, checkmarkButton].forEach {
            containerView.addSubview($0)
        }
        
        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // iOS-style checkbox on the trailing side
            checkmarkButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Content aligned to the left
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -12),
            
            timingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            timingLabel.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with vaccine: String, timing: String, description: String, isSelected: Bool) {
        vaccineName = vaccine
        titleLabel.text = vaccine
        timingLabel.text = timing
        descriptionLabel.text = description
        checkmarkButton.isSelected = isSelected
        
        // Just change the tint color, not the background
        checkmarkButton.tintColor = isSelected ? .systemBlue : .systemGray3
    }
    @objc private func checkmarkTapped() {
        checkmarkButton.isSelected.toggle()
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        delegate?.didTapCheckbox(for: vaccineName)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        timingLabel.text = nil
        descriptionLabel.text = nil
        checkmarkButton.isSelected = false
    }
}
