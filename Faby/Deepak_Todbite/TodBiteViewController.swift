
import UIKit
class TodBiteViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - UI Components
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var collectionView: UICollectionView!
    var tableView: UITableView!
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "No items added to MyBowl yet."
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    // MARK: - Properties
    var selectedCategory: BiteType? = nil
    var selectedRegion: RegionType? = nil
    var selectedAgeGroup: AgeGroup = .months12to18
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // Items for MyBowl grouped by category
    var myBowlItemsDict: [BiteType: [FeedingMeal]] = [:]
    var customBitesDict: [String: [FeedingMeal]] = [:]
    private var customBiteTimes: [BiteType: String] = [:]
    var filteredMeals: [BiteType: [FeedingMeal]] = [:]
    var isSearching: Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }
   
    private var lastAppliedRegion: RegionType?
    private var lastAppliedAgeGroup: AgeGroup?




    

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupSearchBar()
        setupPlaceholderLabel()
        loadDefaultContent()
    }
    private let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Meals..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false

        //  Filter Button
        let filterButton = UIButton(type: .system)
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterButton.tintColor = .systemBlue
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(openFilterOptions), for: .touchUpInside)
        
        let filterBarButton = UIBarButtonItem(customView: filterButton)

       
        let historyButton = UIButton(type: .system)
        historyButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        historyButton.tintColor = .systemBlue
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.addTarget(self, action: #selector(openFeedingPlanHistory), for: .touchUpInside)
        
        let historyBarButton = UIBarButtonItem(customView: historyButton)

        //  Set Both Buttons in the Navigation Bar
        navigationItem.rightBarButtonItems = [filterBarButton, historyBarButton]
    }

    // Function to Open Filter View
   

    //  Function to Open Feeding Plan History
    @objc private func openFeedingPlanHistory() {
        let historyVC = FeedingPlanHistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }


    @objc private func openFilterOptions() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }

    
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    

    // MARK: - UI Setup
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: "TodBiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodBiteTableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    private func setupPlaceholderLabel() {
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func loadDefaultContent() {
        collectionView.isHidden = false
        tableView.isHidden = true
        collectionView.reloadData()
    }
    @objc private func createCustomBiteTapped() {
        let customBiteVC = CreateCustomBiteViewController()

        customBiteVC.onSave = { [weak self] newMeal, timeInterval in
            guard let self = self else { return }

            print("✅ New custom meal added: \(newMeal.name) with time: \(timeInterval)")

            // Ensure the category exists
            if self.myBowlItemsDict[newMeal.category] == nil {
                self.myBowlItemsDict[newMeal.category] = []
            }
            self.myBowlItemsDict[newMeal.category]?.append(newMeal)

            //  Store Time Interval for Custom Bites
            self.customBiteTimes[newMeal.category] = timeInterval

            self.updateMyBowlUI()
        }
        
        navigationController?.pushViewController(customBiteVC, animated: true)
    }







    private func updateMyBowlUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updatePlaceholderVisibility()
        }
    }


    // MARK: - Actions
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Recommended Meal
            collectionView.isHidden = false
            tableView.isHidden = true
            placeholderLabel.isHidden = true


            setupSearchBar()

        case 1: // MyBowl
            collectionView.isHidden = true
            updatePlaceholderVisibility()
            tableView.reloadData()

            var barButtonItems: [UIBarButtonItem] = []

            // ✅ Add "+" button for adding custom bites
            let addButton = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(createCustomBiteTapped)
            )
            addButton.tintColor = .systemBlue
            barButtonItems.append(addButton)

            // ✅ Add Calendar Button for opening Feeding Plan
            let calendarButton = UIBarButtonItem(
                image: UIImage(systemName: "calendar"),
                style: .plain,
                target: self,
                action: #selector(openFeedingPlan)
            )
            calendarButton.tintColor = .systemBlue
            barButtonItems.append(calendarButton)

            // ✅ Add Feeding Plan History Button (🔄 Fix: Restores on switching back)
            let historyButton = UIBarButtonItem(
                image: UIImage(systemName: "clock.arrow.circlepath"),
                
                style: .plain,
                target: self,
                action: #selector(openFeedingPlanHistory)
            )
            historyButton.tintColor = .systemBlue
            barButtonItems.append(historyButton)

            // ✅ Set all buttons
            navigationItem.rightBarButtonItems = barButtonItems

        default:
            break
        }
    }

@objc private func openFeedingPlan() {
        let feedingPlanVC = FeedingPlanViewController()

        // Passing Predefined Meals
        feedingPlanVC.myBowlItemsDict = myBowlItemsDict

        //  Extracting Custom Bites from MyBowl
        var extractedCustomBites: [String: [FeedingMeal]] = [:]
        for (key, meals) in myBowlItemsDict {
            if case let .custom(name) = key {
                extractedCustomBites[name] = meals  // ✅ Save Custom Bite Meals
            }
        }
        feedingPlanVC.customBitesDict = extractedCustomBites  // ✅ Now Passing Correctly

        //  Pass Custom Bite Times
        feedingPlanVC.customBiteTimes = customBiteTimes

     
        print("✅ Opening Feeding Plan")
        print("📌 Extracted Custom Bites: \(extractedCustomBites)")
        print("📌 Custom Bite Times: \(customBiteTimes)")

        navigationController?.pushViewController(feedingPlanVC, animated: true)
    }
//    @objc private func openFeedingPlanHistory() {
//        let historyVC = FeedingPlanHistoryViewController()
//        navigationController?.pushViewController(historyVC, animated: true)
//    }








    private func updatePlaceholderVisibility() {
        let isMyBowlEmpty = myBowlItemsDict.isEmpty
        placeholderLabel.isHidden = !isMyBowlEmpty
        tableView.isHidden = isMyBowlEmpty

        //  Always set navigation bar buttons in the correct order
        var barButtonItems: [UIBarButtonItem] = []

        //  Add "+" button (should always be there)
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createCustomBiteTapped)
        )
        addButton.tintColor = .systemBlue
        barButtonItems.append(addButton)

        //  Add Calendar Button (should always be there)
        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(openFeedingPlan)
        )
        calendarButton.tintColor = .systemBlue
        barButtonItems.append(calendarButton)

        //  Always set both buttons in the correct order
        navigationItem.rightBarButtonItems = barButtonItems
    }
    private func updateFilteredMeals() {
        print("🔄 Updating Meals for Region: \(selectedRegion?.rawValue ?? "Default"), Age: \(selectedAgeGroup.rawValue)")

        filteredMeals.removeAll()
        

        for category in BiteType.predefinedCases {
            let meals = BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup)
            filteredMeals[category] = meals
        }

        collectionView.reloadData()
    }


    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard segmentedControl.selectedSegmentIndex == 1 else { return nil }
        

        let headerView = UIView()
        headerView.backgroundColor = .white
        

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.text = Array(myBowlItemsDict.keys)[section].rawValue
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let intervalLabel = UILabel()
        intervalLabel.font = UIFont.systemFont(ofSize: 14)
        intervalLabel.textColor = .darkGray
        intervalLabel.text = getTimeInterval(for: Array(myBowlItemsDict.keys)[section])
        
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(intervalLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),

            intervalLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            intervalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            intervalLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }



    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(215)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(0)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            return section
        }
    }
    func MealItemDetails(message: String) {
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.text = message
            toastLabel.font = UIFont.systemFont(ofSize: 14)
            toastLabel.textColor = .white
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            toastLabel.textAlignment = .center
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true
            toastLabel.translatesAutoresizingMaskIntoConstraints = false

            guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            keyWindow.addSubview(toastLabel)

            NSLayoutConstraint.activate([
                toastLabel.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                toastLabel.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 16),
                toastLabel.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: -16),
                toastLabel.heightAnchor.constraint(equalToConstant: 40)
            ])

            UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
    private func getTimeInterval(for category: BiteType) -> String {
        switch category {
        case .EarlyBite: return "7:30 AM - 8:00 AM"
        case .NourishBite: return "10:00 AM - 10:30 AM"
        case .MidDayBite: return "12:30 PM - 1:00 PM"
        case .SnackBite: return "4:00 PM - 4:30 PM"
        case .NightBite: return "8:00 PM - 8:30 PM"
        case .custom(let name): return customBiteTimes[category] ?? "Custom Time"
        }
    }




    private func moveItem(_ item: FeedingMeal, from oldCategory: BiteType, to newCategory: BiteType, at indexPath: IndexPath) {
       
        
        myBowlItemsDict[oldCategory]?.remove(at: indexPath.row)
        if myBowlItemsDict[oldCategory]?.isEmpty == true {
            myBowlItemsDict.removeValue(forKey: oldCategory)
        }

       
        
        if myBowlItemsDict[newCategory] == nil {
            myBowlItemsDict[newCategory] = []
        }
        myBowlItemsDict[newCategory]?.append(item)

        MealItemDetails(message: "\(item.name) moved to \(newCategory.rawValue)!")
        tableView.reloadData()
    }

    private func showCategorySelection(for item: FeedingMeal, from currentCategory: BiteType, at indexPath: IndexPath) {
        let categorySelection = UIAlertController(title: "Move to Section", message: "Select a new section for \(item.name)", preferredStyle: .actionSheet)

        for category in BiteType.predefinedCases where category != currentCategory {
            categorySelection.addAction(UIAlertAction(title: category.rawValue, style: .default, handler: { _ in
                self.moveItem(item, from: currentCategory, to: category, at: indexPath)
            }))
        }

        categorySelection.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(categorySelection, animated: true, completion: nil)
    }



    private func handleMoreOptions(for item: FeedingMeal, in category: BiteType, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Manage Item", message: "Choose an action for \(item.name)", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.myBowlItemsDict[category]?.remove(at: indexPath.row)
            if self.myBowlItemsDict[category]?.isEmpty == true {
                self.myBowlItemsDict.removeValue(forKey: category)
            }
            self.updatePlaceholderVisibility()
            self.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "Add to Favorites", style: .default, handler: { _ in
            self.MealItemDetails(message: "\(item.name) added to favorites!")
        }))

        alert.addAction(UIAlertAction(title: "Add to Other Bites", style: .default, handler: { _ in
            self.showCategorySelection(for: item, from: category, at: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    func addItemToMyBowl(item: FeedingMeal) {
        if myBowlItemsDict[.SnackBite] == nil {
            myBowlItemsDict[.SnackBite] = []
        }
        myBowlItemsDict[.SnackBite]?.append(item)
        updatePlaceholderVisibility()
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension TodBiteViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard segmentedControl.selectedSegmentIndex == 0 else { return 0 }
        return BiteType.predefinedCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard segmentedControl.selectedSegmentIndex == 0 else { return 0 }
        
        let category = BiteType.predefinedCases[section]
        
      
        
        if isSearching {
            return filteredMeals[category]?.count ?? 0
        }
        
       
        
        let meals = BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup)
        print("🔄 Displaying \(meals.count) meals for \(category.rawValue) in \(selectedRegion ?? .east) & Age: \(selectedAgeGroup)")
        
        return meals.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TodBiteCollectionViewCell else {
            return UICollectionViewCell()
        }

        let category = BiteType.predefinedCases[indexPath.section]
        
       
        
        let items: [FeedingMeal]
        
        if isSearching {
            items = filteredMeals[category] ?? []
        } else {
            items = !filteredMeals.isEmpty ? (filteredMeals[category] ?? []) :
                     BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup)
        }

        let item = items[indexPath.row]

        print("🍽️ Displaying Meal: \(item.name) - Category: \(category.rawValue) - Region: \(selectedRegion ?? .east) - Age: \(selectedAgeGroup)")

        let isAdded = myBowlItemsDict[category]?.contains(where: { $0.name == item.name }) ?? false

        cell.configure(with: item, category: category, isAdded: isAdded)
        cell.delegate = self
        return cell
    }



    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        ) as? HeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        let sectionName = BiteType.predefinedCases[indexPath.section].rawValue
       let timeIntervals = [
            "7:30 AM - 8:00 AM",
            "10:00 AM - 10:30 AM",
            "12:30 PM - 1:00 PM",
            "3:30 PM - 4:00 PM",
            "6:30 PM - 7:00 PM"
        ]

        let intervalText = indexPath.section < timeIntervals.count ? timeIntervals[indexPath.section] : "Other"

   
        headerView.configure(with: sectionName, interval: intervalText)
        return headerView
    }
}

// MARK: - UICollectionViewDelegate
extension TodBiteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = BiteType.predefinedCases[indexPath.section]
        let items = BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup)
        let selectedItem = items[indexPath.row]

        let detailVC = MealDetailViewController()
        detailVC.selectedItem = selectedItem
        detailVC.sectionItems = items

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TodBiteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return segmentedControl.selectedSegmentIndex == 1 ? myBowlItemsDict.keys.count : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard segmentedControl.selectedSegmentIndex == 1 else { return 0 }
        let category = Array(myBowlItemsDict.keys)[section]
        return myBowlItemsDict[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard segmentedControl.selectedSegmentIndex == 1 else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TodBiteTableViewCell
        let category = Array(myBowlItemsDict.keys)[indexPath.section]
        let item = myBowlItemsDict[category]?[indexPath.row]
        cell.configure(with: item!)

        
        cell.moreOptionsButton.tag = indexPath.row
        cell.moreOptionsButton.addTarget(self, action: #selector(moreOptionsTapped(_:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard segmentedControl.selectedSegmentIndex == 1 else { return nil }

        let category = Array(myBowlItemsDict.keys)[section]
        let interval = getTimeInterval(for: category)
        
        return "\(category.rawValue)\n\(interval)"
    }



    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = Array(myBowlItemsDict.keys)[indexPath.section]
            myBowlItemsDict[category]?.remove(at: indexPath.row)
            if myBowlItemsDict[category]?.isEmpty == true {
                myBowlItemsDict.removeValue(forKey: category)
            }
            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    }

    @objc private func moreOptionsTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TodBiteTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }

        let category = Array(myBowlItemsDict.keys)[indexPath.section]
        let item = myBowlItemsDict[category]?[indexPath.row]
        handleMoreOptions(for: item!, in: category, at: indexPath)
    }
}

// MARK: - TodBiteCollectionViewCellDelegate
extension TodBiteViewController: TodBiteCollectionViewCellDelegate {
    func didTapAddButton(for item: FeedingMeal, in category: BiteType) {
    
        if myBowlItemsDict[category]?.contains(where: { $0.name == item.name }) == true {
           
            MealItemDetails(message: "\"\(item.name)\" is already in MyBowl!")
        } else {
            
            
            if myBowlItemsDict[category] == nil {
                myBowlItemsDict[category] = []
            }
            myBowlItemsDict[category]?.append(item)
            MealItemDetails(message: "\"\(item.name)\" added to MyBowl!")

        
            if let indexPath = indexPathForItem(item, in: category) {
                collectionView.reloadItems(at: [indexPath])
            }
        }

        // Update the UI
        if segmentedControl.selectedSegmentIndex == 1 {
            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    }

    private func indexPathForItem(_ item: FeedingMeal, in category: BiteType) -> IndexPath? {
        guard let section = BiteType.predefinedCases.firstIndex(of: category),
              let row = BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup).firstIndex(where: { $0.name == item.name }) else {
            return nil
        }
        return IndexPath(row: row, section: section)
    }
}
extension TodBiteViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredMeals.removeAll()
            collectionView.reloadData()
            return
        }

        filteredMeals.removeAll()

        for category in BiteType.predefinedCases {
            
            filteredMeals[category] = BiteSampleData.shared.getItems(for: category, in: selectedRegion ?? .east, for: selectedAgeGroup)
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        collectionView.reloadData()
    }
}
extension TodBiteViewController: FilterViewControllerDelegate {
    func didApplyFilters(region: RegionType, ageGroup: AgeGroup) {
        print("\n✅ Filters Applied - Region: \(region), Age Group: \(ageGroup)")

        self.selectedRegion = region
        self.selectedAgeGroup = ageGroup


        
        filteredMeals = [:]
        for category in BiteType.predefinedCases {
            let meals = BiteSampleData.shared.getItems(for: category, in: region, for: ageGroup)
            filteredMeals[category] = meals
            
           
            
            print("🔄 Category: \(category.rawValue) - Meals Count: \(meals.count)")
            for meal in meals {
                print("🍽️ Meal: \(meal.name) - Age: \(meal.ageGroup.rawValue) - Region: \(meal.region.rawValue)")
            }
        }

        collectionView.reloadData()
    }
}




