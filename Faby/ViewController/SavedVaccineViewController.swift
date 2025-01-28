import UIKit

class SavedVaccinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    var savedVaccinationData: [String] = [] // Flat list of vaccine names
    private let emptyStateLabel = UILabel() // Label for empty state message

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.title = "Saved Vaccines"

        // Fetch saved vaccines
        fetchSavedVaccinationDetails()

        // Configure the table view
        configureTableView()

        // Set up empty state message
        setupEmptyStateLabel()
    }

    private func fetchSavedVaccinationDetails() {
        print("Fetching vaccines from UserDefaults")
        print("All UserDefaults: \(UserDefaults.standard.dictionaryRepresentation())")
        
        if let savedData = UserDefaults.standard.array(forKey: "SavedVaccines") as? [String] {
            print("Fetched Saved Vaccines: \(savedData)")
            savedVaccinationData = savedData
        } else {
            print("No vaccines found in UserDefaults")
            savedVaccinationData = []
        }
        tableView.reloadData()
        updateEmptyStateVisibility()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "savedVaccineCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Empty State Handling

    private func setupEmptyStateLabel() {
        emptyStateLabel.text = "No vaccines saved yet."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = .gray
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        emptyStateLabel.isHidden = true // Initially hide the empty state label
    }

    private func updateEmptyStateVisibility() {
        emptyStateLabel.isHidden = !savedVaccinationData.isEmpty
        tableView.isHidden = savedVaccinationData.isEmpty
    }

    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedVaccinationData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedVaccineCell", for: indexPath)
        cell.textLabel?.text = savedVaccinationData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }

    // MARK: - UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle row selection if needed
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
