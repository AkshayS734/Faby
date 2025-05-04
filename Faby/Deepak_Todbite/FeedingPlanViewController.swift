import UIKit

enum PlanType {
    case daily
    case weekly
}
// ✅ Define a fixed order for BiteType
let fixedBiteOrder: [BiteType] = [.EarlyBite, .NourishBite, .MidDayBite, .SnackBite, .NightBite]



class FeedingPlanViewController: UIViewController {
    
    // MARK: - UI Elements
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Daily Plan", "Weekly Plan"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var collectionView: UICollectionView!
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

        setupCollectionView()
        setupUI()
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


    private func getWeekDaysWithDates() -> [String] {
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today) - 1

            var weekDaysWithDates: [String] = []

            for i in 0..<7 {
                if let dayDate = calendar.date(byAdding: .day, value: i - weekday, to: today) {
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

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 60) // ✅ Increased for better UI
        ])
    }


    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Feeding Plan"
        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(savePlanTapped))

    
        let stackView = UIStackView(arrangedSubviews: [segmentedControl, collectionView])
        stackView.axis = .vertical
        stackView.spacing = 8

        view.addSubview(stackView)
        view.addSubview(tableView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

       
        collectionView.isHidden = true
    }



    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeedingPlanCell")
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        selectedPlanType = segmentedControl.selectedSegmentIndex == 0 ? .daily : .weekly
        
        if selectedPlanType == .weekly {
            print("📌 Switching to Weekly Plan")
            
            // Show date range picker
            showDateRangePicker()
        } else {
            // Daily plan selected
            collectionView.isHidden = true
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

        for (category, meals) in summaryVC.savedPlan {
            for meal in meals {
                var mealDict: [String: String] = [
                    "category": category.rawValue,
                    "time": getTimeInterval(for: category),
                    "name": meal.name,
                    "image": meal.image,
                    "description": meal.description,
                    "region": meal.region.rawValue,
                    "ageGroup": meal.ageGroup.rawValue
                ]
                encodedMeals.append(mealDict)
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
            self.segmentedControl.selectedSegmentIndex = 0
            self.selectedPlanType = .daily
            self.collectionView.isHidden = true
        })
        
        // Add continue button
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            self.generateWeeklyDates()
            self.collectionView.isHidden = false
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




    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let predefinedCount = fixedBiteOrder.count

        if section < predefinedCount {
            return fixedBiteOrder[section].rawValue
        } else {
            let customIndex = section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            return customCategory
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingPlanCell", for: indexPath) as? FeedingPlanCell else {
            fatalError("❌ Error: Could not dequeue FeedingPlanCell. Check if the identifier is correctly set.")
        }

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
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 10
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        let mealImageView = UIImageView()
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.clipsToBounds = true
        mealImageView.layer.cornerRadius = 8
        mealImageView.translatesAutoresizingMaskIntoConstraints = false

        let imageUrl = meal.image
        if !imageUrl.isEmpty {
            mealImageView.image = UIImage(named: imageUrl)
        } else {
            mealImageView.image = UIImage(named: "placeholder")
        }

        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 30),
            mealImageView.heightAnchor.constraint(equalToConstant: 30)
        ])

        let mealLabel = UILabel()
        mealLabel.text = meal.name
        mealLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mealLabel.textColor = .black
        mealLabel.numberOfLines = 1
        mealLabel.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.addArrangedSubview(mealImageView)
        contentStackView.addArrangedSubview(mealLabel)

        cell.contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            contentStackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            contentStackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5)
        ])

        return cell
    }
    
    // Helper method to configure placeholder cell
    private func configurePlaceholderCell(_ cell: FeedingPlanCell) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = "No items added in the plan"
        placeholderLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        placeholderLabel.textColor = .gray
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            placeholderLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            placeholderLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        // Disable selection for placeholder cells
        cell.selectionStyle = .none
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black

        let intervalLabel = UILabel()
        intervalLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        intervalLabel.textColor = .gray

        let predefinedBitesCount = fixedBiteOrder.count

        if section < predefinedBitesCount {
            
            let category = fixedBiteOrder[section]
            titleLabel.text = category.rawValue.prefix(1).capitalized + category.rawValue.dropFirst()
            intervalLabel.text = getTimeInterval(for: category)
        } else {
            let customIndex = section - predefinedBitesCount
            let customBites = Array(customBitesDict.keys)

            //  Prevent out-of-bounds crash
            guard customIndex < customBites.count else { return nil }

            let customCategory = customBites[customIndex]
            titleLabel.text = customCategory

           
            intervalLabel.text = customBiteTimes[BiteType.custom(customCategory)] ?? "Custom Time"
        }

        // Add labels to headerView
        headerView.addSubview(titleLabel)
        headerView.addSubview(intervalLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),

            intervalLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            intervalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            intervalLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])

        return headerView
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
            "image": image,
            "category": category.rawValue
        ]
    }
}
