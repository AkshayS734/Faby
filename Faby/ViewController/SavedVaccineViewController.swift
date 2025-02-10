import UIKit

class SavedVaccineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let vaccineManager = VaccineManager.shared
    
    // Dictionary to group vaccines by stage
    private var groupedVaccines: [String: [String]] = [:]
    private var stages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        loadAndGroupVaccines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload saved vaccines when view appears
        vaccineManager.loadSelectedVaccines()
        loadAndGroupVaccines()
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Vaccination History"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(downloadTapped))
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VaccineCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadAndGroupVaccines() {
        // Clear existing groupings
        groupedVaccines.removeAll()
        
        // Group selected vaccines by their stage
        for vaccine in vaccineManager.selectedVaccines {
            // Find the stage for this vaccine
            for stage in vaccineManager.vaccineData {
                if stage.vaccines.contains(vaccine) {
                    if groupedVaccines[stage.stageTitle] == nil {
                        groupedVaccines[stage.stageTitle] = []
                    }
                    groupedVaccines[stage.stageTitle]?.append(vaccine)
                }
            }
        }
        
        // Sort stages chronologically based on vaccineData order
        stages = vaccineManager.vaccineData
            .map { $0.stageTitle }
            .filter { groupedVaccines[$0]?.isEmpty == false }
    }
    
    @objc private func downloadTapped() {
        // Implement download functionality
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stage = stages[section]
        return groupedVaccines[stage]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stages[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath)
        
        let stage = stages[indexPath.section]
        if let vaccines = groupedVaccines[stage] {
            let vaccine = vaccines[indexPath.row]
            
            // Configure cell
            var config = cell.defaultContentConfiguration()
            config.text = vaccine
            config.textProperties.font = .systemFont(ofSize: 17)
            
            // Extract dose info if present
            if let range = vaccine.range(of: "(Dose \\d+)", options: .regularExpression) {
                config.secondaryText = String(vaccine[range])
                config.secondaryTextProperties.color = .gray
                config.secondaryTextProperties.font = .systemFont(ofSize: 15)
                
                // Remove dose info from main text
                let mainText = vaccine.replacingOccurrences(of: " \\(Dose \\d+\\)",
                                                          with: "",
                                                          options: .regularExpression)
                config.text = mainText
            }
            
            cell.contentConfiguration = config
            
            // Add info button
            let infoButton = UIButton(type: .system)
            infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
            infoButton.sizeToFit()
            cell.accessoryView = infoButton
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
