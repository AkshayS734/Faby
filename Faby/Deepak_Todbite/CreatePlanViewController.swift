import UIKit

class CreatePlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SectionExpandableDelegate {

    // MARK: - UI Components
    private let fromDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Start Date", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray6
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let toDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select End Date", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray6
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let intervalsLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Intervals"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let tableView = UITableView()
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Plan", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Properties
    var selectedItemsDict: [CategoryType: [Item]] = [:]  // Stores MyBowl selected items
    var selectedFromDate: Date?
    var selectedToDate: Date?
    private var expandedSections: Set<CategoryType> = [] // Tracks expanded sections

    weak var delegate: HomeViewController? // 🔥 Add delegate for data passing

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        print("✅ MyBowl Items Received: \(selectedItemsDict)") // Debugging
    }

    // MARK: - Setup UI
    private func setupUI() {
        [fromDateButton, toDateButton, intervalsLabel, tableView, submitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        // Configure TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IntervalTableViewCell.self, forCellReuseIdentifier: "IntervalCell")

        // Add constraints
        NSLayoutConstraint.activate([
            fromDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            fromDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            toDateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toDateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            intervalsLabel.topAnchor.constraint(equalTo: fromDateButton.bottomAnchor, constant: 20),
            intervalsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            tableView.topAnchor.constraint(equalTo: intervalsLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),

            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

//        submitButton.addTarget(self, action: #selector(submitPlan), for: .touchUpInside)
    }
    
    // MARK: - Submit Plan
//    @objc private func submitPlan() {
//        delegate?.myBowlItemsDict = selectedItemsDict
//        delegate?.updateTodaysBitesData()
//        navigationController?.popViewController(animated: true)
//    }

    // MARK: - SectionExpandableDelegate
    func didTapExpandCollapse(for section: Int) {
        let category = Array(selectedItemsDict.keys)[section]
        
        if expandedSections.contains(category) {
            expandedSections.remove(category)
        } else {
            expandedSections.insert(category)
        }

        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedItemsDict.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(selectedItemsDict.keys)[section]
        let itemCount = selectedItemsDict[category]?.count ?? 0
        return expandedSections.contains(category) ? 1 + itemCount : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = Array(selectedItemsDict.keys)[indexPath.section]

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath) as? IntervalTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: category.rawValue, isExpanded: expandedSections.contains(category), section: indexPath.section)
            cell.delegate = self
            return cell
        } else {
            let cell = UITableViewCell()
            let foodItem = selectedItemsDict[category]?[indexPath.row - 1] ?? Item(name: "Unknown", description: "", image: "")
            cell.textLabel?.text = foodItem.name
            return cell
        }
    }
}
