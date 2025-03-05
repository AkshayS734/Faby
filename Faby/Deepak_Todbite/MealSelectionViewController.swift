import UIKit

class MealSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var onMealSelected: ((FeedingMeal) -> Void)?
    private let tableView = UITableView()
    private let availableMeals = BiteSampleData.shared.categories 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Meal"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MealCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return availableMeals.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(availableMeals.keys)[section]
        return availableMeals[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        let category = Array(availableMeals.keys)[indexPath.section]
        let meal = availableMeals[category]?[indexPath.row]
        
        cell.textLabel?.text = meal?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = Array(availableMeals.keys)[indexPath.section]
        let selectedMeal = availableMeals[category]?[indexPath.row]
        
        if let meal = selectedMeal {
            onMealSelected?(meal)
            navigationController?.popViewController(animated: true)
        }
    }
}
