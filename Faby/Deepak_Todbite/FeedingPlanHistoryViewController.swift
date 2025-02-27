import UIKit

class FeedingPlanHistoryViewController: UIViewController {

    private let tableView = UITableView()
    private var mealHistory: [String: [[String: String]]] = [:]  // ✅ Dictionary to store meal history

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feeding Plan History"
        view.backgroundColor = .white
        setupTableView()
        loadMealHistory()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadMealHistory() {
        mealHistory = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] ?? [:]
        tableView.reloadData()
    }
}

// ✅ Table View Data Source
extension FeedingPlanHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealHistory.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sortedDates = mealHistory.keys.sorted(by: { $0 > $1 })
        return sortedDates[section]  // ✅ Display the saved date as section title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedDates = mealHistory.keys.sorted(by: { $0 > $1 })
        let selectedDate = sortedDates[section]
        return mealHistory[selectedDate]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let sortedDates = mealHistory.keys.sorted(by: { $0 > $1 })
        let selectedDate = sortedDates[indexPath.section]
        let meals = mealHistory[selectedDate] ?? []

        let meal = meals[indexPath.row]
        cell.textLabel?.text = "\(meal["category"] ?? "") - \(meal["time"] ?? "")"
        return cell
    }
}
