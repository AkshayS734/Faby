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
        
        // Make sure chevron can receive touches
        chevronIcon.isUserInteractionEnabled = true
        
        // Add specific tap gesture to the chevron icon
        let chevronTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTodBiteViewController))
        chevronIcon.addGestureRecognizer(chevronTapGesture)
        
        let stackView = UIStackView(arrangedSubviews: [label, chevronIcon])
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Keep the general tap gesture on the whole stack view too for better UX
        stackView.isUserInteractionEnabled = true
        let stackTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTodBiteViewController))
        stackView.addGestureRecognizer(stackTapGesture)
        
        return stackView
    }()
    
    private var todaysBitesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 280, height: 220) // Wider card to match design
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .always
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
//        setupNavigationBar()
        
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
        // Always update Today's Bites when returning to this view
        updateTodaysBites()
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
            
            specialMomentsContainerView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 10),
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
        // Switch to the TodBite tab when chevron is clicked
        // First try using the tab bar controller
        if let tabBarController = self.tabBarController {
            // Look for the TodBite tab by its identifier
            for (index, controller) in (tabBarController.viewControllers ?? []).enumerated() {
                // Check if it's the TodBite tab
                if controller is UINavigationController,
                   let navController = controller as? UINavigationController,
                   navController.viewControllers.first is TodBiteViewController {
                    // Found the TodBite tab, select it
                    tabBarController.selectedIndex = index
                    return
                }
                
                // Some apps might use the tab's title to identify it
                if controller.tabBarItem.title == "TodBite" {
                    tabBarController.selectedIndex = index
                    return
                }
            }
            
            // If we couldn't find it by class or title, try the standard position (usually last tab)
            if let lastIndex = tabBarController.viewControllers?.count, lastIndex > 0 {
                tabBarController.selectedIndex = lastIndex - 1 // Try the last tab
            }
        }
        
        // As a fallback, post a notification for tab switching
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToTodBiteTab"), object: nil)
        
        print("✅ Attempting to navigate to TodBite tab")
    }
    @objc private func updateTodaysBites() {
        print("✅ Fetching Today's Bites...")
        
        // Clear existing data
        todaysBitesData.removeAll()
        
        // STEP 1: First load from UserDefaults
        let savedMeals = UserDefaults.standard.array(forKey: "todaysBites") as? [[String: String]]
        let savedDate = UserDefaults.standard.string(forKey: "selectedDay")
        
        // Get today's date in the same format as stored in meal history
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E d MMM" // e.g. "Wed 7 May"
        let todayFormattedDate = dateFormatter.string(from: today)
        
        // STEP 2: Load from meal history for today's date
        // This handles cases where a weekly plan is stored but today's date is different from selected date
        let mealHistory = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] ?? [:]
        
        var todaysMeals: [[String: String]] = []
        
        // First try to get today's meals from history
        if let mealsForToday = mealHistory[todayFormattedDate] {
            print("📌 Found meals for today (\(todayFormattedDate)): \(mealsForToday.count) meals")
            todaysMeals = mealsForToday
        } 
        // If not found, use saved meals from todaysBites
        else if let savedMeals = savedMeals, !savedMeals.isEmpty {
            print("📌 Using saved meals from todaysBites")
            todaysMeals = savedMeals
        }
        
        // If we still have no meals, try to get from Supabase asynchronously
        if todaysMeals.isEmpty {
            print("⚠️ No meals found in UserDefaults for today, trying to fetch from Supabase...")
            // This would ideally fetch from Supabase, but for now we'll show empty state
            loadMealsFromSupabase()
        } else {
            // Process and display meals
            processMealsForDisplay(todaysMeals)
        }
    }
    
    // New helper method to load meals from Supabase
    private func loadMealsFromSupabase() {
        // Check if we can access the Supabase client
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            print("❌ Could not access SceneDelegate for Supabase client")
            DispatchQueue.main.async {
                self.updateTodaysBitesEmptyState()
            }
            return
        }
        
        // Get Supabase client
        let supabaseClient = sceneDelegate.supabase
        
        // Create date range (today)
        let today = Date()
        
        // Asynchronously load feeding plans
        Task {
            do {
                print("🔄 Attempting to load meals from Supabase...")
                
                // This assumes you have a SupabaseManager.loadFeedingPlansWithMeals method
                // that returns meals organized by date and category
                if let feedingPlans = try? await SupabaseManager.loadFeedingPlansWithMeals(
                    startDate: today,
                    endDate: today, 
                    using: supabaseClient
                ) {
                    // Convert Supabase response to meal dictionaries
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E d MMM"
                    let todayKey = dateFormatter.string(from: today)
                    
                    if let todayPlans = feedingPlans[todayKey], !todayPlans.isEmpty {
                        // Convert to array of meal dictionaries
                        var mealsArray: [[String: String]] = []
                        
                        for (category, meals) in todayPlans {
                            for meal in meals {
                                var mealDict: [String: String] = [
                                    "category": category.rawValue,
                                    "time": getTimeInterval(for: category),
                                    "name": meal.name,
                                    "image": meal.image_url,
                                    "description": meal.description
                                ]
                                mealsArray.append(mealDict)
                            }
                        }
                        
                        // Process and display on main thread
                        DispatchQueue.main.async {
                            self.processMealsForDisplay(mealsArray)
                        }
                        
                        // Save to UserDefaults for future use
                        UserDefaults.standard.set(mealsArray, forKey: "todaysBites")
                        return
                    }
                }
                
                // If we get here, no meals were found in Supabase
                print("⚠️ No meals found in Supabase for today")
                DispatchQueue.main.async {
                    self.updateTodaysBitesEmptyState()
                }
            } catch {
                print("❌ Error loading meals from Supabase: \(error)")
                DispatchQueue.main.async {
                    self.updateTodaysBitesEmptyState()
                }
            }
        }
    }
    
    // Helper method to get time interval string for category
    private func getTimeInterval(for category: BiteType) -> String {
        switch category {
        case .EarlyBite: return "7:30 AM - 8:00 AM"
        case .NourishBite: return "10:00 AM - 10:30 AM"
        case .MidDayBite: return "12:30 PM - 1:00 PM"
        case .SnackBite: return "4:00 PM - 4:30 PM"
        case .NightBite: return "8:00 PM - 8:30 PM"
        case .custom(_): return "No Time Set"
        }
    }
    
    // Helper method to process meals and display them
    private func processMealsForDisplay(_ meals: [[String: String]]) {
        var updatedBites: [TodayBite] = []
        
        for meal in meals {
            // Try both "image" and "image_url" keys for backward compatibility
            let imageKey = meal["image"] ?? meal["image_url"] ?? ""
            
            // Get the meal name, category, and time
            if let mealName = meal["name"], let category = meal["category"], let time = meal["time"] {
                // Create a TodayBite with the meal name as the title and the category as a separate field
                updatedBites.append(TodayBite(
                    title: mealName,
                    time: time,
                    imageName: imageKey,
                    category: category
                ))
            }
        }
        
        // Sort bites by predefined mealtime order
        let predefinedOrder: [String] = ["EarlyBite", "NourishBite", "MidDayBite", "SnackBite", "NightBite"]
        updatedBites.sort { (a, b) -> Bool in
            // Get category for sorting or use empty string if nil
            let categoryA = a.category ?? ""
            let categoryB = b.category ?? ""
            
            // Find indices in predefined order
            let indexA = predefinedOrder.firstIndex(of: categoryA) ?? predefinedOrder.count
            let indexB = predefinedOrder.firstIndex(of: categoryB) ?? predefinedOrder.count
            
            if indexA != indexB {
                // Sort by the predefined order
                return indexA < indexB
            } else if categoryA == categoryB {
                // If same category, maintain original order
                return true
            } else {
                // This handles custom categories, which all have the same index (predefinedOrder.count)
                // We'll just sort them alphabetically
                return categoryA < categoryB
            }
        }
        
        todaysBitesData = updatedBites
        
        // Update UI on main thread
        DispatchQueue.main.async {
            // Force collection view to reload with animation
            UIView.transition(with: self.todaysBitesCollectionView,
                            duration: 0.35,
                             options: .transitionCrossDissolve,
                          animations: {
                              self.todaysBitesCollectionView.reloadData()
                          })
            
            // Update empty state visibility
            self.updateTodaysBitesEmptyState()
        }
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
        return CGSize(width: 225, height: 220)
    }
}


struct VaccineCardsView: View {
    @State private var displayedVaccines: [(VaccineSchedule, String)]
    let vaccines: [(VaccineSchedule, String)]
    var onVaccineCompleted: ((VaccineSchedule, String)) -> Void
    var onVaccineCardTapped: ((VaccineSchedule, String)) -> Void
    
    init(vaccines: [(VaccineSchedule, String)],
         onVaccineCompleted: @escaping ((VaccineSchedule, String)) -> Void,
         onVaccineCardTapped: @escaping ((VaccineSchedule, String)) -> Void) {
        self.vaccines = vaccines
        self._displayedVaccines = State(initialValue: vaccines)
        self.onVaccineCompleted = onVaccineCompleted
        self.onVaccineCardTapped = onVaccineCardTapped
    }
    
    var body: some View {
        VStack {
            if displayedVaccines.isEmpty {
                emptyVaccineView
            } else {
                vaccineCardsListView
            }
        }
        .frame(height: 160)
        .background(Color.clear) // Using transparent background to blend with main screen
    }
    
    // Break down complex SwiftUI expressions into smaller views
    private var emptyVaccineView: some View {
        HStack {
            Image(systemName: "syringe")
                .font(.system(size: 24))
                .foregroundColor(.white)
            Text("No upcoming vaccinations")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(height: 100)
        .padding(16)
        .background(Color.clear) // Using transparent background to blend with main screen
        .cornerRadius(16)
    }
    
    private var vaccineCardsListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(Array(displayedVaccines.enumerated()), id: \.element.0.id) { index, tuple in
                    vaccineCardView(for: tuple)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .frame(height: 120)
        .background(Color.clear) // Using transparent background to blend with main screen
        .animation(.default, value: displayedVaccines.count)
    }
    
    private func vaccineCardView(for tuple: (VaccineSchedule, String)) -> some View {
        let (vaccine, vaccineName) = tuple
        return VaccineCard(
            vaccine: vaccine,
            vaccineName: vaccineName,
            onComplete: {
                handleVaccineCompletion(vaccine: vaccine, tuple: tuple)
            },
            onCardTapped: {
                onVaccineCardTapped(tuple)
            }
        )
    }
    
    private func handleVaccineCompletion(vaccine: VaccineSchedule, tuple: (VaccineSchedule, String)) {
        print("📱 Vaccine card tapped for completion: \(vaccine.vaccineId)")
        // Use withAnimation to smoothly remove the card
        withAnimation(.easeOut(duration: 0.3)) {
            // Find and remove the completed vaccine from our local array
            if let index = displayedVaccines.firstIndex(where: { $0.0.id == vaccine.id }) {
                displayedVaccines.remove(at: index)
            }
        }
        // Call the completion handler to update the parent view/model
        onVaccineCompleted(tuple)
    }
}

struct VaccineCard: View {
    let vaccine: VaccineSchedule
    let vaccineName: String
    let onComplete: () -> Void
    let onCardTapped: () -> Void
    @State private var isCompleted: Bool
    @State private var showConfirmation = false
    @State private var showReschedulePrompt = false
    
    init(vaccine: VaccineSchedule,
         vaccineName: String,
         onComplete: @escaping () -> Void,
         onCardTapped: @escaping () -> Void) {
        self.vaccine = vaccine
        self.vaccineName = vaccineName
        self.onComplete = onComplete
        self.onCardTapped = onCardTapped
        _isCompleted = State(initialValue: vaccine.isAdministered)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Vaccine Name and Icon
            HStack {
                Image(systemName: "syringe")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.systemBlue))
                    .frame(width: 24)
                
                Text(vaccineName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Button(action: {
                    showConfirmation = true
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : Color(.systemGray3))
                        .font(.system(size: 22))
                }
                .disabled(isCompleted)
            }
            .contentShape(Rectangle()) // Make entire row tappable
            
            // Date and Hospital Info
            VStack(alignment: .leading, spacing: 8) {
                // Create a variable for formatted date string outside the HStack
                let formattedDate: String = {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    return dateFormatter.string(from: vaccine.date)
                }()
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 14))
                        .frame(width: 16)
                    
                    Text(formattedDate)
                        .font(.system(size: 14))
                        .foregroundColor(Color(.darkGray))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: 14))
                        .frame(width: 16)
                    
                    Text(vaccine.hospital)
                        .font(.system(size: 14))
                        .foregroundColor(Color(.darkGray))
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(width: 280, height: 130)
        .background(Color.white) // Changed from .clear to .white
        .cornerRadius(16)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle()) // Make entire card tappable
        .onTapGesture {
            onCardTapped()
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Confirm Vaccination"),
                message: Text("Has this \(vaccineName) vaccine been administered to your child?"),
                primaryButton: .default(Text("Yes")) {
                    isCompleted = true
                    // Just call onComplete immediately - the parent view will handle the animation
                    onComplete()
                },
                secondaryButton: .cancel(Text("No")) {
                    // Just close the dialog without any action
                }
            )
        }
        .sheet(isPresented: $showReschedulePrompt) {
            RescheduleVaccineView(vaccine: vaccine, vaccineName: vaccineName)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct RescheduleVaccineView: View {
    let vaccine: VaccineSchedule
    let vaccineName: String
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reschedule \(vaccineName)")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker(
                    "Select New Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Button(action: {
                    // Here you would implement the actual rescheduling logic
                    // connecting to your VaccineScheduleManager
                    Task {
                        do {
                            try await VaccineScheduleManager.shared.updateSchedule(
                                recordId: vaccine.id,
                                newDate: selectedDate,
                                newHospital: Hospital(
                                    id: UUID(),
                                    babyId: vaccine.babyID,
                                    name: vaccine.hospital,
                                    address: vaccine.location,
                                    distance: 0.0
                                )
                            )
                            // Post notification to refresh the view
                            NotificationCenter.default.post(
                                name: NSNotification.Name("NewVaccineScheduled"),
                                object: nil
                            )
                        } catch {
                            print("Failed to reschedule vaccine: \(error)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save New Date")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
