import UIKit

class FeedingPlanHistoryViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    var feedingHistory: [String: [[String: String]]] = [:] // ✅ Dictionary of saved feeding plans
    var sortedDates: [String] = [] // ✅ Sorted dates to display
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feeding Plan History"
        view.backgroundColor = .white
        setupTableView()
        loadFeedingHistory()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedingHistoryCell.self, forCellReuseIdentifier: "FeedingHistoryCell") // ✅ Custom Cell
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadFeedingHistory() {
        if let savedData = UserDefaults.standard.dictionary(forKey: "mealPlanHistory") as? [String: [[String: String]]] {
            feedingHistory = savedData
            sortedDates = feedingHistory.keys.sorted(by: { $0 > $1 }) // ✅ Sort by latest date

            // ✅ Debugging: Print Retrieved Data
            print("📌 Retrieved Feeding History: \(feedingHistory)")
        } else {
            print("⚠️ No feeding history found!")
        }
        tableView.reloadData()
    }
}

extension FeedingPlanHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedDates[section] // ✅ Now correctly uses section as Int
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
        if let meals = feedingHistory[date] {
            let meal = meals[indexPath.row]
            
            let category = meal["category"] ?? "Unknown"
            let time = meal["time"] ?? ""
            let foodName = meal["name"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let imageName = meal["image"] ?? ""

            // ✅ Check if food name exists; if empty, use category name
            let displayFoodName = !foodName.isEmpty ? foodName : category

            print("📌 Configuring cell: \(category) | Time: \(time) | Food Name: \(displayFoodName) | Image: \(imageName)") // 🔍 Debug print

            cell.configure(category: category, time: time, foodName: displayFoodName, imageName: imageName)
        }

        return cell
    }
}
