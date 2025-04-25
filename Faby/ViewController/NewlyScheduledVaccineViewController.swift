import UIKit

// MARK: - Notification Extension
extension Notification.Name {
    static let vaccineCompleted = Notification.Name("VaccineCompleted")
}

// MARK: - CompletedVaccineManager
class CompletedVaccineManager {
    static let shared = CompletedVaccineManager()
    private init() {}
    
    private var completedVaccines: [[String: String]] = []
    
    func storeCompletedVaccine(_ vaccine: [String: String]) {
        completedVaccines.append(vaccine)
        NotificationCenter.default.post(name: .vaccineCompleted, object: nil)
    }
    
    func getCompletedVaccines() -> [[String: String]] {
        return completedVaccines
    }
    
    func removeVaccine(at index: Int) {
        completedVaccines.remove(at: index)
    }
    
    func clearCompletedVaccines() {
        completedVaccines.removeAll()
    }
}

// MARK: - CompletedVaccineCell
class CompletedVaccineCell: UITableViewCell {
    
    // MARK: - UI Components
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vaccineIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "syringe")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hospitalContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let hospitalIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "building.2")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let hospitalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(vaccineIcon)
        cardView.addSubview(titleLabel)
        cardView.addSubview(dateContainer)
        dateContainer.addSubview(dateIcon)
        dateContainer.addSubview(dateLabel)
        cardView.addSubview(hospitalContainer)
        hospitalContainer.addSubview(hospitalIcon)
        hospitalContainer.addSubview(hospitalLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            vaccineIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            vaccineIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            vaccineIcon.widthAnchor.constraint(equalToConstant: 24),
            vaccineIcon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: vaccineIcon.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: vaccineIcon.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            dateContainer.topAnchor.constraint(equalTo: vaccineIcon.bottomAnchor, constant: 12),
            dateContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            dateContainer.heightAnchor.constraint(equalToConstant: 32),
            
            dateIcon.leadingAnchor.constraint(equalTo: dateContainer.leadingAnchor, constant: 8),
            dateIcon.centerYAnchor.constraint(equalTo: dateContainer.centerYAnchor),
            dateIcon.widthAnchor.constraint(equalToConstant: 16),
            dateIcon.heightAnchor.constraint(equalToConstant: 16),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateIcon.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: -8),
            dateLabel.centerYAnchor.constraint(equalTo: dateContainer.centerYAnchor),
            
            hospitalContainer.topAnchor.constraint(equalTo: dateContainer.bottomAnchor, constant: 8),
            hospitalContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            hospitalContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            hospitalContainer.heightAnchor.constraint(equalToConstant: 32),
            
            hospitalIcon.leadingAnchor.constraint(equalTo: hospitalContainer.leadingAnchor, constant: 8),
            hospitalIcon.centerYAnchor.constraint(equalTo: hospitalContainer.centerYAnchor),
            hospitalIcon.widthAnchor.constraint(equalToConstant: 16),
            hospitalIcon.heightAnchor.constraint(equalToConstant: 16),
            
            hospitalLabel.leadingAnchor.constraint(equalTo: hospitalIcon.trailingAnchor, constant: 8),
            hospitalLabel.trailingAnchor.constraint(equalTo: hospitalContainer.trailingAnchor, constant: -8),
            hospitalLabel.centerYAnchor.constraint(equalTo: hospitalContainer.centerYAnchor)
        ])
    }
    
    func configure(with vaccine: [String: String]) {
        titleLabel.text = vaccine["type"]
        dateLabel.text = vaccine["date"]
        hospitalLabel.text = vaccine["hospital"]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16).cgPath
    }
}

// MARK: - NewlyScheduledVaccineViewController
class NewlyScheduledVaccineViewController: UIViewController {
    
    // MARK: - Properties
    private let storageManager = CompletedVaccineManager.shared
    private var completedVaccines: [[String: String]] = []
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CompletedVaccineCell.self, forCellReuseIdentifier: "CompletedVaccineCell")
        table.separatorStyle = .none
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "syringe")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No completed vaccines yet"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupUI()
        setupNotifications()
        loadCompletedVaccines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCompletedVaccines()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupViewController() {
        title = "Administered Vaccines"  // Changed from "Completed Vaccines"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false  // Changed from true to false
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateView.heightAnchor.constraint(equalToConstant: 150),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVaccineCompleted),
            name: .vaccineCompleted,
            object: nil
        )
    }
    
    // MARK: - Data Loading
    private func loadCompletedVaccines() {
        // Load from local storage
        completedVaccines = storageManager.getCompletedVaccines()
        
        // Also load from Supabase
        Task {
            do {
                // Get the current baby from the app's state
                let baby = BabyDataModel.shared.babyList[0]
                
                // Create a Supabase manager
                let supabaseManager = SupabaseVaccineManager.shared
                
                // Fetch administered vaccines for this baby
                let administeredVaccines = try await supabaseManager.fetchAdministeredVaccines(forBabyId: baby.babyID.uuidString)
                
                await MainActor.run {
                    // Convert administered vaccines to dictionary format
                    let vaccineRecords = administeredVaccines.map { record -> [String: String] in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        
                        return [
                            "type": "Vaccine", // Will need to fetch actual name
                            "date": dateFormatter.string(from: record.administeredDate),
                            "hospital": "Hospital" // Need to include hospital info
                        ]
                    }
                    
                    // Combine local and Supabase data (avoiding duplicates)
                    var allVaccines = completedVaccines
                    
                    for supabaseVaccine in vaccineRecords {
                        // Check if this vaccine is already in our list
                        let isDuplicate = allVaccines.contains { localVaccine in
                            localVaccine["type"] == supabaseVaccine["type"] &&
                            localVaccine["date"] == supabaseVaccine["date"]
                        }
                        
                        if !isDuplicate {
                            allVaccines.append(supabaseVaccine)
                        }
                    }
                    
                    // Update the UI
                    completedVaccines = allVaccines
                    updateUI()
                }
            } catch {
                print("❌ Error loading administered vaccines from Supabase: \(error)")
            }
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
        emptyStateView.isHidden = !completedVaccines.isEmpty
    }
    
    // MARK: - Notification Handlers
    @objc private func handleVaccineCompleted() {
        loadCompletedVaccines()
    }
}



// MARK: - UITableView Extensions
extension NewlyScheduledVaccineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedVaccines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedVaccineCell", for: indexPath) as? CompletedVaccineCell else {
            return UITableViewCell()
        }
        
        let vaccine = completedVaccines[indexPath.row]
        cell.configure(with: vaccine)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storageManager.removeVaccine(at: indexPath.row)
            completedVaccines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateUI()
        }
    }
}
