import UIKit

class FeedingPlanHistoryViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    var feedingHistory: [String: [[String: String]]] = [:]
    var sortedDates: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
        loadFeedingHistory()
        updateTitle()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedingHistoryCell.self, forCellReuseIdentifier: "FeedingHistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        title = "Feeding Plan History"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareHistory)),
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearAllHistory))
        ]
    }

    private func loadFeedingHistory() {
        if let savedData = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] {
            feedingHistory = savedData
            sortedDates = feedingHistory.keys.sorted(by: { $0 > $1 })
        } else {
            feedingHistory = [:]
            sortedDates = []
        }
        tableView.reloadData()
    }

    private func updateTitle() {
        let totalMeals = feedingHistory.values.flatMap { $0 }.count
        title = "Feeding Plan History"
    }

    @objc private func clearAllHistory() {
        let alert = UIAlertController(title: "Clear History", message: "Are you sure you want to delete ALL feeding history?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.feedingHistory.removeAll()
            self?.sortedDates.removeAll()
            UserDefaults.standard.removeObject(forKey: "mealPlanHistory")
            self?.updateTitle()
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }

    @objc private func shareHistory() {
        var historyText = "📖 Feeding Plan History:\n\n"
        for date in sortedDates {
            historyText += "📅 \(date)\n"
            feedingHistory[date]?.forEach { meal in
                let name = meal["name"] ?? meal["category"] ?? "Unknown"
                let time = meal["time"] ?? "Time not set"
                historyText += "🍽️ \(name) - \(time)\n"
            }
            historyText += "\n"
        }
        let activityVC = UIActivityViewController(activityItems: [historyText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension FeedingPlanHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedDates[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = sortedDates[section]
        return feedingHistory[date]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingHistoryCell", for: indexPath) as? FeedingHistoryCell else {
            return UITableViewCell()
        }
        let date = sortedDates[indexPath.section]
        if let meal = feedingHistory[date]?[indexPath.row] {
            cell.configure(
                category: meal["category"] ?? "Unknown",
                time: meal["time"] ?? "",
                foodName: meal["name"] ?? "Meal",
                imageName: meal["image"] ?? ""
            )
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete Meal") { [weak self] _, indexPath in
            guard let self = self else { return }
            let date = self.sortedDates[indexPath.section]
            self.feedingHistory[date]?.remove(at: indexPath.row)

            if self.feedingHistory[date]?.isEmpty == true {
                self.feedingHistory.removeValue(forKey: date)
                self.sortedDates.removeAll(where: { $0 == date })
            }

            UserDefaults.standard.set(self.feedingHistory, forKey: "mealPlanHistory")
            self.updateTitle()
            tableView.reloadData()
        }
        return [deleteAction]
    }

  
    func tableView(_ tableView: UITableView, contextMenuConfigurationForSection section: Int, point: CGPoint) -> UIContextMenuConfiguration? {
        let date = sortedDates[section]

        return UIContextMenuConfiguration(identifier: date as NSString, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Delete Entire Day", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteFullDay(date)
            }
            return UIMenu(title: "Options for \(date)", children: [deleteAction])
        }
    }

    private func deleteFullDay(_ date: String) {
        let alert = UIAlertController(title: "Delete \(date)", message: "Are you sure you want to delete all meals for \(date)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.feedingHistory.removeValue(forKey: date)
            self?.sortedDates.removeAll(where: { $0 == date })
            UserDefaults.standard.set(self?.feedingHistory, forKey: "mealPlanHistory")
            self?.updateTitle()
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
}
