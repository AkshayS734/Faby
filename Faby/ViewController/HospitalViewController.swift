import UIKit
import MapKit

// MARK: - Hospital Model
//struct Hospital {
//    let babyId: UUID
//    let name: String
//    let address: String
//    let distance: Double
//}

// MARK: - HospitalViewController
class HospitalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // UI Elements
    let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Hospital near me"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(HospitalCell.self, forCellReuseIdentifier: HospitalCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Mock Data
    let hospitals = [
        Hospital(babyId: UUID(), name: "Kailash Hospital", address: "Knowledge Park 3, Greater Noida, 201308, Uttar Pradesh", distance: 4.0),
        Hospital(babyId: UUID(), name: "Green City Hospital", address: "Knowledge Park 1, Greater Noida, 201308, Uttar Pradesh", distance: 6.0),
        Hospital(babyId: UUID(), name: "Sharda Hospital", address: "Knowledge Park 2, Greater Noida, 201308, Uttar Pradesh", distance: 8.5)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
        setMapRegion()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Hepatitis Vaccination"
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.addSubview(tableView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setMapRegion() {
        let latitude: CLLocationDegrees = 28.4744
        let longitude: CLLocationDegrees = 77.5021
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HospitalCell.identifier, for: indexPath) as? HospitalCell else {
            return UITableViewCell()
        }
        let hospital = hospitals[indexPath.row]
        cell.configure(with: hospital)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHospital = hospitals[indexPath.row]
        showSchedulePopup(for: selectedHospital)
    }
    
    // MARK: - Scheduling Methods
    private func showSchedulePopup(for hospital: Hospital) {
        let alertController = UIAlertController(
            title: "Select date for scheduling",
            message: nil,
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "DD/MM/YYYY"
            textField.keyboardType = .numbersAndPunctuation
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            if let dateText = alertController.textFields?.first?.text, !dateText.isEmpty {
                self?.saveVaccinationData(hospital: hospital, date: dateText)
                self?.showConfirmationMessage()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        present(alertController, animated: true)
    }
    
    private func saveVaccinationData(hospital: Hospital, date: String) {
        let vaccineType = navigationItem.title?.replacingOccurrences(of: " Vaccination", with: "") ?? "Unknown"
        let vaccinationData = [
            "type": vaccineType,
            "hospital": hospital.name,
            "address": hospital.address,
            "date": date
        ]
        
        var savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] ?? []
        savedData.append(vaccinationData)
        UserDefaults.standard.set(savedData, forKey: "VaccinationSchedules")
    }
    
    private func showConfirmationMessage() {
        let confirmationAlert = UIAlertController(
            title: "Thank you",
            message: "Your vaccination has been scheduled.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToVacciAlert()
        }
        
        confirmationAlert.addAction(okAction)
        present(confirmationAlert, animated: true)
    }
    
    private func navigateToVacciAlert() {
        let vacciAlertVC = VacciAlertViewController()
        
        // If presented modally, dismiss first then navigate
        if let presentingVC = presentingViewController {
            dismiss(animated: true) {
                if let navigationController = presentingVC as? UINavigationController {
                    navigationController.pushViewController(vacciAlertVC, animated: true)
                } else {
                    presentingVC.navigationController?.pushViewController(vacciAlertVC, animated: true)
                }
            }
        } else {
            // If pushed, just navigate
            navigationController?.pushViewController(vacciAlertVC, animated: true)
        }
    }
}

// MARK: - HospitalCell
class HospitalCell: UITableViewCell {
    static let identifier = "HospitalCell"
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.textColor = .gray
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, addressLabel, distanceLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with hospital: Hospital) {
        nameLabel.text = hospital.name
        addressLabel.text = hospital.address
        distanceLabel.text = String(format: "%.1f km", hospital.distance)
    }
}
