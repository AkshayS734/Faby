import UIKit

class FeedingPlanSummaryViewController: UIViewController {

    var selectedDay: String = ""
    var savedPlan: [BiteType: [FeedingMeal]] = [:]
    var customBiteTimes: [BiteType: String] = [:] // Add property to store custom bite times
    
    private let tableView = UITableView(frame: .zero, style: .grouped)

    // ✅ Predefined Order
    private let fixedBiteOrder: [BiteType] = [.EarlyBite, .NourishBite, .MidDayBite, .SnackBite, .NightBite]

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Plan"
        view.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Light gray background to match Feeding Plan screen

        setupDateLabel()
        setupTableView()
        setupNavigationBar()

        dateLabel.text = "Saved Plan for \(selectedDay)"
    }

    private func setupNavigationBar() {
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
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Match the same light gray background
        tableView.separatorStyle = .none // Clean look without separators
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }


    @objc private func sharePlan() {
        let mealText = generateShareableText()
        let activityVC = UIActivityViewController(activityItems: [mealText], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    // ✅ Convert Feeding Plan to Text Format for Sharing
    private func generateShareableText() -> String {
        var text = "📅 Feeding Plan for \(selectedDay)\n\n"
        
        for category in getOrderedBiteTypes() {
            if let meals = savedPlan[category], !meals.isEmpty {
                text += "🍽 \(category.rawValue.uppercased())\n"
                for meal in meals {
                    text += "✅ \(meal.name)\n"
                }
                text += "\n"
            }
        }
        return text
    }

    // Function to Get Ordered Bite Types (Predefined first, then custom)
    private func getOrderedBiteTypes() -> [BiteType] {
        var categories: [BiteType] = []
        
        // First add fixed order categories
        for category in fixedBiteOrder {
            if savedPlan[category] != nil && !(savedPlan[category]?.isEmpty ?? true) {
                categories.append(category)
            }
        }
        
        // Then add any custom categories
        for category in savedPlan.keys {
            if !fixedBiteOrder.contains(category) {
                categories.append(category)
            }
        }
        
        return categories
    }
    
    // Helper method to get formatted time display for each bite type
    private func getBiteTimeForDisplay(for biteType: BiteType) -> String {
        switch biteType {
        case .EarlyBite:
            return "7:30 AM - 8:00 AM"
        case .NourishBite:
            return "10:00 AM - 10:30 AM"
        case .MidDayBite:
            return "12:30 PM - 1:00 PM"
        case .SnackBite:
            return "4:00 PM - 4:30 PM"
        case .NightBite:
            return "8:00 PM - 8:30 PM"
        default:
            return "Flexible Time Slot"
        }
    }

    // Add this method to properly display time for each bite type including custom bites
    private func getTimeInterval(for category: BiteType) -> String {
        switch category {
        case .EarlyBite: return "7:30 AM - 8:00 AM"
        case .NourishBite: return "10:00 AM - 10:30 AM"
        case .MidDayBite: return "12:30 PM - 1:00 PM"
        case .SnackBite: return "4:00 PM - 4:30 PM"
        case .NightBite: return "8:00 PM - 8:30 PM"
        case .custom(_): return customBiteTimes[category] ?? "Flexible Time Slot"
        }
    }
}


extension FeedingPlanSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return getOrderedBiteTypes().count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 0.97, alpha: 1.0) // Same background as the view
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .darkGray
        
        // Get bite category and title
        let categories = getOrderedBiteTypes()
        let biteType = categories[section]
        titleLabel.text = biteType.rawValue
        
        // Set time using the getTimeInterval method which handles all bite types
        timeLabel.text = getTimeInterval(for: biteType)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70 // Consistent height for section headers
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categories = getOrderedBiteTypes()
        let category = categories[section]
        return savedPlan[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedingPlanCell", for: indexPath)
        let categories = getOrderedBiteTypes()
        let category = categories[indexPath.section]
        let meals = savedPlan[category] ?? []
        
        // Configure cell to match card style from Feeding Plan
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Create card container view
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add cardView to cell's contentView
        if let existingCardView = cell.contentView.viewWithTag(100) {
            existingCardView.removeFromSuperview()
        }
        cardView.tag = 100
        cell.contentView.addSubview(cardView)
        
        // Setup meal name label
        let nameLabel = UILabel()
        nameLabel.text = meals[indexPath.row].name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // Consistent height for card cells
    }
}
