import UIKit

class TodBiteViewController: UIViewController, UITableViewDelegate {

    // MARK: - UI Components
    @IBOutlet weak var segmentedControl: UISegmentedControl! // Connect this in storyboard
    var collectionView: UICollectionView!
    var tableView: UITableView!
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "No items added to MyBowl yet."
        label.textAlignment = .center
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.isHidden = true // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var createPlanButton: UIButton!

    // MARK: - Properties
    var selectedCategory: CategoryType? = nil
    var selectedRegion: RegionType = .East
    var selectedAgeGroup: AgeGroup = .months12to15

    // Items for MyBowl grouped by category
    var myBowlItemsDict: [CategoryType: [Item]] = [:]

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        setupCreatePlanButton()
        setupPlaceholderLabel()
        loadDefaultContent()
    }

    // MARK: - UI Setup
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UINib(nibName: "TodBiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TodBiteCollectionViewCell")
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

    private func setupCreatePlanButton() {
        createPlanButton = UIButton(type: .system)
        createPlanButton.setTitle("Create Plan", for: .normal)
        createPlanButton.translatesAutoresizingMaskIntoConstraints = false
        createPlanButton.backgroundColor = .systemBlue
        createPlanButton.setTitleColor(.white, for: .normal)
        createPlanButton.layer.cornerRadius = 10
        createPlanButton.addTarget(self, action: #selector(createPlanButtonTapped), for: .touchUpInside)
        view.addSubview(createPlanButton)

        NSLayoutConstraint.activate([
            createPlanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createPlanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createPlanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createPlanButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        createPlanButton.isHidden = true // Initially hidden
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

    // MARK: - Actions
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            collectionView.isHidden = false
            tableView.isHidden = true
            createPlanButton.isHidden = true
            placeholderLabel.isHidden = true
        case 1:
            collectionView.isHidden = true
            updatePlaceholderVisibility()
            tableView.reloadData()
        default:
            break
        }
    }

    @objc private func createPlanButtonTapped() {
        let createPlanVC = CreatePlanViewController()
        // Map items to their names
        createPlanVC.selectedItems = myBowlItemsDict.flatMap { $0.value }.map { $0.name }
        navigationController?.pushViewController(createPlanVC, animated: true)
    }

    private func updatePlaceholderVisibility() {
        let isMyBowlEmpty = myBowlItemsDict.isEmpty
        placeholderLabel.isHidden = !isMyBowlEmpty
        tableView.isHidden = isMyBowlEmpty
        createPlanButton.isHidden = isMyBowlEmpty
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
    internal func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])

        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }


    private func handleMoreOptions(for item: Item, in category: CategoryType, at indexPath: IndexPath) {
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
            self.showToast(message: "\(item.name) added to favorites!")
        }))

        alert.addAction(UIAlertAction(title: "Add to Other Section", style: .default, handler: { _ in
            self.showToast(message: "Feature coming soon!")
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func addItemToMyBowl(item: Item) {
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
        return CategoryType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard segmentedControl.selectedSegmentIndex == 0 else { return 0 }
        let category = CategoryType.allCases[section]
        return Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodBiteCollectionViewCell", for: indexPath) as? TodBiteCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = CategoryType.allCases[indexPath.section]
        let items = Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup)
        let item = items[indexPath.row]
        let isAdded = myBowlItemsDict[category]?.contains(where: { $0.name == item.name }) ?? false

        cell.configure(with: item, category: category,isAdded: isAdded)
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

        let sectionName = CategoryType.allCases[indexPath.section].rawValue
        let intervalText = "\(7 + indexPath.section):30 AM - \(8 + indexPath.section):00 AM"
        headerView.configure(with: sectionName, interval: intervalText)
        return headerView
    }
}

// MARK: - UICollectionViewDelegate
extension TodBiteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = CategoryType.allCases[indexPath.section]
        let items = Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup)
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

        // Configure the more options button
        cell.moreOptionsButton.tag = indexPath.row
        cell.moreOptionsButton.addTarget(self, action: #selector(moreOptionsTapped(_:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard segmentedControl.selectedSegmentIndex == 1 else { return nil }
        let category = Array(myBowlItemsDict.keys)[section]
        return category.rawValue
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
    func didTapAddButton(for item: Item, in category: CategoryType) {
        // Check if the item is already in MyBowl
        if myBowlItemsDict[category]?.contains(where: { $0.name == item.name }) == true {
            // Show toast message if duplicate
            showToast(message: "\"\(item.name)\" is already in MyBowl!")
        } else {
            // Add the item to MyBowl if not already present
            if myBowlItemsDict[category] == nil {
                myBowlItemsDict[category] = []
            }
            myBowlItemsDict[category]?.append(item)
            showToast(message: "\"\(item.name)\" added to MyBowl!")

            // Reload the specific cell to update button state
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

    private func indexPathForItem(_ item: Item, in category: CategoryType) -> IndexPath? {
        guard let section = CategoryType.allCases.firstIndex(of: category),
              let row = Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup).firstIndex(where: { $0.name == item.name }) else {
            return nil
        }
        return IndexPath(row: row, section: section)
    }
}
