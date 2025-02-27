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
    var customBitesDict: [String: [FeedingMeal]] = [:]  // ✅ Custom bites storage
    

    
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
        
        // ✅ Setup UI Components
        setupCollectionView()
        setupUI()
        setupTableView()

        // ✅ Enable Drag & Drop for TableView
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(FeedingPlanCell.self, forCellReuseIdentifier: "FeedingPlanCell")

        // ✅ Add Back Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )

        let weekDays = getWeekDaysWithDates()

        print("📌 Weekdays: \(weekDays)")
        print("📌 Weekly Plan: \(weeklyPlan)")

        // ✅ Auto-select first date with a weekly plan
        if let firstPlannedDay = weekDays.first(where: { weeklyPlan[$0] != nil }) {
            selectedDay = firstPlannedDay
            selectedDateIndex = weekDays.firstIndex(of: firstPlannedDay) ?? 0
        } else {
            selectedDay = weekDays.first ?? ""
            selectedDateIndex = 0
        }

        // ✅ Reload CollectionView & TableView after setup
        DispatchQueue.main.async {
            self.collectionView.reloadData() // Fix layout issues
            self.tableView.reloadData()
        }
    }


    private func getWeekDaysWithDates() -> [String] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today) - 1  // Get current weekday (0 = Sunday)

        var weekDaysWithDates: [String] = []

        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i - weekday, to: today) {
                let formatter = DateFormatter()
                formatter.dateFormat = "E d MMM" // Example: "Mon 12 Feb"
                weekDaysWithDates.append(formatter.string(from: dayDate))
            }
        }

        return weekDaysWithDates
    }
    
    func didSelectDate(_ date: String) {
        print("📌 Selected Day: \(date)")

        // ✅ Update selected day
        selectedDay = date

        // ✅ Reload tableView to show correct meals for selected date
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
        collectionView.backgroundColor = .clear // ✅ Match background

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

        // ✅ StackView now contains both segmentedControl and collectionView (initially hidden)
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

        // ✅ Initially hide collectionView (only show for Weekly Plan)
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
        collectionView.isHidden = selectedPlanType == .daily // ✅ Show only for Weekly Plan

        if selectedPlanType == .weekly {
            print("📌 Switching to Weekly Plan")

            let weekDays = getWeekDaysWithDates()
            for day in weekDays {
                if weeklyPlan[day] == nil {
                    weeklyPlan[day] = [:]  // ✅ Ensure every day has an empty dictionary
                }
            }

            if weeklyPlan[selectedDay] == nil || weeklyPlan[selectedDay]?.isEmpty == true {
                weeklyPlan[selectedDay] = myBowlItemsDict
                print("✅ Weekly Plan Updated: \(weeklyPlan)")
            }
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.tableView.reloadData()
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

        // ✅ Save History in UserDefaults
        var mealHistory = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] ?? [:]

        var encodedMeals: [[String: String]] = []

        for (category, meals) in summaryVC.savedPlan {
            for meal in meals {
                var mealDict: [String: String] = [
                    "category": category.rawValue,
                    "time": getTimeInterval(for: category),
                    "image": meal.image
                ]
                encodedMeals.append(mealDict)
            }
        }

        // ✅ Save Today's Bites
        mealHistory[selectedDay] = encodedMeals
        UserDefaults.standard.set(mealHistory, forKey: "mealPlanHistory")
        UserDefaults.standard.set(encodedMeals, forKey: "todaysBites")
        
        // ✅ Store Selected Date
        let todayDateString = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
        UserDefaults.standard.set(todayDateString, forKey: "selectedDay")

        // ✅ Notify HomeViewController
        NotificationCenter.default.post(name: NSNotification.Name("FeedingPlanUpdated"), object: nil)

        print("✅ Feeding Plan Saved! Meals Count: \(encodedMeals.count)")

        // ✅ Push to Summary Screen (Then Return to Home)
        navigationController?.pushViewController(summaryVC, animated: true)
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
}

extension FeedingPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = fixedBiteOrder[indexPath.section]  // ✅ Get category

            // ✅ Check if valid index before deleting
            if selectedPlanType == .daily {
                guard let meals = myBowlItemsDict[category], indexPath.row < meals.count else {
                    print("⚠️ Error: Attempted to delete invalid index in Daily Plan")
                    return
                }
                myBowlItemsDict[category]?.remove(at: indexPath.row)
                
                // ✅ Remove empty categories after deletion
                if myBowlItemsDict[category]?.isEmpty == true {
                    myBowlItemsDict.removeValue(forKey: category)
                }
            } else {
                guard let meals = weeklyPlan[selectedDay]?[category], indexPath.row < meals.count else {
                    print("⚠️ Error: Attempted to delete invalid index in Weekly Plan")
                    return
                }
                weeklyPlan[selectedDay]?[category]?.remove(at: indexPath.row)

                // ✅ Remove empty categories after deletion
                if weeklyPlan[selectedDay]?[category]?.isEmpty == true {
                    weeklyPlan[selectedDay]?.removeValue(forKey: category)
                }
            }

            // ✅ Reload table safely after deletion
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        let predefinedCount = fixedBiteOrder.count
        let customBitesCount = customBitesDict.keys.count  // ✅ Include Custom Bites
        return predefinedCount + customBitesCount  // ✅ Total sections: Predefined + Custom
    }




    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let predefinedCount = fixedBiteOrder.count

        if section < predefinedCount {
            return fixedBiteOrder[section].rawValue  // ✅ Standard Bites
        } else {
            let customIndex = section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            return customCategory  // ✅ Show Custom Bite Name
        }
    }










    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let predefinedCount = fixedBiteOrder.count

        if section < predefinedCount {
            // ✅ Standard Bites (EarlyBite, SnackBite, etc.)
            let category = fixedBiteOrder[section]
            return selectedPlanType == .daily ? myBowlItemsDict[category]?.count ?? 0 : weeklyPlan[selectedDay]?[category]?.count ?? 0
        } else {
            // ✅ Custom Bites
            let customIndex = section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            return customBitesDict[customCategory]?.count ?? 0
        }
    }










    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingPlanCell", for: indexPath) as? FeedingPlanCell else {
            fatalError("❌ Error: Could not dequeue FeedingPlanCell. Check if the identifier is correctly set.")
        }

        let predefinedCount = fixedBiteOrder.count
        let meal: FeedingMeal?

        if indexPath.section < predefinedCount {
            // ✅ Standard Bites
            let category = fixedBiteOrder[indexPath.section]
            meal = selectedPlanType == .daily ? myBowlItemsDict[category]?[indexPath.row] : weeklyPlan[selectedDay]?[category]?[indexPath.row]
        } else {
            // ✅ Custom Bites
            let customIndex = indexPath.section - predefinedCount
            let customCategory = Array(customBitesDict.keys)[customIndex]
            meal = customBitesDict[customCategory]?[indexPath.row]
        }

        // ✅ Handle Empty Meals
        if meal == nil {
            cell.textLabel?.text = "No meals added"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
            cell.textLabel?.textColor = .gray
            cell.imageView?.image = nil
            return cell
        }

        // ✅ Remove existing subviews (to prevent duplication)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // ✅ Create a Horizontal StackView to align Image & Label
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 10
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Create ImageView
        let mealImageView = UIImageView()
        mealImageView.contentMode = .scaleAspectFill
        mealImageView.clipsToBounds = true
        mealImageView.layer.cornerRadius = 8
        mealImageView.translatesAutoresizingMaskIntoConstraints = false

        if let imageUrl = meal?.image {
            mealImageView.image = UIImage(named: imageUrl)
        } else {
            mealImageView.image = UIImage(named: "placeholder")  // Default placeholder
        }

        // ✅ Set Image Size Constraints
        NSLayoutConstraint.activate([
            mealImageView.widthAnchor.constraint(equalToConstant: 30),
            mealImageView.heightAnchor.constraint(equalToConstant: 30)
        ])

        // ✅ Create Label for Meal Name
        let mealLabel = UILabel()
        mealLabel.text = meal?.name ?? "No Meal"
        mealLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mealLabel.textColor = .black
        mealLabel.numberOfLines = 1
        mealLabel.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Add Image & Label to StackView
        contentStackView.addArrangedSubview(mealImageView)
        contentStackView.addArrangedSubview(mealLabel)

        // ✅ Add StackView to Cell
        cell.contentView.addSubview(contentStackView)

        // ✅ Apply Constraints
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            contentStackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            contentStackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5)
        ])

        return cell
    }
    
    
    
    
    
    
    
    
    
    
    
    




    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black  // ✅ Ensure proper visibility

        let intervalLabel = UILabel()
        intervalLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        intervalLabel.textColor = .gray

        let predefinedBitesCount = fixedBiteOrder.count

        if section < predefinedBitesCount {
            // ✅ Standard predefined bite types
            let category = fixedBiteOrder[section]
            titleLabel.text = category.rawValue.prefix(1).capitalized + category.rawValue.dropFirst()
            intervalLabel.text = getTimeInterval(for: category)
        } else {
            // ✅ Custom Bites Handling
            let customIndex = section - predefinedBitesCount
            let customBites = Array(customBitesDict.keys)

            // ✅ Prevent out-of-bounds crash
            guard customIndex < customBites.count else { return nil }

            let customCategory = customBites[customIndex]
            titleLabel.text = customCategory  // ✅ Display custom bite name

            // ✅ Retrieve the custom time interval if available
            intervalLabel.text = customBiteTimes[BiteType.custom(customCategory)] ?? "Custom Time"
        }

        // ✅ Add labels to headerView
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
        return true  // ✅ Allow moving meals across categories
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let fromCategory = fixedBiteOrder[fromIndexPath.section]
        let toCategory = fixedBiteOrder[toIndexPath.section]

        guard var fromMeals = myBowlItemsDict[fromCategory] else { return }

        let movedMeal = fromMeals.remove(at: fromIndexPath.row)

        // ✅ Remove meal from source category
        myBowlItemsDict[fromCategory] = fromMeals.isEmpty ? nil : fromMeals

        // ✅ Add meal to destination category
        if myBowlItemsDict[toCategory] == nil {
            myBowlItemsDict[toCategory] = []
        }
        myBowlItemsDict[toCategory]?.insert(movedMeal, at: toIndexPath.row)

        tableView.reloadData()
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

        // ✅ Determine if the date is selected
        let isSelected = indexPath.item == selectedDateIndex

        // ✅ Check if the date has a weekly plan
        let hasPlan = weeklyPlan[currentDate] != nil && !(weeklyPlan[currentDate]?.isEmpty ?? true)

        // ✅ Configure the cell with all required parameters
        cell.configure(with: currentDate, isSelected: isSelected, hasPlan: hasPlan)

        // ✅ Debugging - Print which dates have a weekly plan
        print("📌 Checking Date: \(currentDate), Has Weekly Plan: \(hasPlan)")

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
            self.collectionView.reloadData()  // ✅ Highlight selected date
            self.tableView.reloadData()  // ✅ Show meals for the selected date
        }
    }





}
extension FeedingPlanViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let category = fixedBiteOrder[indexPath.section]
        guard let meal = myBowlItemsDict[category]?[indexPath.row] else { return [] }
        
        let itemProvider = NSItemProvider(object: meal.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = (meal, category)  // ✅ Store both meal and its category
        return [dragItem]
    }
}


extension FeedingPlanViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        let destinationCategory = fixedBiteOrder[destinationIndexPath.section]  // ✅ Get category where dropped

        if let dragItem = coordinator.items.first,
           let (sourceMeal, sourceCategory) = dragItem.dragItem.localObject as? (FeedingMeal, BiteType) {

            tableView.performBatchUpdates({
                // ✅ Remove from old category
                if let index = myBowlItemsDict[sourceCategory]?.firstIndex(where: { $0.name == sourceMeal.name }) {
                    myBowlItemsDict[sourceCategory]?.remove(at: index)
                    if myBowlItemsDict[sourceCategory]?.isEmpty == true {
                        myBowlItemsDict.removeValue(forKey: sourceCategory)
                    }
                }

                // ✅ Add to new category
                if myBowlItemsDict[destinationCategory] == nil {
                    myBowlItemsDict[destinationCategory] = []
                }
                myBowlItemsDict[destinationCategory]?.insert(sourceMeal, at: destinationIndexPath.row)

                tableView.reloadData()
            })
        }
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

extension FeedingMeal {
    func toDictionary() -> [String: String] {
        return [
            "name": name,
            "description": description,
            "image": image,
            "category": category.rawValue // Convert enum to string
        ]
    }
}
