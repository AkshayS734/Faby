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
    private let todaysBitesLabel: UIView = {
        // Create a container view for better touch handling
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = true
        
        // Create title label
        let label = UILabel()
        label.text = "Today's Bites"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Create chevron with larger tappable area
        let chevronIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronIcon.tintColor = .black
        chevronIcon.contentMode = .scaleAspectFit
        chevronIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to container
        containerView.addSubview(label)
        containerView.addSubview(chevronIcon)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            chevronIcon.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            chevronIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add padding to increase the touch area
        containerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        return containerView
    }()
    
    private var todaysBitesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 220)
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .always
        return collectionView
    }()
    
    // Add page control for Today's Bites
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.systemGray5
        pageControl.currentPageIndicatorTintColor = UIColor.systemBlue
        
        if #available(iOS 14.0, *) {
            // Make the dots smaller
            pageControl.preferredIndicatorImage = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
            pageControl.preferredCurrentPageIndicatorImage = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
        }
        
        // Scale down the dots (make them smaller)
        pageControl.transform = CGAffineTransform(scaleX: 1, y: 0.8)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
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
    
    // Activity indicator for general loading operations
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
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
    
    // Add timer property
    private var autoScrollTimer: Timer?
    private let autoScrollInterval: TimeInterval = 3.0 // Scroll every 3 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baby = dataController.baby
        print("🚀 HomeViewController viewDidLoad")
        view.backgroundColor = .systemGroupedBackground
        tabBarItem.title = "Home"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        if let babyName = baby?.name {
            navigationItem.title = "\(babyName)"
        }
        
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
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 220)
        layout.minimumLineSpacing = 32
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        todaysBitesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        todaysBitesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        todaysBitesCollectionView.backgroundColor = .clear
        todaysBitesCollectionView.showsHorizontalScrollIndicator = false
        todaysBitesCollectionView.isPagingEnabled = false
        todaysBitesCollectionView.decelerationRate = .fast
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
        
        // Add the tap gesture to the todaysBitesLabel container
        let todaysBitesTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTodBiteViewController))
        todaysBitesLabel.addGestureRecognizer(todaysBitesTapGesture)
        
        // Add visual feedback for tapping
        todaysBitesLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTodaysBitesTouch(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🚀 HomeViewController viewWillAppear")
        // Check if baby data is available, if not reload it
                if baby == nil || baby?.name == nil || baby?.name.isEmpty == true {
                    print("⚠️ Baby data missing or incomplete in HomeViewController, reloading from server")
                    Task {
                        do {
                            // Try to reload baby data
                            await dataController.loadBabyData()
                            self.baby = dataController.baby
                            
                            // Update UI on main thread
                            await MainActor.run {
                                if let babyName = baby?.name {
                                    navigationItem.title = babyName
                                    print("✅ Baby data reloaded successfully: \(babyName)")
                                } else {
                                    print("❌ Failed to reload baby name")
                                }
                            }
                        } catch {
                            print("❌ Error loading baby data: \(error)")
                        }
                    }
                } else {
                    // Ensure the title is set correctly even if we already have the baby data
                    if let babyName = baby?.name {
                        navigationItem.title = babyName
                        print("👶 Using existing baby data: \(babyName)")
                    }
                }
        loadVaccinations() // Reload vaccinations when view appears
        updateSpecialMoments()
        // Always update Today's Bites when returning to this view
        updateTodaysBites()
        
        // Check for overdue vaccines when view appears
        checkForOverdueVaccines()
        startAutoScrollTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        // Stop auto-scrolling timer when leaving the view
        stopAutoScrollTimer()
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
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Using navigation bar's large title instead of custom nameLabel
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsContainerView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        contentView.addSubview(pageControl)
        
        // Add the vaccination container view
        contentView.addSubview(upcomingVaccinationLabel)
        contentView.addSubview(vaccineContainerView)
        
        // Add loading indicator to the vaccine container view
        vaccineContainerView.addSubview(vaccinationLoadingIndicator)
        
        // Add activity indicator for general loading operations
        view.addSubview(activityIndicator)
        
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
            todaysBitesLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            // Page control constraints
            pageControl.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 12),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 30),
            
            // Add constraints for the vaccination container
            upcomingVaccinationLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            upcomingVaccinationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            vaccineContainerView.topAnchor.constraint(equalTo: upcomingVaccinationLabel.bottomAnchor, constant: 10),
            vaccineContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineContainerView.heightAnchor.constraint(equalToConstant: 165),
            vaccineContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Add constraints for the vaccination loading indicator
            vaccinationLoadingIndicator.centerXAnchor.constraint(equalTo: vaccineContainerView.centerXAnchor),
            vaccinationLoadingIndicator.centerYAnchor.constraint(equalTo: vaccineContainerView.centerYAnchor),
            
            // Add constraints for the general activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
        print("🚀 Chevron tapped - attempting to navigate to TodBite tab (tab index 4)")
        
        // Based on your screenshot, the TodBite tab is the 5th tab (index 4)
        guard let tabBarController = self.tabBarController else {
            print("❌ Tab bar controller not found!")
            return
        }
        
        // Log all tabs for debugging
        for (i, controller) in (tabBarController.viewControllers ?? []).enumerated() {
            print("Tab \(i): \(controller.tabBarItem.title ?? "Unknown")")
        }
        
        // Direct selection of the TodBite tab (index 4 based on screenshot)
        if (tabBarController.viewControllers?.count ?? 0) > 4 {
            // Show a flash animation on the tab bar item as visual feedback
            if let tabItems = tabBarController.tabBar.items, tabItems.count > 4 {
                let tabItem = tabItems[4]
                let originalImage = tabItem.image
                tabItem.image = UIImage(systemName: "checkmark.circle.fill")
                
                // Reset after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    tabItem.image = originalImage
                    tabBarController.selectedIndex = 4
                }
            } else {
                tabBarController.selectedIndex = 4
            }
        }
    }
    
    @objc private func handleTodaysBitesTouch(_ gesture: UITapGestureRecognizer) {
        // Provide visual feedback when tapped
        UIView.animate(withDuration: 0.1, animations: {
            self.todaysBitesLabel.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.todaysBitesLabel.alpha = 1.0
            }
        }
        
        // Also call the navigation method
        openTodBiteViewController()
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
        
        // After todaysBitesData is updated, restart the timer if needed
        if let _ = autoScrollTimer, todaysBitesData.count > 1 {
            startAutoScrollTimer()
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
    
    // MARK: - Overdue Vaccine Check and Alert
    
    /// Check for any vaccines that were scheduled for yesterday or earlier and have not been administered
    private func checkForOverdueVaccines() {
        print("🔍 Checking for overdue vaccines...")
        Task {
            do {
                // Fetch overdue vaccines using SupabaseVaccineManager
                let overdueVaccines = try await SupabaseVaccineManager.shared.fetchOverdueVaccines()
                
                // If there are any overdue vaccines, show an alert on the main thread
                if !overdueVaccines.isEmpty {
                    await MainActor.run {
                        // Show alert for the first overdue vaccine
                        showOverdueVaccineAlert(for: overdueVaccines[0])
                    }
                } else {
                    print("✅ No overdue vaccines found")
                }
            } catch {
                print("❌ Error checking for overdue vaccines: \(error)")
            }
        }
    }
    
    /// Show an Apple-native alert asking if the user has administered the overdue vaccine
    private func showOverdueVaccineAlert(for vaccine: (VaccineSchedule, String)) {
        let (vaccineSchedule, vaccineName) = vaccine
        
        // Format the date for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedDate = dateFormatter.string(from: vaccineSchedule.date)
        
        // Create an iOS-native alert controller
        let alert = UIAlertController(
            title: "Overdue Vaccination",
            message: "The \(vaccineName) vaccine was scheduled for \(formattedDate). Has this vaccine been administered?",
            preferredStyle: .alert
        )
        
        // Add "Yes" action to mark as administered
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.markVaccineAsAdministered(vaccineSchedule)
        }
        
        // Add "Reschedule" action instead of "No"
        let rescheduleAction = UIAlertAction(title: "Reschedule", style: .default) { [weak self] _ in
            self?.showDatePicker(for: vaccineSchedule, vaccineName: vaccineName)
        }
        
        // Add "Remind Me Later" option
        let remindLaterAction = UIAlertAction(title: "Remind Me Later", style: .cancel)
        
        // Add actions to the alert controller
        alert.addAction(yesAction)
        alert.addAction(rescheduleAction)
        alert.addAction(remindLaterAction)
        
        // Present the alert
        present(alert, animated: true)
    }
    
    /// Shows a date picker alert for rescheduling a vaccine
    private func showDatePicker(for vaccineSchedule: VaccineSchedule, vaccineName: String) {
        // Create alert controller with action sheet style
        let alertController = UIAlertController(title: "Reschedule \(vaccineName)", message: "Select a new date", preferredStyle: .actionSheet)
        
        // Create custom view for date picker with sufficient height
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.bounds.width - 16, height: 380))
        
        // Create and configure date picker using iOS-native inline style
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline  // Modern iOS inline calendar style
        
        // Set minimum date to today (can't schedule in the past)
        datePicker.minimumDate = Date()
        
        // Set the date to a week from now as default
        datePicker.date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        // Configure datePicker to properly fit in the view
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(datePicker)
        
        // Add constraints to ensure datePicker is properly sized and positioned
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: customView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: customView.bottomAnchor)
        ])
        
        // Add custom view to alert
        alertController.view.addSubview(customView)
        
        // Adjust alert height to accommodate date picker and prevent cut-off dates
        let heightConstraint = NSLayoutConstraint(
            item: alertController.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 580 // Increased height to ensure all dates are visible
        )
        alertController.view.addConstraint(heightConstraint)
        
        // Add actions
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Start loading state
            self.activityIndicator.startAnimating()
            
            // Get the selected date
            let newDate = datePicker.date
            
            // Update the schedule in the database
            Task {
                do {
                    try await self.updateVaccineScheduleDate(vaccineSchedule, newDate: newDate)
                    
                    // Once updated, reload vaccinations
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.showToast(message: "Vaccine rescheduled successfully")
                        self.loadVaccinations()
                    }
                } catch {
                    print("❌ Error rescheduling vaccine: \(error)")
                    
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.showToast(message: "Failed to reschedule. Please try again.")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    
    /// Update the scheduled date for a vaccine
    private func updateVaccineScheduleDate(_ vaccineSchedule: VaccineSchedule, newDate: Date) async throws {
        // Use VaccineScheduleManager to update the schedule
        try await VaccineScheduleManager.shared.updateSchedule(
            recordId: vaccineSchedule.id,
            newDate: newDate
        )
        
        print("✅ Vaccine rescheduled successfully for date: \(newDate)")
    }
    
    /// Mark a vaccine as administered in the database
    private func markVaccineAsAdministered(_ vaccine: VaccineSchedule) {
        Task {
            do {
                // Use SupabaseVaccineManager to mark vaccine as administered
                try await SupabaseVaccineManager.shared.markVaccineAsAdministered(
                    scheduleId: vaccine.id.uuidString,
                    administeredDate: Date()
                )
                
                print("✅ Vaccine marked as administered: \(vaccine.id)")
                
                // Reload vaccinations to update the UI
                await MainActor.run {
                    self.loadVaccinations()
                }
                
                // Show confirmation to the user
                await MainActor.run {
                    let confirmationAlert = UIAlertController(
                        title: "Success",
                        message: "The vaccine has been marked as administered.",
                        preferredStyle: .alert
                    )
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(confirmationAlert, animated: true)
                }
            } catch {
                print("❌ Error marking vaccine as administered: \(error)")
                
                // Show error alert
                await MainActor.run {
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to mark the vaccine as administered. Please try again.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
    
    /// Shows a toast message with feedback
    private func showToast(message: String) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 16
        toastContainer.clipsToBounds = true
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        // Set constraints
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12),
            
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        
        // Animate in
        toastContainer.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            toastContainer.alpha = 1
        }, completion: { _ in
            // Animate out after delay
            UIView.animate(withDuration: 0.2, delay: 2.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    private func  startAutoScrollTimer() {
        // Cancel any existing timer
        stopAutoScrollTimer()
        
        // Only start timer if we have more than one item
        if todaysBitesData.count > 1 {
            autoScrollTimer = Timer.scheduledTimer(timeInterval: autoScrollInterval,
                                                   target: self,
                                                   selector: #selector(scrollToNextCard),
                                                   userInfo: nil,
                                                   repeats: true)
        }
    }
    
    // Function to stop auto-scrolling timer
    private func stopAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    // Function to scroll to the next card
    @objc private func scrollToNextCard() {
        guard todaysBitesData.count > 1,
              let visibleItems = todaysBitesCollectionView.indexPathsForVisibleItems.first else {
            return
        }
        
        // Calculate the next index
        let nextIndex = (visibleItems.item + 1) % todaysBitesData.count
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        
        // Scroll to the next item with animation
        todaysBitesCollectionView.scrollToItem(at: nextIndexPath,
                                               at: .centeredHorizontally,
                                               animated: true)
        
        // Update page control
        pageControl.currentPage = nextIndex
    }
    
    // Pause scrolling when user touches the collection view
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == todaysBitesCollectionView {
            stopAutoScrollTimer()
        }
    }
    
    // Resume scrolling when user stops interacting with the collection view
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == todaysBitesCollectionView {
            startAutoScrollTimer()
        }
    }
}



// MARK: - UICollection View

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Update page control
        pageControl.numberOfPages = todaysBitesData.count
        pageControl.isHidden = todaysBitesData.count <= 1
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
        return CGSize(width: collectionView.frame.width - 32, height: 220)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == todaysBitesCollectionView {
            // Calculate cell width and spacing
            let cellWidth = self.view.frame.width - 32
            let spacing = CGFloat(32) // Match the minimumLineSpacing
            
            // Calculate the total width of a cell including spacing
            let cardWidthWithSpacing = cellWidth + spacing
            
            // Determine the target offset by dividing the current offset by the cell+spacing width
            let targetIndex = round(targetContentOffset.pointee.x / cardWidthWithSpacing)
            
            // Calculate the new x offset that will center the target cell
            let newTargetX = targetIndex * cardWidthWithSpacing
            
            // Set the new target offset to snap to
            targetContentOffset.pointee.x = newTargetX
            
            // Update page control
            pageControl.currentPage = Int(targetIndex)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == todaysBitesCollectionView {
            // Use the same calculation as in scrollViewWillEndDragging
            let cellWidth = self.view.frame.width - 32
            let spacing = CGFloat(32)
            let cardWidthWithSpacing = cellWidth + spacing
            let page = Int(round(scrollView.contentOffset.x / cardWidthWithSpacing))
            pageControl.currentPage = page
        }
    }
}
