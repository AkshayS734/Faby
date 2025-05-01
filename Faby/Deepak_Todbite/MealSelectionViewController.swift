import UIKit

class MealSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var onMealSelected: ((FeedingMeal) -> Void)?
    var allMeals: [FeedingMeal] = []
    private var filteredMeals: [FeedingMeal] = []
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Meal"
        view.backgroundColor = .white
        
        setupSearchBar()
        setupTableView()
        
        // Initially, filtered meals are the same as all meals
        filteredMeals = allMeals
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search meals..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MealTableViewCell.self, forCellReuseIdentifier: "MealCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealTableViewCell
        let meal = filteredMeals[indexPath.row]
        
        cell.configure(with: meal)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMeal = filteredMeals[indexPath.row]
        onMealSelected?(selectedMeal)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMeals = allMeals
            isSearching = false
        } else {
            isSearching = true
            filteredMeals = allMeals.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMeals = allMeals
        isSearching = false
        tableView.reloadData()
    }
}
