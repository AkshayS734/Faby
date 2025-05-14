import UIKit

enum PlanType {
    case daily
    case weekly
}
// ✅ Define a fixed order for BiteType
let fixedBiteOrder: [BiteType] = [.EarlyBite, .NourishBite, .MidDayBite, .SnackBite, .NightBite]



class FeedingPlanViewController: UIViewController {
    
    // MARK: - UI Elements
    // New UI elements - Two separate buttons
    private let dailyPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Daily Plan", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(planButtonTapped(_:)), for: .touchUpInside)
        button.tag = 0 // Tag for Daily Plan
        return button
    }()
    
    private let weeklyPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Weekly Plan", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(planButtonTapped(_:)), for: .touchUpInside)
        button.tag = 1 // Tag for Weekly Plan
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var collectionView: UICollectionView!
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    private var selectedDateIndex: Int = 0 // Stores selected date index
    private var weekDates: [String] = [] // Stores formatted dates

    
    // MARK: - Data
    var myBowlItemsDict: [BiteType: [FeedingMeal]] = [:]
  
    private var selectedPlanType: PlanType = .daily
    var customBiteTimes: [BiteType: String] = [:]
     
    private var selectedDay: String = "Monday"
    var weeklyPlan: [String: [BiteType: [FeedingMeal]]] = [:]
    var customBitesDict: [String: [FeedingMeal]] = [:]
    
    // Add new properties to store date range
    private var startDate: Date = Date()
    private var endDate: Date = Calendar.current.date(byAdding: .day, value: 6, to: Date())!
    

    
    private func setupWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) - 1

        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i - weekday, to: today) {
                let formatter = DateFormatter()
                formatter.dateFormat = "E d MMM" // Example: "Sun 9 Feb"
                weekDates.append(formatter.string(from: dayDate))
            }
        }
        selectedDay = weekDates[selectedDateIndex]
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create all UI components first
        setupCollectionView()
        setupUI()  // This will arrange all components with proper constraints
        setupTableView()

        tableView.register(FeedingPlanCell.self, forCellReuseIdentifier: "FeedingPlanCell")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        let weekDays = getWeekDaysWithDates()
        
        print("📌 Weekdays: \(weekDays)")
        print("📌 Weekly Plan: \(weeklyPlan)")

        //  Auto-select TODAY's Date
        let todayDate = getFormattedDate(Date()) // Get today's date in "E d MMM" format

        if let todayIndex = weekDays.firstIndex(of: todayDate) {
            selectedDay = todayDate
            selectedDateIndex = todayIndex
        } else {
            selectedDay = weekDays.first ?? ""
            selectedDateIndex = 0
        }

        // Load existing feeding plans for the current date range
        loadExistingFeedingPlans()
       
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.selectedDateIndex < self.collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: self.selectedDateIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
        }
    }

    // Method to load existing feeding plans from Supabase
    private func loadExistingFeedingPlans() {
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Get date range (use past 7 days as default)
        let today = Date()
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        Task {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let supabaseClient = sceneDelegate.supabase
                
                // Load feeding plans with meal details
                let loadedPlans = await SupabaseManager.loadFeedingPlansWithMeals(
                    startDate: oneWeekAgo,
                    endDate: today,
                    using: supabaseClient
                )
                
                await MainActor.run {
                    print("📌 Loaded feeding plans for \(loadedPlans.count) days from Supabase")
                    
                    // Merge loaded plans with weeklyPlan 
                    if !loadedPlans.isEmpty {
                        // Merge with any existing plans
                        for (dateKey, mealsByCategory) in loadedPlans {
                            if weeklyPlan[dateKey] == nil {
                                weeklyPlan[dateKey] = mealsByCategory
                            } else {
                                // Merge categories
                                for (category, meals) in mealsByCategory {
                                    if weeklyPlan[dateKey]?[category] == nil {
                                        weeklyPlan[dateKey]?[category] = meals
                                    } else {
                                        // Append meals, avoiding duplicates by ID
                                        let existingIds = Set(weeklyPlan[dateKey]?[category]?.compactMap { $0.id } ?? [])
                                        let newMeals = meals.filter { !existingIds.contains($0.id ?? -1) }
                                        weeklyPlan[dateKey]?[category]?.append(contentsOf: newMeals)
                                    }
                                }
                            }
                        }
                        
                        // If we loaded plans for the selected day, use those for MyBowl
                        if let selectedDayPlans = loadedPlans[selectedDay] {
                            // Only replace myBowlItemsDict if it's empty or if we have data for the selected day
                            if myBowlItemsDict.isEmpty || !selectedDayPlans.isEmpty {
                                myBowlItemsDict = selectedDayPlans
                            }
                        }
                        
                        // Reload UI
                        collectionView.reloadData()
                        tableView.reloadData()
                    }
                    
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
        }
    }

    private func getWeekDaysWithDates() -> [String] {
        let calendar = Calendar.current
        let today = Date()
        
        var weekDaysWithDates: [String] = []
        
        // Start with today and get the next 6 days
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: today) {
                weekDaysWithDates.append(getFormattedDate(dayDate))
            }
        }
        
        return weekDaysWithDates
    }
    private func getFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        return formatter.string(from: date)
    }

    
    private func getFormattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        return formatter.string(from: Date())
    }

    func didSelectDate(_ date: String) {
        print("📌 Selected Day: \(date)")

      
        selectedDay = date

        
        tableView.reloadData()
    }


    
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // ✅ Auto adjust cell size

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear

        // Create height constraint for collection view (we'll activate it in setupUI)
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 60)
    }


    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Feeding Plan"
        view.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Light gray background to match TodBiteViewController

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePlanTapped))

        // Setup button stack view
        buttonStackView.addArrangedSubview(dailyPlanButton)
        buttonStackView.addArrangedSubview(weeklyPlanButton)
        
        // Add all UI elements to the view
        view.addSubview(buttonStackView)
        view.addSubview(collectionView)
        view.addSubview(tableView)

        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // First: Position button stack view
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Second: Position collection view BELOW buttons
            collectionView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionViewHeightConstraint,

            // Third: Position table view BELOW collection view 
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0), // Reduced spacing
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Initially hide collection view for daily plan and set height to 0
        collectionView.isHidden = true
        collectionViewHeightConstraint.constant = 0
    }



    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Light gray background to match TodBiteViewController
        
        // Adjust the appearance of section headers
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 60
        
        // Show empty cells in the UI
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
    }
    
    // MARK: - Actions
    @objc private func planButtonTapped(_ sender: UIButton) {
        // Update button appearances
        dailyPlanButton.backgroundColor = sender.tag == 0 ? .systemBlue : .lightGray
        dailyPlanButton.setTitleColor(sender.tag == 0 ? .white : .darkGray, for: .normal)
        
        weeklyPlanButton.backgroundColor = sender.tag == 1 ? .systemBlue : .lightGray
        weeklyPlanButton.setTitleColor(sender.tag == 1 ? .white : .darkGray, for: .normal)
        
        // Update selected plan type
        selectedPlanType = sender.tag == 0 ? .daily : .weekly
        
        if selectedPlanType == .weekly {
            print("📌 Switching to Weekly Plan")
            
            // Initialize weekly plan with current daily plan data
            if weeklyPlan.isEmpty {
                // Copy current daily plan to all days in the week
                let weekDays = getWeekDaysWithDates()
                for day in weekDays {
                    weeklyPlan[day] = myBowlItemsDict
                }
            }
            
            // Show collection view with animation
            UIView.animate(withDuration: 0.3) {
                self.collectionView.isHidden = false
                self.collectionViewHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            }
            
            // Show date range picker
            showDateRangePicker()
        } else {
            // Daily plan selected - hide collection view with animation
            UIView.animate(withDuration: 0.3) {
                self.collectionView.isHidden = true
                self.collectionViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            tableView.reloadData()
        }
    }


    @objc private func dayChanged(to index: Int) {
        selectedDateIndex = index
        selectedDay = weekDates[index]

        if weeklyPlan[selectedDay] == nil {
            weeklyPlan[selectedDay] = myBowlItemsDict
        }

        print("📌 Selected Day: \(selectedDay)")
        collectionView.reloadData()
        tableView.reloadData()
    }






    @objc private func savePlanTapped() {
        print("✅ Saving Feeding Plan for \(selectedDay)")

        let summaryVC = FeedingPlanSummaryViewController()
        summaryVC.selectedDay = selectedDay
        summaryVC.savedPlan = selectedPlanType == .daily ? myBowlItemsDict : weeklyPlan[selectedDay] ?? [:]

        var mealHistory = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] ?? [:]

        var encodedMeals: [[String: String]] = []

        // Collect all meals to save to Supabase
        var mealsToSave: [FeedingMeal] = []

        for (category, meals) in summaryVC.savedPlan {
            for meal in meals {
                var mealDict: [String: String] = [
                    "category": category.rawValue,
                    "time": getTimeInterval(for: category),
                    "name": meal.name,
                    "image": meal.image_url,
                    "description": meal.description,
                    "region": meal.region.rawValue,
                    "ageGroup": meal.ageGroup.rawValue
                ]
                encodedMeals.append(mealDict)
                
                // Add to meals to save to Supabase
                mealsToSave.append(meal)
            }
        }

        // Save to meal history
        mealHistory[selectedDay] = encodedMeals
        UserDefaults.standard.set(mealHistory, forKey: "mealPlanHistory")
        
        // Save for today's bites display on Home tab
        UserDefaults.standard.set(encodedMeals, forKey: "todaysBites")

        // Save the selected day
        let todayDateString = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
        UserDefaults.standard.set(todayDateString, forKey: "selectedDay")
        
        // Synchronize to make sure data is saved immediately
        UserDefaults.standard.synchronize()

        // Post notification for Home tab to update
        NotificationCenter.default.post(name: NSNotification.Name("FeedingPlanUpdated"), object: nil)

        print("✅ Stored Meals in UserDefaults:", encodedMeals)  // 🔍 Debugging print
        
        // Save to Supabase
        Task {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let supabaseClient = sceneDelegate.supabase
                
                // Determine plan type for Supabase
                let planTypeForDB: FeedingPlanType = (selectedPlanType == .daily) ? .daily : .weekly
                
                // Set date range
                let today = Date()
                let calendar = Calendar.current
                let endDate = selectedPlanType == .daily 
                    ? today // Same day for daily plan
                    : calendar.date(byAdding: .day, value: 7, to: today) ?? today // 7 days for weekly
                
                // Save to Supabase
                let success = await SupabaseManager.saveFeedingPlan(
                    meals: mealsToSave,
                    planType: planTypeForDB,
                    startDate: today,
                    endDate: endDate,
                    using: supabaseClient
                )
                
                if !success {
                    // If there was an error, show an error message
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to save feeding plan to database. Your plan is saved locally.")
                    }
                }
            }
        }

        // Show success message
        let alert = UIAlertController(
            title: "Plan Saved Successfully",
            message: "Your meal plan has been saved and will appear in Home tab",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "View Plan", style: .default) { _ in
            // Navigate to summary view
            self.navigationController?.pushViewController(summaryVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Go to Home", style: .default) { _ in
            // Navigate back to root then select Home tab
            self.navigateToHomeTab()
        })
        
        present(alert, animated: true)
    }

    // Helper function to show error alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Helper method to navigate to Home tab
    private func navigateToHomeTab() {
        // Navigate to root view controller first
        navigationController?.popToRootViewController(animated: false)
        
        // Post notification before switching tabs to ensure data is ready
        NotificationCenter.default.post(name: NSNotification.Name("FeedingPlanUpdated"), object: nil)
        
        // Select the Home tab (usually index 0)
        if let tabBarController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 1 // Home tab index
            
            // We can't directly call updateTodaysBites as it's private
            // Instead we rely on the notification we just posted
            // The HomeViewController should respond to it automatically
        }
    }







    
    private func getTimeInterval(for category: BiteType) -> String {
        switch category {
        case .EarlyBite: return "7:30 AM - 8:00 AM"
        case .NourishBite: return "10:00 AM - 10:30 AM"
        case .MidDayBite: return "12:30 PM - 1:00 PM"
        case .SnackBite: return "4:00 PM - 4:30 PM"
        case .NightBite: return "8:00 PM - 8:30 PM"
        case .custom(_): return customBiteTimes[category] ?? "**No Time Set**"
        }
    }

    // Add method to show date range picker
    private func showDateRangePicker() {
        let alert = UIAlertController(title: "Select Plan Duration", message: "Please select start and end dates for your plan", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Start Date"
            
            // Create date picker for start date
            let startDatePicker = UIDatePicker()
            startDatePicker.datePickerMode = .date
            startDatePicker.preferredDatePickerStyle = .wheels
            startDatePicker.date = self.startDate
            startDatePicker.addTarget(self, action: #selector(self.startDateChanged(_:)), for: .valueChanged)
            
            textField.inputView = startDatePicker
            
            // Create toolbar with done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePicker))
            toolbar.setItems([doneButton], animated: false)
            textField.inputAccessoryView = toolbar
            
            // Set initial text
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            textField.text = formatter.string(from: self.startDate)
        }
        
        alert.addTextField { textField in
            textField.placeholder = "End Date"
            
            // Create date picker for end date
            let endDatePicker = UIDatePicker()
            endDatePicker.datePickerMode = .date
            endDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.date = self.endDate
            endDatePicker.addTarget(self, action: #selector(self.endDateChanged(_:)), for: .valueChanged)
            
            textField.inputView = endDatePicker
            
            // Create toolbar with done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.donePicker))
            toolbar.setItems([doneButton], animated: false)
            textField.inputAccessoryView = toolbar
            
            // Set initial text
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            textField.text = formatter.string(from: self.endDate)
        }
        
        // Add cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // If canceled, revert to Daily Plan
            self.selectedPlanType = .daily
            self.dailyPlanButton.backgroundColor = .systemBlue
            self.dailyPlanButton.setTitleColor(.white, for: .normal)
            self.weeklyPlanButton.backgroundColor = .lightGray
            self.weeklyPlanButton.setTitleColor(.darkGray, for: .normal)
            
            // Hide collection view with animation
            UIView.animate(withDuration: 0.3) {
            self.collectionView.isHidden = true
                self.collectionViewHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        })
        
        // Add continue button
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            self.generateWeeklyDates()
            
            // Show collection view with animation
            UIView.animate(withDuration: 0.3) {
            self.collectionView.isHidden = false
                self.collectionViewHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            }
            
            self.collectionView.reloadData()
            self.tableView.reloadData()
        })
        
        present(alert, animated: true)
    }

    // Add method to handle start date change
    @objc private func startDateChanged(_ sender: UIDatePicker) {
        startDate = sender.date
        
        // Update text field
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let alertController = presentedViewController as? UIAlertController,
           let startTextField = alertController.textFields?[0] {
            startTextField.text = formatter.string(from: startDate)
        }
    }

    // Add method to handle end date change
    @objc private func endDateChanged(_ sender: UIDatePicker) {
        endDate = sender.date
        
        // Update text field
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let alertController = presentedViewController as? UIAlertController,
           let endTextField = alertController.textFields?[1] {
            endTextField.text = formatter.string(from: endDate)
        }
    }

    // Add method to dismiss date picker
    @objc private func donePicker() {
        view.endEditing(true)
    }

    // Update method to generate dates based on selected range
    private func generateWeeklyDates() {
        weekDates.removeAll()
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E d MMM" // Example: "Sun 9 Feb"
        
        // Get all dates between start and end date
        var currentDate = startDate
        while currentDate <= endDate {
            weekDates.append(dateFormatter.string(from: currentDate))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Set selected day to first day in range
        if !weekDates.isEmpty {
            selectedDay = weekDates[0]
            selectedDateIndex = 0
        }
    }
}

extension FeedingPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = fixedBiteOrder[indexPath.section]  // ✅ Get category

            //  Check if valid index before deleting
            if selectedPlanType == .daily {
                guard let meals = myBowlItemsDict[category], indexPath.row < meals.count else {
                    print("⚠️ Error: Attempted to delete invalid index in Daily Plan")
                    return
                }
                myBowlItemsDict[category]?.remove(at: indexPath.row)
                
                //  Remove empty categories after deletion
                if myBowlItemsDict[category]?.isEmpty == true {
                    myBowlItemsDict.removeValue(forKey: category)
                }
            } else {
                guard let meals = weeklyPlan[selectedDay]?[category], indexPath.row < meals.count else {
                    print("⚠️ Error: Attempted to delete invalid index in Weekly Plan")
                    return
                }
                weeklyPlan[selectedDay]?[category]?.remove(at: indexPath.row)

                // Remove empty categories after deletion
                if weeklyPlan[selectedDay]?[category]?.isEmpty == true {
                    weeklyPlan[selectedDay]?.removeValue(forKey: category)
                }
            }

            //  Reload table safely after deletion
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        let predefinedCount = fixedBiteOrder.count
        let customBitesCount = customBitesDict.keys.count
        return predefinedCount + customBitesCount
    }




    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Light gray background
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .darkGray
        
        // Get bite category and title
        let predefinedCount = fixedBiteOrder.count
        let biteTitle: String
        let biteTime: String
        
        if section < predefinedCount {
            let biteType = fixedBiteOrder[section]
            biteTitle = biteType.rawValue
            biteTime = getBiteTimeForDisplay(for: biteType) // Get the formatted time
        } else {
            let customIndex = section - predefinedCount
            let customBiteKey = Array(customBitesDict.keys)[customIndex]
            biteTitle = customBiteKey
            
            // Since FeedingMeal doesn't have a time property, use a default time for custom bites
            biteTime = "Flexible Time Slot"
        }
        
        titleLabel.text = biteTitle
        timeLabel.text = biteTime
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            
            timeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    // Helper method to format bite times for display
    private func getBiteTimeForDisplay(for biteType: BiteType) -> String {
        switch biteType {
        case .EarlyBite:
            return "7:30 AM - 8:00 AM"
        case .NourishBite:
            return "10:00 AM - 10:30 AM"
        case .MidDayBite:
            return "12:30 PM - 1:00 PM"
        case .SnackBite:
            return "4:00 PM - 4:30 PM"
        case .NightBite:
            return "8:00 PM - 8:30 PM"
        default:
            return "" // Handle any additional cases added to the enum
        }
    }










    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let predefinedCount = fixedBiteOrder.count

        if section < predefinedCount {
            // Standard Bites (EarlyBite, SnackBite, etc.)
            let category = fixedBiteOrder[section]
            let count = selectedPlanType == .daily ? myBowlItemsDict[category]?.count ?? 0 : weeklyPlan[selectedDay]?[category]?.count ?? 0
            // Return at least 1 row to show placeholder if no meals
            return count > 0 ? count : 1
        } else {
            // Custom Bites
            let customIndex = section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            let count = customBitesDict[customCategory]?.count ?? 0
            // Return at least 1 row to show placeholder if no meals
            return count > 0 ? count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingPlanCell", for: indexPath) as? FeedingPlanCell ?? FeedingPlanCell(style: .default, reuseIdentifier: "FeedingPlanCell")

        let predefinedCount = fixedBiteOrder.count
        let meals: [FeedingMeal]?
        let category: BiteType?

        if indexPath.section < predefinedCount {
            category = fixedBiteOrder[indexPath.section]
            meals = selectedPlanType == .daily ? myBowlItemsDict[category!] : weeklyPlan[selectedDay]?[category!]
        } else {
            let customIndex = indexPath.section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            category = BiteType.custom(customCategory)
            meals = customBitesDict[customCategory]
        }

        // Check if there are no meals for this category
        if meals == nil || meals!.isEmpty {
            // Create a placeholder cell
            configurePlaceholderCell(cell)
            return cell
        }

        // Normal cell configuration for meals
        let meal = meals![indexPath.row]
        
        cell.configure(with: meal)
        return cell
    }
    
    // Helper method to configure placeholder cell
    private func configurePlaceholderCell(_ cell: FeedingPlanCell) {
        // Create a clean placeholder cell with card styling
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "No items added in the plan"
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.textColor = .gray
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1.0) // Light gray background
        cell.selectionStyle = .none
        
        cardView.addSubview(placeholderLabel)
        cell.contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            placeholderLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Disable row moving since we removed drag and drop
        return false
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FeedingPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getWeekDaysWithDates().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.identifier, for: indexPath) as! DateCell
        let weekDaysWithDates = getWeekDaysWithDates()
        let currentDate = weekDaysWithDates[indexPath.item]

        // Check if the date is today
        let isToday = currentDate == getFormattedDate(Date())

        // Determine if the date is selected
        let isSelected = indexPath.item == selectedDateIndex

        // Check if the date has a weekly plan
        let hasPlan = weeklyPlan[currentDate] != nil && !(weeklyPlan[currentDate]?.isEmpty ?? true)

   
        cell.configure(with: currentDate, isSelected: isSelected || isToday, hasPlan: hasPlan)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let weekDaysWithDates = getWeekDaysWithDates()
        let selectedDate = weekDaysWithDates[indexPath.item]

        selectedDay = selectedDate
        selectedDateIndex = indexPath.item

        print("📌 Selected Day: \(selectedDay), Weekly Plan Exists: \(weeklyPlan[selectedDay] != nil)")

        if weeklyPlan[selectedDay] == nil {
            weeklyPlan[selectedDay] = myBowlItemsDict
        }

        didSelectDate(selectedDate)

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()

            
            let indexPath = IndexPath(item: self.selectedDateIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
}

extension FeedingMeal {
    func toDictionary() -> [String: String] {
        return [
            "name": name,
            "description": description,
            "image": image_url,
            "category": category.rawValue
        ]
    }
}
