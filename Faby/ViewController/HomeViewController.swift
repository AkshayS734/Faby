import UIKit
import SwiftUI
import Foundation

class HomeViewController: UIViewController {
    // For storing navigation bar blur effect view
    private var navigationBarBlurEffectView: UIVisualEffectView?
    
    // Gradient layer for the background - same as AuthViewController
    private let gradientLayer = CAGradientLayer()
    
    private let storageManager = SupabaseVaccineManager.shared
    var scheduledVaccines: [[String: String]] = []
    private var administeredVaccines: [[String: String]] = []
    var vaccineView: UIView?
    var dataController: DataController {
        return DataController.shared
    }
    var baby : Baby?
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // Using navigation bar's large title instead of custom nameLabel
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        // We'll position this right below the navigation bar's large title
        return label
    }()
    private let specialMomentsLabel: UILabel = {
        let label = UILabel()
        label.text = "Special Moments"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let specialMomentsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let todaysBitesLabel: UIStackView = {
        let label = UILabel()
        label.text = "Today's Bites"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        
        let chevronIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronIcon.tintColor = .black
        chevronIcon.contentMode = .scaleAspectFit
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        chevronIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [label, chevronIcon])
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    private var todaysBitesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 220, height: 160)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let upcomingVaccinationLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Vaccination"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let vaccinationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Add missing vaccineContainerView
    private let vaccineContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.systemGray4.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()
    
    // Loading indicator for upcoming vaccination section
    private let vaccinationLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var todaysBitesData: [TodayBite] = []
    
    private let todaysBitesEmptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = false
        // iOS-native card shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let todaysBitesContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let todaysBitesEmptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "todayBite")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let todaysBitesEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meal plan added yet"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addMealPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Meal Plan", for: .normal)
        button.backgroundColor = UIColor(red: 98/255, green: 206/255, blue: 156/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 22 // Half of height for pill shape
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baby = dataController.baby
        print("🚀 HomeViewController viewDidLoad")
        view.backgroundColor = .systemGroupedBackground
        
        // Set up navigation bar with large title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Home"
        
        // Setup the navigation bar with gradient and blur effects
        setupNavigationBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(goToSettings)
        )
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 220, height: 160)
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        todaysBitesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        todaysBitesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        todaysBitesCollectionView.backgroundColor = .clear
        todaysBitesCollectionView.showsHorizontalScrollIndicator = false
        todaysBitesCollectionView.delegate = self
        todaysBitesCollectionView.dataSource = self
        todaysBitesCollectionView.register(TodayBiteCollectionViewCell.self, forCellWithReuseIdentifier: "BitesCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openTodBiteViewController))
        todaysBitesLabel.addGestureRecognizer(tapGesture)
        
        setupUI()
        setupDelegates()
        
        // Fetch current baby data first
        Task {
            do {
                self.baby = try await fetchCurrentBaby()
                // Now that we have the baby data, we can load vaccinations
                await MainActor.run {
                    loadVaccinations()
                    // Update UI with baby name
                    if let babyName = baby?.name {
                        title = "\(babyName)"
                    }
                }
            } catch {
                print("❌ Error fetching baby data: \(error)")
                // Still try to load vaccinations with default UUID
                await MainActor.run {
                    loadVaccinations()
                }
            }
        }
        
        // Navigation title is set directly in viewDidLoad instead of using updateNameLabel()
        updateDateLabel()
        updateTodaysBites()
        embedSpecialMomentsViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🚀 HomeViewController viewWillAppear")
        
        // Ensure large title is always displayed when coming from any tab
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // If we have baby data, update the title
        if let babyName = baby?.name {
            title = "\(babyName)'s Home"
        }
        
        loadVaccinations() // Reload vaccinations when view appears
        updateSpecialMoments()
        updateDateLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient covers the entire view when layout changes
        gradientLayer.frame = view.bounds
    }
    
    // This method has been replaced with the implementation at line ~635 that uses tab bar navigation
    
    // MARK: - Baby Data Fetching
    
    /// Fetch the current baby data directly from Supabase
    private func fetchCurrentBaby() async throws -> Baby {
        // Try to get current baby ID from UserDefaults
        if let currentBabyId = UserDefaultsManager.shared.currentBabyId {
            // Get baby details from Supabase
            return try await fetchBaby(with: currentBabyId)
        }
        
        // If no current baby ID, fetch first connected baby
        return try await fetchFirstConnectedBaby()
    }
    
    @objc func goToSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func updateSpecialMoments() {
        DispatchQueue.main.async {
            self.removeEmbeddedView()
            self.embedSpecialMomentsViewController()
        }
    }
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Using navigation bar's large title instead of custom nameLabel
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsContainerView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        
        // Add the vaccination container view
        contentView.addSubview(upcomingVaccinationLabel)
        contentView.addSubview(vaccineContainerView)
        
        // Add loading indicator to the vaccine container view
        vaccineContainerView.addSubview(vaccinationLoadingIndicator)
        
        // Add empty state views with proper hierarchy
        contentView.addSubview(todaysBitesEmptyStateView)
        todaysBitesEmptyStateView.addSubview(todaysBitesContentStack)
        
        todaysBitesContentStack.addArrangedSubview(todaysBitesEmptyImageView)
        todaysBitesContentStack.addArrangedSubview(todaysBitesEmptyLabel)
        todaysBitesContentStack.addArrangedSubview(addMealPlanButton)
        
        // Set custom spacing after image
        todaysBitesContentStack.setCustomSpacing(8, after: todaysBitesEmptyImageView)
        todaysBitesContentStack.setCustomSpacing(16, after: todaysBitesEmptyLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Position dateLabel to be right below the large title with minimal spacing
            dateLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            specialMomentsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            specialMomentsLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            specialMomentsContainerView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 0),
            specialMomentsContainerView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            specialMomentsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            specialMomentsContainerView.heightAnchor.constraint(equalToConstant: 225),
            
            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor, constant: 24),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 225),
            
            // Add constraints for the vaccination container
            upcomingVaccinationLabel.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 24),
            upcomingVaccinationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            vaccineContainerView.topAnchor.constraint(equalTo: upcomingVaccinationLabel.bottomAnchor, constant: 10),
            vaccineContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineContainerView.heightAnchor.constraint(equalToConstant: 165),
            vaccineContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Add constraints for the vaccination loading indicator
            vaccinationLoadingIndicator.centerXAnchor.constraint(equalTo: vaccineContainerView.centerXAnchor),
            vaccinationLoadingIndicator.centerYAnchor.constraint(equalTo: vaccineContainerView.centerYAnchor),
            
            // Card constraints
            todaysBitesEmptyStateView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 12),
            todaysBitesEmptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            todaysBitesEmptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Content stack constraints
            todaysBitesContentStack.topAnchor.constraint(equalTo: todaysBitesEmptyStateView.topAnchor, constant: 24),
            todaysBitesContentStack.leadingAnchor.constraint(equalTo: todaysBitesEmptyStateView.leadingAnchor, constant: 16),
            todaysBitesContentStack.trailingAnchor.constraint(equalTo: todaysBitesEmptyStateView.trailingAnchor, constant: -16),
            todaysBitesContentStack.bottomAnchor.constraint(equalTo: todaysBitesEmptyStateView.bottomAnchor, constant: -24),
            
            // Image constraints
            todaysBitesEmptyImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            todaysBitesEmptyImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            // Button constraints
            addMealPlanButton.heightAnchor.constraint(equalToConstant: 44),
            addMealPlanButton.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        addMealPlanButton.addTarget(self, action: #selector(addMealPlanTapped), for: .touchUpInside)
        
        // Update the empty state visibility
        updateTodaysBitesEmptyState()
    }
    private func setupVaccineView() {
        print("🔄 Setting up vaccine view with \(scheduledVaccines.count) vaccines")
        
        // Use the correct VaccineSchedule objects with their original IDs
        var vaccineSchedulesWithNames: [(VaccineSchedule, String)] = []
        
        // Match each scheduled vaccine dictionary with its corresponding VaccineSchedule object
        for dict in scheduledVaccines {
            guard let idString = dict["id"],
                  let vaccineName = dict["type"],
                  let id = UUID(uuidString: idString) else {
                continue
            }
            
            // Find the matching VaccineSchedule from actualScheduledVaccines
            if let matchingSchedule = actualScheduledVaccines.first(where: { $0.id == id }) {
                vaccineSchedulesWithNames.append((matchingSchedule, vaccineName))
            } else {
                // Fallback to creating a new object if we can't find the original
                guard let dateString = dict["date"],
                      let hospital = dict["hospital"],
                      let vaccineIdString = dict["vaccineId"],
                      let isAdministeredString = dict["isAdministered"],
                      let vaccineId = UUID(uuidString: vaccineIdString) else {
                    continue
                }
                
                // Create a date from the string
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                guard let date = dateFormatter.date(from: dateString) else {
                    print("❌ Could not parse date: \(dateString)")
                    continue
                }
                
                let schedule = VaccineSchedule(
                    id: id,
                    babyID: baby?.babyID ?? UUID(),
                    vaccineId: vaccineId,
                    hospital: hospital,
                    date: date,
                    location: dict["location"] ?? "",
                    isAdministered: isAdministeredString.lowercased() == "true"
                )
                vaccineSchedulesWithNames.append((schedule, vaccineName))
            }
        }

        // Debug the content of scheduled vaccines
        for (i, tuple) in vaccineSchedulesWithNames.enumerated() {
            let (vaccine, vaccineName) = tuple
            print("📊 Scheduled vaccine \(i):")
            print("   - Name: \(vaccineName)")
            print("   - Date: \(vaccine.date)")
            print("   - Hospital: \(vaccine.hospital)")
            print("   - Record type: VaccineSchedule")
        }
        
        let workItem = DispatchWorkItem {
            // Remove any existing vaccine view
            if let existingVaccineView = self.vaccineView {
                existingVaccineView.removeFromSuperview()
                self.vaccineView = nil
            }
            
            // Remove any existing hosting controller
            if let oldVaccineViewController = self.children.first(where: { $0 is UIHostingController<VaccineCardsView> }) {
                oldVaccineViewController.willMove(toParent: nil)
                oldVaccineViewController.view.removeFromSuperview()
                oldVaccineViewController.removeFromParent()
            }
            
            // Create the vaccine cards view with the callbacks for both completion and navigation
            let vaccineCardsView = UIHostingController(rootView: VaccineCardsView(
                vaccines: vaccineSchedulesWithNames,
                onVaccineCompleted: { [weak self] tuple in
                    let (vaccine, name) = tuple
                    print("📱 Vaccine card tapped for completion: \(vaccine.id)")
                    print("📱 Vaccine completion requested for: \(vaccine.vaccineId)")
                    Task {
                        do {
                            // Directly use the vaccine.id from the VaccineSchedule object
                            let scheduleId = vaccine.id.uuidString
                            
                            // Use SupabaseVaccineManager to mark vaccine as administered
                            try await SupabaseVaccineManager.shared.markVaccineAsAdministered(
                                scheduleId: scheduleId,
                                administeredDate: Date()
                            )
                            print("✅ Vaccine '\(name)' marked as administered in Supabase - ID: \(scheduleId)")
                            
                            // Reload vaccinations
                            await MainActor.run {
                                self?.loadVaccinations()
                            }
                        } catch {
                            print("❌ Error completing vaccine: \(error)")
                        }
                    }
                },
                onVaccineCardTapped: { [weak self] tuple in
                    let (vaccine, name) = tuple
                    print("🔍 Navigating to details for vaccine: \(name) (ID: \(vaccine.id))")
                    self?.navigateToVaccineDetails(vaccine: vaccine, vaccineName: name)
                }
            ))
            // Add the view controller as a child
            self.addChild(vaccineCardsView)
            vaccineCardsView.view.translatesAutoresizingMaskIntoConstraints = false
            vaccineCardsView.view.backgroundColor = UIColor(hex: "#f2f2f7")
            // Add and constrain the view
            self.vaccineContainerView.addSubview(vaccineCardsView.view)
            NSLayoutConstraint.activate([
                vaccineCardsView.view.topAnchor.constraint(equalTo: self.vaccineContainerView.topAnchor),
                vaccineCardsView.view.leadingAnchor.constraint(equalTo: self.vaccineContainerView.leadingAnchor),
                vaccineCardsView.view.trailingAnchor.constraint(equalTo: self.vaccineContainerView.trailingAnchor),
                vaccineCardsView.view.bottomAnchor.constraint(equalTo: self.vaccineContainerView.bottomAnchor)
            ])
            vaccineCardsView.didMove(toParent: self)
            self.vaccineView = vaccineCardsView.view
        }
        DispatchQueue.main.async(execute: workItem)
    }
    
    private func setupDelegates() {
        todaysBitesCollectionView.delegate = self
        todaysBitesCollectionView.dataSource = self
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: Date())
    }
    
    // Store the actual VaccineSchedule objects for direct access
    private var actualScheduledVaccines: [VaccineSchedule] = []
    
    private func loadVaccinations() {
        print("📋 Loading vaccinations...")
        print("🌐 Fetching all vaccination records from Supabase...")
        
        // Show loading indicator
        vaccinationLoadingIndicator.startAnimating()
        
        Task {
            do {
                // Fetch all scheduled vaccines from Supabase (no baby filter)
                let allScheduledRecords = try await VaccineScheduleManager.shared.fetchAllSchedules()
                print("✅ Successfully fetched \(allScheduledRecords.count) scheduled vaccination records (all babies)")
                
                // Filter out administered vaccines and store only non-administered ones
                self.actualScheduledVaccines = allScheduledRecords.filter { !$0.isAdministered }
                
                // Fetch administered vaccines for all babies (optional, can be filtered if needed)
                let allAdministeredRecords = try await AdministeredVaccineManager.shared.fetchAllAdministeredVaccines()
                print("✅ Successfully fetched \(allAdministeredRecords.count) administered vaccination records (all babies)")
                
                // Convert scheduled records to dictionaries with the original ID stored
                // Filter out administered vaccines
                var scheduledDictionaries: [[String: String]] = []
                for record in allScheduledRecords.filter({ !$0.isAdministered }) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let vaccineName = await getVaccineName(for: record.vaccineId)
                    let dict: [String: String] = [
                        "id": record.id.uuidString, // Store the original ID
                        "type": vaccineName,
                        "date": dateFormatter.string(from: record.date),
                        "hospital": record.hospital,
                        "location": record.location,
                        "vaccineId": record.vaccineId.uuidString, // Store vaccine ID
                        "isAdministered": String(record.isAdministered)
                    ]
                    scheduledDictionaries.append(dict)
                }
                
                // Convert administered records to dictionaries
                var administeredDictionaries: [[String: String]] = []
                for record in allAdministeredRecords {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let vaccineName = await getVaccineName(for: record.vaccineId)
                    let dict: [String: String] = [
                        "id": record.id.uuidString,
                        "type": vaccineName,
                        "date": dateFormatter.string(from: record.administeredDate),
                        "hospital": "Unknown Hospital",
                        "location": "Unknown Location",
                        "isAdministered": "true"
                    ]
                    administeredDictionaries.append(dict)
                }
                
                print("📊 Processed \(scheduledDictionaries.count) scheduled and \(administeredDictionaries.count) administered vaccines (all babies)")
                
                await MainActor.run {
                    self.scheduledVaccines = scheduledDictionaries
                    self.administeredVaccines = administeredDictionaries
                    print("🔢 UI updated with \(self.scheduledVaccines.count) scheduled and \(self.administeredVaccines.count) administered vaccines (all babies)")
                    self.setupVaccineView()
                    self.updateTodaysBitesEmptyState()
                    self.todaysBitesCollectionView.reloadData()
                    
                    // Stop the loading indicators
                    self.vaccinationLoadingIndicator.stopAnimating()
                }
            } catch {
                print("❌ Failed to load vaccination records from Supabase: \(error.localizedDescription)")
                await MainActor.run {
                    // Stop loading indicator
                    self.vaccinationLoadingIndicator.stopAnimating()
                    
                    // Show error state or empty state
                    print("📦 Error fetching vaccination data: \(error.localizedDescription)")
                    self.setupVaccineView() // Setup with empty data
                    self.updateTodaysBitesEmptyState()
                    self.todaysBitesCollectionView.reloadData()
                }
            }
        }
    }
    
    // Helper method to get vaccine name from ID
    private func getVaccineName(for vaccineId: UUID) async -> String {
        do {
            // Use SupabaseVaccineManager instead of FetchingVaccines
            let allVaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
            if let vaccine = allVaccines.first(where: { $0.id == vaccineId }) {
                return vaccine.name
            }
            
            // Fallback to fetching from VaccineManager's static data if needed
            for stage in VaccineManager.shared.vaccineData {
                for vaccineName in stage.vaccines {
                    // This is a simple check - in practice you'd want to match more precisely
                    if vaccineName.contains(vaccineId.uuidString.prefix(8)) {
                        return vaccineName
                    }
                }
            }
            
            return "Unknown Vaccine"
        } catch {
            print("❌ Error fetching vaccine name: \(error)")
            
            // Fallback to local data
            return "Vaccine \(vaccineId.uuidString.prefix(8))"
        }
    }
    
    @objc private func openTodBiteViewController() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 4
        } else {
            print("⚠️ TabBarController not found")
        }
    }
    
    // Setup background gradient - exactly like AuthViewController
    private func setupNavigationBar() {
        // Match the AuthViewController exactly
        gradientLayer.colors = [
            UIColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,  // Light blue at top - exact match to AuthViewController
            UIColor.white.cgColor  // White at bottom - exact match to AuthViewController
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.3)  // Gradient fades to white faster
        
        // Apply gradient to the entire view just like in AuthViewController
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Set background to white so it matches AuthViewController
        view.backgroundColor = .white
        
        // Configure navigation bar with modern iOS appearance
        if let navigationBar = navigationController?.navigationBar {
            // Enable large titles properly
            navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            
            // iOS 15+ appearance with different states
            if #available(iOS 15.0, *) {
                // Create large title appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                
                // Standard appearance (when scrolled) - with blur effect
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
                appearance.backgroundColor = UIColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 0.7)
                
                // Large title text attributes - make them bold and larger
                appearance.largeTitleTextAttributes = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold)
                ]
                
                // Apply appearances to all navigation bar states
                navigationBar.standardAppearance = appearance
                navigationBar.compactAppearance = appearance
                
                // Scroll edge appearance should be transparent to show the gradient
                let scrollEdgeAppearance = UINavigationBarAppearance()
                scrollEdgeAppearance.configureWithTransparentBackground()
                scrollEdgeAppearance.largeTitleTextAttributes = appearance.largeTitleTextAttributes
                navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
            } else {
                // iOS 14 and below
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.isTranslucent = true
                navigationBar.largeTitleTextAttributes = [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 34, weight: .bold)
                ]
            }
        }
    }
    
    @objc private func updateTodaysBites() {
        guard let savedMeals = UserDefaults.standard.array(forKey: "todaysBites") as? [[String: String]],
              let savedDate = UserDefaults.standard.string(forKey: "selectedDay") else {
//            print("⚠️ No saved meals found!")
            return
        }
        
//        print("📌 Saved Meals: \(savedMeals)")
//        print("📌 Saved Date: \(savedDate)")
//
        var updatedBites: [TodayBite] = []
        
        for meal in savedMeals {
            if let title = meal["category"], let time = meal["time"], let imageName = meal["image"] {
                updatedBites.append(TodayBite(title: title, time: time, imageName: imageName))
            }
        }
        let predefinedOrder: [String] = ["EarlyBite", "NourishBite", "MidDayBite", "SnackBite", "NightBite"]
        updatedBites.sort { (a, b) -> Bool in
            let indexA = predefinedOrder.firstIndex(of: a.title) ?? predefinedOrder.count
            let indexB = predefinedOrder.firstIndex(of: b.title) ?? predefinedOrder.count
            return indexA < indexB
        }
        todaysBitesData = updatedBites
        todaysBitesCollectionView.reloadData()
        
        // Update the empty state
        updateTodaysBitesEmptyState()
    }
    
    @objc private func handleNewVaccineScheduled(_ notification: Notification) {
        print("📣 Received NewVaccineScheduled notification")
        // Use a small delay to ensure database consistency
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadVaccinations()
        }
    }
    
    private func removeEmbeddedView() {
        for subview in specialMomentsContainerView.subviews {
            subview.removeFromSuperview()
        }
        for child in children {
            if child is SpecialMomentsViewController {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
    }
    
    
    private func embedSpecialMomentsViewController() {
        let specialMomentsVC = SpecialMomentsViewController()
        addChild(specialMomentsVC)
        specialMomentsVC.view.translatesAutoresizingMaskIntoConstraints = false
        specialMomentsContainerView.addSubview(specialMomentsVC.view)
        specialMomentsVC.populateMilestones()
        NSLayoutConstraint.activate([
            specialMomentsVC.view.topAnchor.constraint(equalTo: specialMomentsContainerView.topAnchor),
            specialMomentsVC.view.leadingAnchor.constraint(equalTo: specialMomentsContainerView.leadingAnchor),
            specialMomentsVC.view.trailingAnchor.constraint(equalTo: specialMomentsContainerView.trailingAnchor),
            specialMomentsVC.view.bottomAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor)
        ])
        
        specialMomentsVC.didMove(toParent: self)
    }
    
    // MARK: - Actions and Handlers
    @objc private func addMealPlanTapped() {
        print("Add meal plan tapped")
        // Implement meal plan addition navigation
    }
    
    // MARK: - Navigation
    private func navigateToVaccineDetails(vaccine: VaccineSchedule, vaccineName: String) {
        // Create the VaccineReminderViewController
        let vaccineReminderVC = VaccineReminderViewController()
        
        // Set any needed properties or data
        vaccineReminderVC.selectedVaccineId = vaccine.vaccineId.uuidString
        vaccineReminderVC.selectedVaccineName = vaccineName
        vaccineReminderVC.selectedScheduleId = vaccine.id.uuidString
        
        // Configure any initial state if needed
        vaccineReminderVC.hidesBottomBarWhenPushed = true // Hide bottom tab bar for a cleaner detail view
        
        // Add smooth iOS-native transition animation
        UIView.transition(with: navigationController!.view,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
        
        // Navigate to the vaccine details screen
        navigationController?.pushViewController(vaccineReminderVC, animated: true)
    }

    private func updateTodaysBitesEmptyState() {
        if todaysBitesData.isEmpty {
            todaysBitesCollectionView.isHidden = true
            todaysBitesEmptyStateView.isHidden = false
        } else {
            todaysBitesCollectionView.isHidden = false
            todaysBitesEmptyStateView.isHidden = true
        }
    }
}



// MARK: - UICollection View

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todaysBitesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BitesCell", for: indexPath) as? TodayBiteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let bite = todaysBitesData[indexPath.row]
        cell.configure(with: bite)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 225, height: 190)
    }
}
