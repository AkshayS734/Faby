import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    private let storageManager = SupabaseVaccineManager.shared
    var scheduledVaccines: [[String: String]] = []
    private var administeredVaccines: [[String: String]] = []
    var vaccineView: UIView?
    var baby = BabyDataModel.shared.babyList[0]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
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
        return view
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
        print("🚀 HomeViewController viewDidLoad")
        view.backgroundColor = .systemGray6
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle"),
            style: .plain,
            target: self,
            action: #selector(goToSettings)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpecialMoments), name: .milestonesAchievedUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewVaccineScheduled), name: NSNotification.Name("NewVaccineScheduled"), object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTodaysBites),
            name: NSNotification.Name("FeedingPlanUpdated"),
            object: nil
        )
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 220, height: 160)
        layout.minimumLineSpacing = 15
        
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
        loadVaccinations() // Initial load of vaccinations
        updateNameLabel()
        updateDateLabel()
        updateTodaysBites()
        embedSpecialMomentsViewController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🚀 HomeViewController viewWillAppear")
        loadVaccinations() // Reload vaccinations when view appears
        updateSpecialMoments()
        updateTodaysBites()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsContainerView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        
        // Add the vaccination container view
        contentView.addSubview(upcomingVaccinationLabel)
        contentView.addSubview(vaccineContainerView)
        
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
            
            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            specialMomentsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            specialMomentsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            specialMomentsContainerView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 10),
            specialMomentsContainerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialMomentsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            specialMomentsContainerView.heightAnchor.constraint(equalToConstant: 225),
            
            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor, constant: 24),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 225),
            
            // Add constraints for the vaccination container
            upcomingVaccinationLabel.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 24),
            upcomingVaccinationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            vaccineContainerView.topAnchor.constraint(equalTo: upcomingVaccinationLabel.bottomAnchor, constant: 10),
            vaccineContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineContainerView.heightAnchor.constraint(equalToConstant: 160),
            vaccineContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
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
        
        // Convert dictionary vaccines to VaccineSchedule objects and keep vaccine names
        let vaccineSchedulesWithNames: [(VaccineSchedule, String)] = scheduledVaccines.compactMap { dict in
            guard let vaccineName = dict["type"],
                  let dateString = dict["date"],
                  let hospital = dict["hospital"] else {
                return nil
            }
            
            // Create a date from the string
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            guard let date = dateFormatter.date(from: dateString) else {
                print("❌ Could not parse date: \(dateString)")
                return nil
            }
            
            let schedule = VaccineSchedule(
                id: UUID(),
                babyID: BabyDataModel.shared.babyList[0].babyID,
                vaccineId: UUID(), // This is not used for display
                hospital: hospital,
                date: date,
                location: dict["address"] ?? "",
                isAdministered: false
            )
            return (schedule, vaccineName)
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
            
            // Create the vaccine cards view with the callback
            let vaccineCardsView = UIHostingController(rootView: VaccineCardsView(
                vaccines: vaccineSchedulesWithNames,
                onVaccineCompleted: { [weak self] tuple in
                    let (vaccine, _) = tuple
                    print("📱 Vaccine completion requested for: \(vaccine.vaccineId)")
                    Task {
                        do {
                            // Get all scheduled records for this baby
                            let schedules = try await VaccineScheduleManager.shared.fetchSchedules(forBaby: BabyDataModel.shared.babyList[0].babyID)
                            print("✅ Successfully fetched \(schedules.count) scheduled vaccination records")
                            // Find and delete the matching schedule
                            for record in schedules {
                                if record.id == vaccine.id {
                                    try await VaccineScheduleManager.shared.updateSchedule(
                                        recordId: record.id,
                                        newDate: record.date,
                                        newHospital: Hospital(
                                            id: UUID(),
                                            babyId: record.babyID,
                                            name: record.hospital,
                                            address: record.location,
                                            distance: 0.0
                                        )
                                    )
                                    print("✅ Deleted original scheduled record with ID: \(record.id)")
                                    // Create administered record
                                    let administered = VaccineAdministered(
                                        id: UUID(),
                                        babyId: record.babyID,
                                        vaccineId: record.vaccineId,
                                        scheduleId: record.id,
                                        administeredDate: Date()
                                    )
                                    try await AdministeredVaccineManager.shared.addAdministeredVaccine(
                                        babyId: administered.babyId,
                                        vaccineId: administered.vaccineId,
                                        scheduleId: administered.scheduleId,
                                        date: administered.administeredDate,
                                        location: record.location
                                    )
                                    print("✅ Saved administered vaccine record")
                                    // Reload vaccinations
                                    await MainActor.run {
                                        self?.loadVaccinations()
                                    }
                                    break
                                }
                            }
                        } catch {
                            print("❌ Error completing vaccine: \(error)")
                        }
                    }
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
    
    private func updateNameLabel() {
        nameLabel.text = baby.name
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func loadVaccinations() {
        print("📋 Loading vaccinations...")
        print("🌐 Fetching all vaccination records from Supabase...")
        Task {
            do {
                // Fetch all scheduled vaccines from Supabase (no baby filter)
                let allScheduledRecords = try await VaccineScheduleManager.shared.fetchAllSchedules()
                print("✅ Successfully fetched \(allScheduledRecords.count) scheduled vaccination records (all babies)")
                
                // Fetch administered vaccines for all babies (optional, can be filtered if needed)
                let allAdministeredRecords = try await AdministeredVaccineManager.shared.fetchAllAdministeredVaccines()
                print("✅ Successfully fetched \(allAdministeredRecords.count) administered vaccination records (all babies)")
                
                // Convert scheduled records to dictionaries
                var scheduledDictionaries: [[String: String]] = []
                for record in allScheduledRecords {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let vaccineName = await getVaccineName(for: record.vaccineId)
                    let dict: [String: String] = [
                        "type": vaccineName,
                        "date": dateFormatter.string(from: record.date),
                        "hospital": record.hospital,
                        "location": record.location
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
                        "type": vaccineName,
                        "date": dateFormatter.string(from: record.administeredDate),
                        "hospital": "Unknown Hospital",
                        "location": "Unknown Location"
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
                }
            } catch {
                print("❌ Failed to load vaccination records from Supabase: \(error.localizedDescription)")
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
    
    @objc private func updateTodaysBites() {
        print("✅ Fetching Today's Bites from UserDefaults...")
        
        guard let savedMeals = UserDefaults.standard.array(forKey: "todaysBites") as? [[String: String]],
              let savedDate = UserDefaults.standard.string(forKey: "selectedDay") else {
            print("⚠️ No saved meals found!")
            return
        }
        print("📌 Saved Meals: \(savedMeals)")
        print("📌 Saved Date: \(savedDate)")
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
    
    @objc private func addMealPlanTapped() {
        openTodBiteViewController()
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


struct VaccineCardsView: View {
    let vaccines: [(VaccineSchedule, String)]
    var onVaccineCompleted: ((VaccineSchedule, String)) -> Void
    
    var body: some View {
        VStack {
            if vaccines.isEmpty {
                HStack {
                    Image(systemName: "syringe")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text("No upcoming vaccinations")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(height: 100)
                .background(Color(UIColor(hex: "#f2f2f7")))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(Array(vaccines.enumerated()), id: \.element.0.id) { index, tuple in
                            let (vaccine, vaccineName) = tuple
                            VaccineCard(
                                vaccine: vaccine,
                                vaccineName: vaccineName,
                                onComplete: {
                                    print("📱 Vaccine card tapped for completion: \(vaccine.vaccineId)")
                                    onVaccineCompleted(tuple)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
                .frame(height: 120)
            }
        }
        .frame(height: 160)
        .background(Color(UIColor(hex: "#f2f2f7")))
    }
}

struct VaccineCard: View {
    let vaccine: VaccineSchedule
    let vaccineName: String
    let onComplete: () -> Void
    @State private var isCompleted = false
    @State private var opacity = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Vaccine Name and Completion Button
            HStack {
                Text(vaccineName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isCompleted = true
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.3) {
                        onComplete()
                    }
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : Color(.systemGray3))
                        .font(.system(size: 22))
                }
                .disabled(isCompleted)
            }
            // Date and Hospital Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 14))
                    Text(formatDate(vaccine.date))
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                HStack(spacing: 6) {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 14))
                    Text(vaccine.hospital)
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(16)
        .frame(width: 260, height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4, x: 0, y: 2)
        .opacity(opacity)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// UIViewRepresentable to ensure exact match with UIKit's UIFont.boldSystemFont
struct UILabelRepresentable: UIViewRepresentable {
    var text: String
    var font: UIFont
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.font = font
    }
}
