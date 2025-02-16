import UIKit

class FeedingPlanSummaryViewController: UIViewController {

    var selectedDay: String = ""
    var savedPlan: [BiteType: [FeedingMeal]] = [:]
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    // ✅ Add Date Label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkGray
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Plan"
        view.backgroundColor = .white

        setupDateLabel()
        setupTableView()
        setupNavigationBar()  // ✅ Added Share Button

        dateLabel.text = "Saved Plan for \(selectedDay)"
    }

    private func setupNavigationBar() {
        // ✅ Add Share Button in the Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Share",
            style: .plain,
            target: self,
            action: #selector(sharePlan)
        )
    }

    private func setupDateLabel() {
        view.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FeedingPlanCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // ✅ Share Feeding Plan
    @objc private func sharePlan() {
        let mealText = generateShareableText()
        let activityVC = UIActivityViewController(activityItems: [mealText], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    // ✅ Convert Feeding Plan to Text Format for Sharing
    private func generateShareableText() -> String {
        var text = "📅 Feeding Plan for \(selectedDay)\n\n"
        
        for (category, meals) in savedPlan {
            text += "🍽 \(category.rawValue.uppercased())\n"
            for meal in meals {
                text += "✅ \(meal.name)\n"
            }
            text += "\n"
        }
        return text
    }
}

// ✅ Table View Data Source
extension FeedingPlanSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedPlan.keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categories = Array(savedPlan.keys)
        return categories[section].rawValue // ✅ BiteType name (EarlyBite, etc.)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categories = Array(savedPlan.keys)
        let category = categories[section]
        return savedPlan[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingPlanCell", for: indexPath)
        let categories = Array(savedPlan.keys)
        let category = categories[indexPath.section]
        let meals = savedPlan[category] ?? []
        cell.textLabel?.text = meals[indexPath.row].name
        return cell
    }
}
