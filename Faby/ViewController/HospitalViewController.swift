import UIKit
import MapKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.dataSource = self
        tableView.delegate = self
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

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitals.count
    }

    private func getScheduledVaccinationDates() -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Match the format used when saving data

        // Retrieve data from UserDefaults
        let savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] ?? []

        // Extract and convert dates from the saved data
        let dates = savedData.compactMap { $0["date"] }
        return dates.compactMap { dateFormatter.date(from: $0) }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HospitalCell.identifier, for: indexPath) as? HospitalCell else {
            return UITableViewCell()
        }
        let hospital = hospitals[indexPath.row]
        cell.configure(with: hospital)
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedHospital = hospitals[indexPath.row]
        showSchedulePopup(for: selectedHospital)
    }

    // MARK: - Show Schedule Popup
    private func showSchedulePopup(for hospital: Hospital) {
        let alertController = UIAlertController(title: "Select date for scheduling",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "DD/MM/YYYY"
            textField.keyboardType = .numbersAndPunctuation
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            if let dateText = alertController.textFields?.first?.text, !dateText.isEmpty {
                // Save the date and hospital info locally
                self.saveVaccinationData(hospital: hospital, date: dateText)
                
                // Show confirmation message
                self.showConfirmationMessage()
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        present(alertController, animated: true)
    }

    private func saveVaccinationData(hospital: Hospital, date: String) {
        // Create a dictionary to store the hospital and date
        let vaccinationData = ["hospital": hospital.name, "address": hospital.address, "date": date]

        // Retrieve existing data (if any)
        var savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] ?? []

        // Add the new entry
        savedData.append(vaccinationData)

        // Save updated data back to UserDefaults
        UserDefaults.standard.set(savedData, forKey: "VaccinationSchedules")
        print("Saved vaccination schedule: \(vaccinationData)")
    }

    private func showConfirmationMessage() {
        let confirmationAlert = UIAlertController(
            title: "Thank you",
            message: "Your vaccination has been scheduled.",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(confirmationAlert, animated: true)
    }

    // Mock Data
    let hospitals = [
        Hospital(name: "Kailash Hospital", address: "Knowledge Park 3, Greater Noida, 201308, Uttar Pradesh", distance: "3-5 km"),
        Hospital(name: "Green City Hospital", address: "Knowledge Park 1, Greater Noida, 201308, Uttar Pradesh", distance: "5-7 km"),
        Hospital(name: "Sharda Hospital", address: "Knowledge Park 2, Greater Noida, 201308, Uttar Pradesh", distance: "7-10 km")
    ]
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
        distanceLabel.text = hospital.distance
    }
}


