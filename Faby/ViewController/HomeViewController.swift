import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    private let storageManager = VaccinationStorageManager.shared
    var scheduledVaccines: [[String: String]] = []
    private var completedVaccinesStorage: [[String: String]] = []
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
        
        setupUI()
        setupDelegates()
        loadVaccinations()
        updateNameLabel()
        updateDateLabel()
        updateTodaysBites()
        embedSpecialMomentsViewController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVaccinations()
        updateSpecialMoments()
        
        // Always update Today's Bites when returning to this view
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
        vaccineView?.removeFromSuperview()
        
        if let oldVaccineViewController = children.first(where: { $0 is UIHostingController<VaccineCardsView> }) {
            oldVaccineViewController.willMove(toParent: nil)
            oldVaccineViewController.view.removeFromSuperview()
            oldVaccineViewController.removeFromParent()
        }
        
        let vaccineCardsView = UIHostingController(rootView: VaccineCardsView(
            vaccines: scheduledVaccines,
            onVaccineCompleted: { [weak self] vaccine in
                guard let self = self else { return }
                
                if let index = self.scheduledVaccines.firstIndex(where: { $0 == vaccine }) {
                    self.scheduledVaccines.remove(at: index)
                    self.completedVaccinesStorage.append(vaccine)
                    
                    if let scheduleToRemove = self.storageManager.getAllSchedules().first(where: {
                        $0.type == vaccine["type"] &&
                        $0.scheduledDate == vaccine["date"] &&
                        $0.hospitalName == vaccine["hospital"]
                    }) {
                        self.storageManager.deleteSchedule(id: scheduleToRemove.id)
                    }
                    
                    DispatchQueue.main.async {
                        self.loadVaccinations()
                    }
                }
            }
        )
        )
        
        addChild(vaccineCardsView)
        vaccineCardsView.view.translatesAutoresizingMaskIntoConstraints = false
        vaccineCardsView.view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        if let index = contentView.subviews.firstIndex(of: todaysBitesCollectionView) {
            contentView.insertSubview(vaccineCardsView.view, at: index + 1)
        } else {
            contentView.addSubview(vaccineCardsView.view)
        }
        
        vaccineCardsView.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            vaccineCardsView.view.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 20),
            vaccineCardsView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineCardsView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineCardsView.view.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        if let lastConstraint = contentView.constraints.first(where: { $0.firstAttribute == .bottom }) {
            lastConstraint.isActive = false
        }
        
        contentView.bottomAnchor.constraint(equalTo: vaccineCardsView.view.bottomAnchor, constant: 20).isActive = true
        
        vaccineView = vaccineCardsView.view
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
        let schedules = storageManager.getAllSchedules()
        self.scheduledVaccines = schedules.map { schedule in
            [
                "type": schedule.type,
                "date": schedule.scheduledDate,
                "hospital": schedule.hospitalName
            ]
        }
        
        DispatchQueue.main.async {
            self.setupVaccineView()
        }
    }
    @objc private func openTodBiteViewController() {
        // Create a new view controller to show all of today's bites
        let todaysBitesListVC = TodaysBitesListViewController()
        
        // Pass the current meal data to the list view controller
        todaysBitesListVC.meals = todaysBitesData
        
        // Push the view controller onto the navigation stack
        navigationController?.pushViewController(todaysBitesListVC, animated: true)
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
            
            if let title = meal["category"], let time = meal["time"] {
                updatedBites.append(TodayBite(title: title, time: time, imageName: imageKey))
            }
        }
        
        // Sort bites by predefined mealtime order
        let predefinedOrder: [String] = ["EarlyBite", "NourishBite", "MidDayBite", "SnackBite", "NightBite"]
        updatedBites.sort { (a, b) -> Bool in
            let indexA = predefinedOrder.firstIndex(of: a.title) ?? predefinedOrder.count
            let indexB = predefinedOrder.firstIndex(of: b.title) ?? predefinedOrder.count
            return indexA < indexB
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
        loadVaccinations()
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
    var vaccines: [[String: String]]
    var onVaccineCompleted: ([String: String]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            UILabelRepresentable(text: "Vaccine Reminder", font: UIFont.boldSystemFont(ofSize: 20))
                .frame(height: 24)
                .padding(.horizontal, 16)
            
            if vaccines.isEmpty {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Text("No vaccines added yet")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.systemGray))
                            .frame(width: geometry.size.width, alignment: .center)
                        Spacer()
                    }
                }
                .frame(height: 100)
                .background(Color(UIColor(hex: "#f2f2f7")))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vaccines, id: \.self) { vaccine in
                            VaccineCard(
                                vaccine: vaccine,
                                onComplete: {
                                    onVaccineCompleted(vaccine)
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


struct VaccineCard: View {
    var vaccine: [String: String]
    var onComplete: () -> Void
    @State private var isCompleted = false
    @State private var opacity = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Type and Completion Button
            HStack {
                Text(vaccine["type"] ?? "Unknown Vaccine")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isCompleted = true
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                    Text(vaccine["date"] ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 14))
                    Text(vaccine["hospital"] ?? "Unknown Hospital")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(16)
        .frame(width: 260, height: 120)
        .background(Color(.systemBackground)) // This keeps the cards white
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4, x: 0, y: 2)
        .opacity(opacity)
    }
}
// Make Dictionary conform to Hashable
extension Dictionary: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
}
