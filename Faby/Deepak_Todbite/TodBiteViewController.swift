import UIKit
import Supabase

// Use the global fixedBiteOrder constant that's already defined in the project

class TodBiteViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, HeaderCollectionReusableViewDelegate {

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
    var selectedContinent: ContinentType = .asia
    var selectedCountry: CountryType = .india
    var selectedRegion: RegionType = .north
    var selectedAgeGroup: AgeGroup = .months12to15
    // Flag to track if initial data loading has completed
    private var initialDataLoadComplete = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Set up navigation buttons based on current segment selection
        if segmentedControl.selectedSegmentIndex == 0 {
            setupNavigationButtonsForRecommendedMeal()
            
            // If initial data load is not complete or filteredMeals is empty
            if !initialDataLoadComplete || filteredMeals.isEmpty {
                // Show loading indicator
                let activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.center = view.center
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)
                
                // Hide collection view until data is loaded
                collectionView.isHidden = true
                
                // Reload data
                Task {
                    await fetchAndPopulateMealData()
                    await MainActor.run {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        
                        if BiteSampleData.shared.categories.count > 0 {
                            applyDefaultFilters()
                            collectionView.isHidden = false
                            collectionView.reloadData()
                            print("✅ Data loaded and collection view reloaded")
                        } else {
                            print("⚠️ No data available after loading")
                        }
                    }
                }
            } else {
                // Data is already loaded, just make sure UI is correct
                collectionView.isHidden = false
                tableView.isHidden = true
                collectionView.reloadData()
                print("✅ Using cached data in viewWillAppear")
            }
        } else {
            // For My Bowl tab
            setupNavigationButtonsForMyBowl()
            updatePlaceholderVisibility()
        }
    }

    // Items for MyBowl grouped by category
    var myBowlItemsDict: [BiteType: [FeedingMeal]] = [:]
    var customBitesDict: [String: [FeedingMeal]] = [:]
    private var customBiteTimes: [BiteType: String] = [:]
    var filteredMeals: [BiteType: [FeedingMeal]] = [:]
    var isSearching: Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true)
    }
   
    private var lastAppliedContinent: ContinentType?
    private var lastAppliedCountry: CountryType?
    private var lastAppliedRegion: RegionType?
    private var lastAppliedAgeGroup: AgeGroup?




    

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupSearchBar()
        setupPlaceholderLabel()
        
        // Show loading indicator while data is being fetched
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Always hide collection view until data is loaded
        collectionView.isHidden = true
        
        // Set up correct navigation buttons for initial tab (index 0)
        setupNavigationButtonsForRecommendedMeal()
        
        // Load initial data and set up UI
        Task {
            // Use the PreloadedDataManager to ensure data is loaded
            await fetchAndPopulateMealData()
            
            // Then apply filters and update UI on main thread
            await MainActor.run {
                // Apply default filters only if data is available
                if BiteSampleData.shared.categories.count > 0 {
                    applyDefaultFilters()
                    
                    // Always show collection view after data is loaded
                    collectionView.isHidden = false
                    tableView.isHidden = true
                    
                    // Force reload of collection view
                    collectionView.reloadData()
                    print("✅ Collection view reloaded in viewDidLoad")
                }
                
        loadDefaultContent()
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            
            // Load saved My Bowl meals
            await loadSavedMyBowlMeals()
        }
    }
    
    // Load saved My Bowl meals from database
    private func loadSavedMyBowlMeals() async {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let savedMeals = await SupabaseManager.loadMyBowlMealsFromDatabase(using: sceneDelegate.supabase)
            
            // Add each meal to myBowlItemsDict
            for meal in savedMeals {
                if myBowlItemsDict[meal.category] == nil {
                    myBowlItemsDict[meal.category] = []
                }
                
                // Only add if not already in the list
                if !myBowlItemsDict[meal.category]!.contains(where: { $0.id == meal.id }) {
                    myBowlItemsDict[meal.category]?.append(meal)
                }
            }
            
            // Update UI on main thread
            await MainActor.run {
                print("✅ Loaded \(savedMeals.count) saved meals")
                updateMyBowlUI()
            }
        }
    }

    private let searchController = UISearchController(searchResultsController: nil)

    // Add this method to ensure the filter button is added after layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only add the filter button if we're on the first tab
        if segmentedControl.selectedSegmentIndex == 0 {
            // Add slight delay to ensure search bar is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateSearchBarWithFilterButton()
            }
        }
    }

    private func updateSearchBarWithFilterButton() {
        // Make sure the search text field exists
        guard let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField else {
            return
        }
        
        // Create filter button
        let filterButton = UIButton(type: .system)
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filterButton.tintColor = .systemBlue
        filterButton.addTarget(self, action: #selector(openFilterOptions), for: .touchUpInside)
        
        // Configure button size and appearance
        filterButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        filterButton.contentMode = .scaleAspectFit
        
        // Add the button to the search bar
        searchTextField.rightView = filterButton
        searchTextField.rightViewMode = .always
    }

    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Meals..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Create history button for navigation bar
        let historyButton = UIButton(type: .system)
        historyButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        historyButton.tintColor = .systemBlue
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.addTarget(self, action: #selector(openFeedingPlanHistory), for: .touchUpInside)
        
        let historyBarButton = UIBarButtonItem(customView: historyButton)

        // Set only history button in the navigation bar
        navigationItem.rightBarButtonItems = [historyBarButton]
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
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Light gray background to match screenshot
        tableView.separatorStyle = .none // Remove cell separators for a cleaner look
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
        // First load UI components
        if initialDataLoadComplete && BiteSampleData.shared.categories.count > 0 {
            // Only show collection view if we have data
        collectionView.isHidden = false
        } else {
            collectionView.isHidden = true
        }
        tableView.isHidden = true
        
        // Ensure the filter button is displayed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateSearchBarWithFilterButton()
        }
        
        print("✅ UI updated with data from Supabase, initialDataLoadComplete: \(initialDataLoadComplete)")
    }
    
    // New function to apply default filters automatically
    private func applyDefaultFilters() {
        print("\n✅ Applying Default Filters - Continent: \(selectedContinent.rawValue), Country: \(selectedCountry.rawValue), Region: \(selectedRegion.rawValue), Age Group: \(selectedAgeGroup.rawValue)")

        // Clear existing filtered meals
        filteredMeals = [:]
        
        // Only proceed if we have data
        if BiteSampleData.shared.categories.isEmpty {
            print("⚠️ No data available in BiteSampleData categories")
            // Force load data using PreloadedDataManager
            Task {
                await PreloadedDataManager.shared.ensureDataLoaded()
            await MainActor.run {
                    // Retry applying filters on main thread
                    self.applyDefaultFilters()
                }
            }
            return
        }
        
        // Track if we have any meals
        var totalMeals = 0
        
        for category in BiteType.predefinedCases {
            // Use PreloadedDataManager to get filtered meals
            let meals = PreloadedDataManager.shared.getFilteredMeals(
                for: category,
                in: selectedContinent,
                in: selectedCountry,
                in: selectedRegion,
                for: selectedAgeGroup
            )
            filteredMeals[category] = meals
            totalMeals += meals.count
            
            print("🔄 Category: \(category.rawValue) - Meals Count: \(meals.count)")
            for meal in meals {
                print("🍽️ Meal: \(meal.name) - Age: \(meal.ageGroup.rawValue) - Region: \(meal.region.rawValue)")
            }
        }
        
        print("✅ Total meals after filtering: \(totalMeals)")
        
        // Mark data loading as complete if we have any meals
        if totalMeals > 0 && !initialDataLoadComplete {
            initialDataLoadComplete = true
            print("✅ Setting initialDataLoadComplete = true")
        }

        // Always reload the collection view on the main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
            
            // Set up the correct navigation buttons for Recommended Meal tab
            setupNavigationButtonsForRecommendedMeal()
            
            // Check if data needs to be loaded
            if !initialDataLoadComplete || filteredMeals.isEmpty {
                // Show loading indicator
                let activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.center = view.center
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)
                
                // Hide collection view until data is loaded
                collectionView.isHidden = true
                
                // Reload data
                Task {
                    await fetchAndPopulateMealData()
                    await MainActor.run {
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        
                        if BiteSampleData.shared.categories.count > 0 {
                            applyDefaultFilters()
                            collectionView.isHidden = false
                            collectionView.reloadData()
                            print("✅ Data loaded from tab change and collection view reloaded")
                        } else {
                            print("⚠️ No data available after loading from tab change")
                        }
                    }
                }
            } else {
                // We already have data, just reload the collection view
                print("🔄 Reloading collection view with existing data in segmentedControlTapped")
                collectionView.reloadData()
            }

        case 1: // MyBowl
            collectionView.isHidden = true
            updatePlaceholderVisibility()
            tableView.reloadData()

            // Set up the correct navigation buttons for My Bowl tab
            setupNavigationButtonsForMyBowl()

        default:
            break
        }
    }

@objc private func openFeedingPlan() {
        // Check if MyBowl is empty
        if myBowlItemsDict.isEmpty {
            // Show message that MyBowl is empty and prevent navigation
            MealItemDetails(message: "No items in your bowl. Please add meals first.")
            return // Return early to prevent navigation
        }
        
        // If we have items, continue with normal flow
        let feedingPlanVC = FeedingPlanViewController()
        
        // Passing Predefined Meals
        feedingPlanVC.myBowlItemsDict = myBowlItemsDict

        // Extracting Custom Bites from MyBowl
        var extractedCustomBites: [String: [FeedingMeal]] = [:]
        for (key, meals) in myBowlItemsDict {
            if case let .custom(name) = key {
                extractedCustomBites[name] = meals  // ✅ Save Custom Bite Meals
            }
        }
        feedingPlanVC.customBitesDict = extractedCustomBites  // ✅ Now Passing Correctly

        // Pass Custom Bite Times
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
        if segmentedControl.selectedSegmentIndex == 1 {
            let isMyBowlEmpty = myBowlItemsDict.isEmpty
            placeholderLabel.isHidden = !isMyBowlEmpty
            tableView.isHidden = isMyBowlEmpty
            setupNavigationButtonsForMyBowl()
        } else {
            // Always hide the placeholder in Recommended Meal tab
            placeholderLabel.isHidden = true
        }
    }
    private func updateFilteredMeals() {
        print(" Updating Meals for Continent: \(selectedContinent.rawValue), Country: \(selectedCountry.rawValue), Region: \(selectedRegion.rawValue), Age: \(selectedAgeGroup.rawValue)")

        filteredMeals.removeAll()
        
        for category in BiteType.predefinedCases {
            // Get meals using the full filtering hierarchy
            let meals = BiteSampleData.shared.getItems(for: category, in: selectedContinent, in: selectedCountry, in: selectedRegion, for: selectedAgeGroup)
                filteredMeals[category] = meals
        }

        collectionView.reloadData()
    }


    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard segmentedControl.selectedSegmentIndex == 1 else { return nil }

        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Light background like in the screenshot

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold) // Cleaner font style from second image
        titleLabel.textColor = .black

        let intervalLabel = UILabel()
        intervalLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular) // Smaller, lighter font for time interval
        intervalLabel.textColor = .darkGray
        
        // Get the appropriate category based on search state
        let categories = getSortedCategories()
        let category: BiteType
        
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Filter to categories containing matching meals
            let filteredCategories = categories.filter { cat in
                return myBowlItemsDict[cat]?.contains(where: { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }) ?? false
            }
            
            guard section < filteredCategories.count else { return headerView }
            category = filteredCategories[section]
        } else {
            // Normal case
            guard section < categories.count else { return headerView }
            category = categories[section]
        }
        
        titleLabel.text = category.rawValue
        intervalLabel.text = getTimeInterval(for: category)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        intervalLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(intervalLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),

            intervalLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            intervalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            intervalLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12)
        ])

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70 // Increased height for the header to match screenshot
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Increased height for the card cells
    }



    private func createCompositionalLayout() -> UICollectionViewLayout {
        // Create a two-column layout with wider items
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.47), // Adjusted to allow for wider appearance
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Keep original padding
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 4)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.05), // Slightly wider than screen to allow bigger cards
            heightDimension: .absolute(230)
        )
        // Create group with exactly 2 items and consistent spacing
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(4)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 2)
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
        case .custom(_): 
            // Make sure to check if we have a time set for this category
            if let time = customBiteTimes[category], !time.isEmpty {
                return time
            } else {
                return "Flexible Time Slot"  // Default display when no time is set
            }
        }
    }




    private func moveItem(_ item: FeedingMeal, from oldCategory: BiteType, to newCategory: BiteType, at indexPath: IndexPath) {
        // Create a new copy of the item with the new category
        let updatedItem = FeedingMeal(from: item, withNewCategory: newCategory)
       
        // Remove from old category in local data
        myBowlItemsDict[oldCategory]?.remove(at: indexPath.row)
        if myBowlItemsDict[oldCategory]?.isEmpty == true {
            myBowlItemsDict.removeValue(forKey: oldCategory)
        }

        // Add to new category in local data
        if myBowlItemsDict[newCategory] == nil {
            myBowlItemsDict[newCategory] = []
        }
        myBowlItemsDict[newCategory]?.append(updatedItem)

        // Update UI
        MealItemDetails(message: "\(item.name) moved to \(newCategory.rawValue)!")
        tableView.reloadData()
        
        // Update in Supabase
        Task {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                await SupabaseManager.updateBiteTypeInMyBowlDatabase(meal: updatedItem, using: sceneDelegate.supabase)
            }
        }
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

    // Note: The old handleMoreOptions method was replaced with moreOptionsTapped method
    // which implements the same functionality with Supabase syncing

    func addItemToMyBowl(item: FeedingMeal) {
        if myBowlItemsDict[.SnackBite] == nil {
            myBowlItemsDict[.SnackBite] = []
        }
        myBowlItemsDict[.SnackBite]?.append(item)
        updatePlaceholderVisibility()
        tableView.reloadData()
    }

    // Add this method to implement the HeaderCollectionReusableViewDelegate
    func didTapSectionHeader(category: String) {
        // Find the corresponding BiteType
        guard let biteType = BiteType.predefinedCases.first(where: { $0.rawValue == category }) else {
            return
        }
        
        // Get all meals for this category
        let meals = BiteSampleData.shared.getItems(for: biteType, in: selectedRegion, for: selectedAgeGroup)
        
        // Use the existing MealDetailViewController to show the first meal in the category
        if let firstMeal = meals.first {
            let detailVC = MealDetailViewController()
            detailVC.title = category
            detailVC.selectedItem = firstMeal
            detailVC.sectionItems = meals
            
            // Navigate to the detail view controller
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // Show a message if no meals are found
            MealItemDetails(message: "No meals available in \(category)")
        }
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
        
        // If data hasn't loaded yet, try using PreloadedDataManager directly
        if !initialDataLoadComplete && BiteSampleData.shared.categories.isEmpty {
            print("⚠️ Data not fully loaded yet, attempting direct access through PreloadedDataManager")
            // Force reload on next cycle - this won't block the UI thread
            Task {
                await fetchAndPopulateMealData()
                await MainActor.run {
                    if !collectionView.isHidden {
                        collectionView.reloadData()
                    }
                }
            }
        }
        
        let category = BiteType.predefinedCases[section]
        
        if isSearching {
            return filteredMeals[category]?.count ?? 0
        }
        
        // If we have filtered meals, use them, otherwise get items from PreloadedDataManager
        if !filteredMeals.isEmpty {
            return filteredMeals[category]?.count ?? 0
        } else {
            let meals = PreloadedDataManager.shared.getFilteredMeals(
                for: category,
                in: selectedContinent,
                in: selectedCountry,
                in: selectedRegion,
                for: selectedAgeGroup
            )
            print("🔄 Displaying \(meals.count) meals for \(category.rawValue) in \(selectedRegion.rawValue) & Age: \(selectedAgeGroup.rawValue)")
        return meals.count
        }
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TodBiteCollectionViewCell else {
            return UICollectionViewCell()
        }

        let category = BiteType.predefinedCases[indexPath.section]
        
        let items: [FeedingMeal]
        
        if isSearching {
            items = filteredMeals[category] ?? []
        } else if !filteredMeals.isEmpty {
            items = filteredMeals[category] ?? []
        } else {
            // Use PreloadedDataManager to ensure data is available
            items = PreloadedDataManager.shared.getFilteredMeals(
                for: category,
                in: selectedContinent,
                in: selectedCountry,
                in: selectedRegion,
                for: selectedAgeGroup
            )
        }
        
        // Make sure we have items before trying to access them
        guard items.count > indexPath.row else {
            print("⚠️ Warning: Trying to access item at index \(indexPath.row) but only have \(items.count) items")
            return cell
        }

        let item = items[indexPath.row]

        print("🍽️ Displaying Meal: \(item.name) - Category: \(category.rawValue) - Region: \(item.region.rawValue) - Age: \(selectedAgeGroup.rawValue)")

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
        headerView.delegate = self
        return headerView
    }
}

// MARK: - UICollectionViewDelegate
extension TodBiteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the specific meal for the tapped card
        let category = BiteType.predefinedCases[indexPath.section]
        
        let items: [FeedingMeal]
        if isSearching {
            items = filteredMeals[category] ?? []
        } else if !filteredMeals.isEmpty {
            items = filteredMeals[category] ?? []
        } else {
            items = PreloadedDataManager.shared.getFilteredMeals(
                for: category,
                in: selectedContinent,
                in: selectedCountry,
                in: selectedRegion,
                for: selectedAgeGroup
            )
        }
        
        // Make sure we have items before trying to access them
        guard indexPath.row < items.count else {
            print("⚠️ Warning: Invalid index path when selecting item")
            return
        }
        
        let selectedItem = items[indexPath.row]
        
        // Navigate to detail view showing ONLY this specific meal (not the whole category)
        let detailVC = MealDetailViewController()
        detailVC.title = selectedItem.name  // Use meal name as title instead of category
        detailVC.selectedItem = selectedItem
        detailVC.sectionItems = [selectedItem]  // Only include this specific meal
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TodBiteViewController: UITableViewDataSource {
    // Helper method to get categories in a fixed order
    private func getSortedCategories() -> [BiteType] {
        var categories: [BiteType] = []
        
        // First add the fixed order categories if they exist in myBowlItemsDict
        for category in fixedBiteOrder {
            if myBowlItemsDict[category] != nil {
                categories.append(category)
            }
        }
        
        // Then add any custom categories that aren't in the fixed order
        for category in myBowlItemsDict.keys {
            if !fixedBiteOrder.contains(category) {
                categories.append(category)
            }
        }
        
        return categories
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard segmentedControl.selectedSegmentIndex == 1 else { return 0 }
        
        // If we're searching, we need to check which categories contain matching meals
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Only include sections that have meals matching the search text
            return getSortedCategories().filter { category in
                return myBowlItemsDict[category]?.contains(where: { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }) ?? false
            }.count
        }
        
        return myBowlItemsDict.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard segmentedControl.selectedSegmentIndex == 1 else { return 0 }
        
        let categories = getSortedCategories()
        
        // If we're searching, only show meals that match the search
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Filter categories to only those that contain matching meals
            let filteredCategories = categories.filter { category in
                return myBowlItemsDict[category]?.contains(where: { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }) ?? false
            }
            
            // Make sure we have enough categories for this section
            guard section < filteredCategories.count else { return 0 }
            
            let category = filteredCategories[section]
            // Filter meals within this category
            return myBowlItemsDict[category]?.filter { meal in
                return meal.name.lowercased().contains(searchText.lowercased())
            }.count ?? 0
        }
        
        // Normal (non-search) case
        guard section < categories.count else { return 0 }
        let category = categories[section]
        return myBowlItemsDict[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard segmentedControl.selectedSegmentIndex == 1 else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TodBiteTableViewCell
        
        // Get category and item based on whether we're searching
        let categories = getSortedCategories()
        let category: BiteType
        let item: FeedingMeal?
        
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            // Filter categories to only those that contain matching meals
            let filteredCategories = categories.filter { cat in
                return myBowlItemsDict[cat]?.contains(where: { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }) ?? false
            }
            
            guard indexPath.section < filteredCategories.count else { return cell }
            category = filteredCategories[indexPath.section]
            
            // Filter meals within this category
            let filteredMeals = myBowlItemsDict[category]?.filter { meal in
                return meal.name.lowercased().contains(searchText.lowercased())
            }
            
            guard indexPath.row < filteredMeals?.count ?? 0 else { return cell }
            item = filteredMeals?[indexPath.row]
        } else {
            // Normal (non-search) case
            guard indexPath.section < categories.count else { return cell }
            category = categories[indexPath.section]
            
            guard indexPath.row < myBowlItemsDict[category]?.count ?? 0 else { return cell }
            item = myBowlItemsDict[category]?[indexPath.row]
        }
        
        if let item = item {
            cell.configure(with: item)
            
            // Store section and row in the button's tag
            // We'll use a combined tag: section * 1000 + row to encode both values
            cell.moreOptionsButton.tag = (indexPath.section * 1000) + indexPath.row
            
            // Remove any existing targets to avoid duplicate actions
            cell.moreOptionsButton.removeTarget(nil, action: nil, for: .allEvents)
            
            // Add the target for touch up inside
            cell.moreOptionsButton.addTarget(self, action: #selector(moreOptionsTapped(_:)), for: .touchUpInside)
            
            // Make sure the button is enabled and user interaction is enabled
            cell.moreOptionsButton.isEnabled = true
            cell.moreOptionsButton.isUserInteractionEnabled = true
            cell.contentView.isUserInteractionEnabled = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard segmentedControl.selectedSegmentIndex == 1 else { return nil }

        let categories = getSortedCategories()
        
        // If we're searching, only show categories that contain matching meals
        if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let filteredCategories = categories.filter { category in
                return myBowlItemsDict[category]?.contains(where: { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }) ?? false
            }
            
            guard section < filteredCategories.count else { return nil }
            let category = filteredCategories[section]
        let interval = getTimeInterval(for: category)
        
        return "\(category.rawValue)\n\(interval)"
    }

        // Normal (non-search) case
        guard section < categories.count else { return nil }
        let category = categories[section]
        let interval = getTimeInterval(for: category)

        return "\(category.rawValue)\n\(interval)"
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the appropriate category and item based on search state
            let categories = Array(myBowlItemsDict.keys)
            let category: BiteType
            let item: FeedingMeal?
            
            if isSearching, let searchText = searchController.searchBar.text, !searchText.isEmpty {
                // Get filtered categories
                let filteredCategories = categories.filter { cat in
                    return myBowlItemsDict[cat]?.contains(where: { meal in
                        return meal.name.lowercased().contains(searchText.lowercased())
                    }) ?? false
                }
                
                guard indexPath.section < filteredCategories.count else { return }
                category = filteredCategories[indexPath.section]
                
                // Get filtered meals for this category
                let filteredMeals = myBowlItemsDict[category]?.filter { meal in
                    return meal.name.lowercased().contains(searchText.lowercased())
                }
                
                guard indexPath.row < filteredMeals?.count ?? 0 else { return }
                item = filteredMeals?[indexPath.row]
                
                // Find the original index of this item in the unfiltered array
                if let item = item, let originalIndex = myBowlItemsDict[category]?.firstIndex(where: { $0.id == item.id }) {
                    // Now delete from the original array
                    myBowlItemsDict[category]?.remove(at: originalIndex)
                }
            } else {
                // Normal (non-search) case
                guard indexPath.section < categories.count else { return }
                category = categories[indexPath.section]
                
                guard indexPath.row < myBowlItemsDict[category]?.count ?? 0 else { return }
                item = myBowlItemsDict[category]?[indexPath.row]
                
                // Remove directly
            myBowlItemsDict[category]?.remove(at: indexPath.row)
            }
            
            // Clean up empty categories
            if myBowlItemsDict[category]?.isEmpty == true {
                myBowlItemsDict.removeValue(forKey: category)
            }
            
            // Update UI
            updatePlaceholderVisibility()
            tableView.reloadData()
            
            // Delete from Supabase
            guard let mealId = item?.id else {
                MealItemDetails(message: "❌ Error: Cannot delete meal without ID")
                return
            }
            
            Task {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    await SupabaseManager.deleteFromMyBowlDatabase(mealId: mealId, using: sceneDelegate.supabase)
                    
                    DispatchQueue.main.async {
                        self.MealItemDetails(message: "✅ Deleted \"\(item?.name ?? "meal")\" from My Bowl")
                    }
                }
            }
        }
    }

    @objc private func moreOptionsTapped(_ sender: UIButton) {
        // Extract section and row from the tag
        let tag = sender.tag
        let section = tag / 1000
        let row = tag % 1000
        
        // Make sure we have valid categories
        let categories = getSortedCategories()
        guard section < categories.count else { return }
        
        let category = categories[section]
        guard let items = myBowlItemsDict[category], row < items.count else { return }
        let itemSafe = items[row] // Non-optional item
        
        // Create an action sheet with options
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add to Other Bites option (change bite type)
        actionSheet.addAction(UIAlertAction(title: "Add to Other Bites", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            // Create an IndexPath for the method calls that expect it
            let indexPath = IndexPath(row: row, section: section)
            self.showBiteTypeOptions(for: itemSafe, currentCategory: category, at: indexPath)
        }))
        
        // Delete option
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            // Create an IndexPath for the method calls that expect it
            let indexPath = IndexPath(row: row, section: section)
            self.deleteItem(itemSafe, from: category, at: indexPath)
        }))
        
        // Cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true)
    }
    
    private func deleteItem(_ item: FeedingMeal, from category: BiteType, at indexPath: IndexPath) {
        // Remove from local data
        myBowlItemsDict[category]?.remove(at: indexPath.row)
        if myBowlItemsDict[category]?.isEmpty == true {
            myBowlItemsDict.removeValue(forKey: category)
        }
        
        // Update UI
        updatePlaceholderVisibility()
        tableView.reloadData()
        
        // Delete from Supabase
        guard let mealId = item.id else {
            MealItemDetails(message: "❌ Error: Cannot delete meal without ID")
            return
        }
        
        Task {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                await SupabaseManager.deleteFromMyBowlDatabase(mealId: mealId, using: sceneDelegate.supabase)
                
                DispatchQueue.main.async {
                    self.MealItemDetails(message: "✅ Deleted \"\(item.name)\" from My Bowl")
                }
            }
        }
    }
    
    private func showBiteTypeOptions(for item: FeedingMeal, currentCategory: BiteType, at indexPath: IndexPath) {
        // Create an alert controller to select a new bite type
        let alertController = UIAlertController(title: "Select Bite Type", message: nil, preferredStyle: .actionSheet)
        
        // Add all bite types as options except the current one
        for biteType in BiteType.predefinedCases where biteType != currentCategory {
            alertController.addAction(UIAlertAction(title: biteType.rawValue, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.moveItemToBiteType(item, from: currentCategory, to: biteType, at: indexPath)
            })
        }
        
        // Add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert controller
        present(alertController, animated: true)
    }
    
    private func moveItemToBiteType(_ item: FeedingMeal, from oldCategory: BiteType, to newCategory: BiteType, at indexPath: IndexPath) {
        // Create a new copy of the item with the new category
        let updatedItem = FeedingMeal(from: item, withNewCategory: newCategory)
        
        // Remove from old category
        myBowlItemsDict[oldCategory]?.remove(at: indexPath.row)
        if myBowlItemsDict[oldCategory]?.isEmpty == true {
            myBowlItemsDict.removeValue(forKey: oldCategory)
        }
        
        // Add to new category
        if myBowlItemsDict[newCategory] == nil {
            myBowlItemsDict[newCategory] = []
        }
        myBowlItemsDict[newCategory]?.append(updatedItem)
        
        // Update UI
        updatePlaceholderVisibility()
        tableView.reloadData()
        
        // Update in Supabase
        Task {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                await SupabaseManager.updateBiteTypeInMyBowlDatabase(meal: updatedItem, using: sceneDelegate.supabase)
                
                DispatchQueue.main.async {
                    self.MealItemDetails(message: "✅ Moved \"\(item.name)\" to \(newCategory.rawValue)")
                }
            }
        }
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

            // Save to Supabase my_Bowl table
            Task {
                // Get client from SceneDelegate
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    await SupabaseManager.saveToMyBowlDatabase(item, using: sceneDelegate.supabase)
                }
            }
        
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
              let row = BiteSampleData.shared.getItems(for: category, in: selectedContinent, in: selectedCountry, in: selectedRegion, for: selectedAgeGroup).firstIndex(where: { $0.name == item.name }) else {
            return nil
        }
        return IndexPath(row: row, section: section)
    }
}
extension TodBiteViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            // Reset search state
            filteredMeals.removeAll()
            if segmentedControl.selectedSegmentIndex == 0 {
            collectionView.reloadData()
            } else {
                // For My Bowl tab, no filtering needed when search is empty
                tableView.reloadData()
            }
            return
        }

        // Handle search differently based on which tab is active
        if segmentedControl.selectedSegmentIndex == 0 {
            // For Recommended Meal tab - search in available meals
        filteredMeals.removeAll()

        for category in BiteType.predefinedCases {
            // Get meals using the three-level geographical hierarchy
                let allMeals = BiteSampleData.shared.getItems(for: category, in: selectedContinent, in: selectedCountry, in: selectedRegion, for: selectedAgeGroup)
            
            // Filter by search text
            filteredMeals[category] = allMeals.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }

        collectionView.reloadData()
        } else {
            // For My Bowl tab - implement search within myBowlItemsDict
            // This is a simple implementation - you might want to enhance it
            // Currently just reloads the table view without filtering
            // You can implement actual filtering logic here if needed
            tableView.reloadData()
        }
    }
}
extension TodBiteViewController: FilterViewControllerDelegate {
    func didApplyFilters(continent: ContinentType, country: CountryType, region: RegionType, ageGroup: AgeGroup) {
        print("\n✅ Filters Applied - Continent: \(continent.rawValue), Country: \(country.rawValue), Region: \(region.rawValue), Age Group: \(ageGroup.rawValue)")

        self.selectedContinent = continent
        self.selectedCountry = country
        self.selectedRegion = region
        self.selectedAgeGroup = ageGroup
        
        filteredMeals = [:]
        for category in BiteType.predefinedCases {
            let meals = BiteSampleData.shared.getItems(for: category, in: continent, in: country, in: region, for: ageGroup)
            filteredMeals[category] = meals
            
            print("🔄 Category: \(category.rawValue) - Meals Count: \(meals.count)")
            for meal in meals {
                print("🍽️ Meal: \(meal.name) - Age: \(meal.ageGroup.rawValue) - Region: \(meal.region.rawValue)")
            }
        }

        collectionView.reloadData()
    }
}

// Add populateMealData function inside the TodBiteViewController class
extension TodBiteViewController {
    // Function to populate meal data from the TodBiteDataController
    private func fetchAndPopulateMealData() async {
        // Implementation that uses the new PreloadedDataManager
        print("📲 Starting to populate meal data using PreloadedDataManager...")
        
        // Wait for the preloaded data to be ready
        await PreloadedDataManager.shared.ensureDataLoaded()
        
        // Log the data status to verify it's loaded
        print("✅ Data loading completed using PreloadedDataManager")
        print("✅ Categories count: \(BiteSampleData.shared.categories.count)")
        for (category, meals) in BiteSampleData.shared.categories {
            print("   - \(category.rawValue): \(meals.count) meals")
        }
        
        // Set flag indicating initial data load is complete
        initialDataLoadComplete = true
    }
    
    // Helper method to set up navigation buttons for Recommended Meal tab (index 0)
    private func setupNavigationButtonsForRecommendedMeal() {
        // Create history button for navigation bar
        let historyButton = UIButton(type: .system)
        historyButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        historyButton.tintColor = .systemBlue
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        historyButton.addTarget(self, action: #selector(openFeedingPlanHistory), for: .touchUpInside)
        
        let historyBarButton = UIBarButtonItem(customView: historyButton)

        // Set only history button in the navigation bar
        navigationItem.rightBarButtonItems = [historyBarButton]
        
        // Ensure search controller is visible with appropriate placeholder
        searchController.searchBar.placeholder = "Search Recommended Meals..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add filter button to search bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateSearchBarWithFilterButton()
        }
    }

    // Helper method to set up navigation buttons for My Bowl tab (index 1)
    private func setupNavigationButtonsForMyBowl() {
        var barButtonItems: [UIBarButtonItem] = []

        // Add "+" button for adding custom bites
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(createCustomBiteTapped)
        )
        addButton.tintColor = .systemBlue
        barButtonItems.append(addButton)

        // Add Calendar Button for opening Feeding Plan
        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(openFeedingPlan)
        )
        calendarButton.tintColor = .systemBlue
        barButtonItems.append(calendarButton)

        // Set buttons
        navigationItem.rightBarButtonItems = barButtonItems
        
        // Keep search controller visible but without the filter button
        searchController.searchBar.placeholder = "Search My Bowl..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Clear any existing rightView (filter button) from the search text field
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.rightView = nil
        }
    }
}




