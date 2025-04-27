import UIKit
import MapKit
import CoreLocation

// MARK: - Hospital Model
//struct Hospital {
//    let babyId: UUID
//    let name: String
//    let address: String
//    let distance: Double
//}

// MARK: - HospitalViewController
class HospitalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Vaccine properties
    var vaccine: Vaccine?
    var vaccineName: String = "Vaccination"
    var vaccineId: UUID = UUID()
    
    private var hospitals: [Hospital] = []
    private let hospitalSearchManager = HospitalSearchManager.shared
    private let locationManager = CLLocationManager()
    
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
    
    // Loading indicator
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Add a status label for location errors
    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    // Date formatter for consistent date formatting
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        
        // Update title if a vaccine is provided
        if let vaccine = vaccine {
            vaccineName = vaccine.name
            vaccineId = vaccine.id
            navigationItem.title = "\(vaccineName)"
            print("✅ Scheduling vaccine: \(vaccineName) (ID: \(vaccineId))")
        } else {
            navigationItem.title = "Schedule Vaccination"
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        mapView.delegate = self
        
        // Show loading indicator
        activityIndicator.startAnimating()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check location authorization status
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Request permission if not determined yet
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show alert or status message when location access is restricted or denied
            showLocationAccessError()
        case .authorizedWhenInUse, .authorizedAlways:
            // We have permission, proceed with loading hospitals
            locationManager.startUpdatingLocation()
            loadNearbyHospitals()
        @unknown default:
            print("Unknown location authorization status")
            showLocationAccessError()
        }
    }
    
    private func showLocationAccessError() {
        activityIndicator.stopAnimating()
        statusLabel.isHidden = false
        statusLabel.text = "Location access is required to find nearby hospitals.\nPlease enable location access in Settings."
        
        // Add settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setTitle("Open Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.addSubview(mapView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)
        
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Once we get the location, we can stop updating
        locationManager.stopUpdatingLocation()
        
        // Load nearby hospitals
        loadNearbyHospitals()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        activityIndicator.stopAnimating()
        statusLabel.isHidden = false
        statusLabel.text = "Unable to determine your location.\nPlease check your device settings."
    }
    
    private func loadNearbyHospitals() {
        hospitalSearchManager.findNearbyHospitals { [weak self] hospitals in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.hospitals = hospitals
                self.tableView.reloadData()
                self.addAnnotationsToMap()
                self.activityIndicator.stopAnimating()
                
                if hospitals.isEmpty {
                    self.statusLabel.isHidden = false
                    self.statusLabel.text = "No hospitals found nearby. Please try again later."
                } else {
                    self.statusLabel.isHidden = true
                }
                
                // If we have locations, set the map region to show them
                if let firstHospital = hospitals.first, let coordinates = firstHospital.coordinates {
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: coordinates, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    private func addAnnotationsToMap() {
        // Clear existing annotations
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        // Add new annotations
        for hospital in hospitals {
            guard let coordinates = hospital.coordinates else { continue }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = hospital.name
            annotation.subtitle = String(format: "%.1f km away", hospital.distance)
            
            mapView.addAnnotation(annotation)
        }
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
    
    // MARK: - Map View Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "HospitalAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            (annotationView as? MKMarkerAnnotationView)?.glyphImage = UIImage(systemName: "cross.fill")
            (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .systemRed
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    // MARK: - Scheduling Methods
    private func showSchedulePopup(for hospital: Hospital) {
        // Create a clean, modern sheet presentation
        let dateSelectionVC = UIViewController()
        dateSelectionVC.view.backgroundColor = .systemBackground
        dateSelectionVC.modalPresentationStyle = .formSheet
        dateSelectionVC.preferredContentSize = CGSize(width: 340, height: 480)
        
        // Hospital card view container
        let hospitalCardView = UIView()
        hospitalCardView.backgroundColor = .systemGray6
        hospitalCardView.layer.cornerRadius = 12
        hospitalCardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Hospital name with icon
        let nameStack = UIStackView()
        nameStack.axis = .horizontal
        nameStack.spacing = 8
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        let hospitalIcon = UIImageView()
        hospitalIcon.image = UIImage(systemName: "building.2")
        hospitalIcon.tintColor = .systemBlue
        hospitalIcon.contentMode = .scaleAspectFit
        hospitalIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hospitalIcon.widthAnchor.constraint(equalToConstant: 24),
            hospitalIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = hospital.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .label
        
        nameStack.addArrangedSubview(hospitalIcon)
        nameStack.addArrangedSubview(nameLabel)
        
        // Hospital address with icon
        let addressStack = UIStackView()
        addressStack.axis = .horizontal
        addressStack.spacing = 8
        addressStack.alignment = .top
        addressStack.translatesAutoresizingMaskIntoConstraints = false
        
        let addressIcon = UIImageView()
        addressIcon.image = UIImage(systemName: "mappin.and.ellipse")
        addressIcon.tintColor = .systemRed
        addressIcon.contentMode = .scaleAspectFit
        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressIcon.widthAnchor.constraint(equalToConstant: 24),
            addressIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let addressLabel = UILabel()
        addressLabel.text = hospital.address
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 2
        
        addressStack.addArrangedSubview(addressIcon)
        addressStack.addArrangedSubview(addressLabel)
        
        // Distance with icon
        let distanceStack = UIStackView()
        distanceStack.axis = .horizontal
        distanceStack.spacing = 8
        distanceStack.translatesAutoresizingMaskIntoConstraints = false
        
        let distanceIcon = UIImageView()
        distanceIcon.image = UIImage(systemName: "location.north.circle")
        distanceIcon.tintColor = .systemGreen
        distanceIcon.contentMode = .scaleAspectFit
        distanceIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            distanceIcon.widthAnchor.constraint(equalToConstant: 24),
            distanceIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let distanceLabel = UILabel()
        distanceLabel.text = String(format: "%.1f km away", hospital.distance)
        distanceLabel.font = UIFont.systemFont(ofSize: 14)
        distanceLabel.textColor = .secondaryLabel
        
        distanceStack.addArrangedSubview(distanceIcon)
        distanceStack.addArrangedSubview(distanceLabel)
        
        // Arrange hospital info in stack
        let hospitalInfoStack = UIStackView(arrangedSubviews: [nameStack, addressStack, distanceStack])
        hospitalInfoStack.axis = .vertical
        hospitalInfoStack.spacing = 8
        hospitalInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        hospitalCardView.addSubview(hospitalInfoStack)
        NSLayoutConstraint.activate([
            hospitalInfoStack.topAnchor.constraint(equalTo: hospitalCardView.topAnchor, constant: 16),
            hospitalInfoStack.leadingAnchor.constraint(equalTo: hospitalCardView.leadingAnchor, constant: 16),
            hospitalInfoStack.trailingAnchor.constraint(equalTo: hospitalCardView.trailingAnchor, constant: -16),
            hospitalInfoStack.bottomAnchor.constraint(equalTo: hospitalCardView.bottomAnchor, constant: -16)
        ])
        
        // Title for date picker
        let dateTitle = UILabel()
        dateTitle.text = "Select Vaccination Date"
        dateTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dateTitle.textAlignment = .center
        dateTitle.translatesAutoresizingMaskIntoConstraints = false
        
        // Create beautiful date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date()
        datePicker.tintColor = .systemBlue
        datePicker.backgroundColor = .systemBackground
        datePicker.layer.cornerRadius = 12
        datePicker.clipsToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Add beautiful buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .systemGray6
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.layer.cornerRadius = 12
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Schedule", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(confirmButton)
        
        // Add action to buttons
        cancelButton.addAction(UIAction { [weak self] _ in
            dateSelectionVC.dismiss(animated: true, completion: nil)
        }, for: .touchUpInside)
        
        confirmButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.saveVaccinationData(hospital: hospital, date: datePicker.date)
            dateSelectionVC.dismiss(animated: true) {
                self.showConfirmationMessage()
            }
        }, for: .touchUpInside)
        
        // Add everything to the view
        dateSelectionVC.view.addSubview(dateTitle)
        dateSelectionVC.view.addSubview(hospitalCardView)
        dateSelectionVC.view.addSubview(datePicker)
        dateSelectionVC.view.addSubview(buttonStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            dateTitle.topAnchor.constraint(equalTo: dateSelectionVC.view.topAnchor, constant: 20),
            dateTitle.leadingAnchor.constraint(equalTo: dateSelectionVC.view.leadingAnchor, constant: 20),
            dateTitle.trailingAnchor.constraint(equalTo: dateSelectionVC.view.trailingAnchor, constant: -20),
            
            hospitalCardView.topAnchor.constraint(equalTo: dateTitle.bottomAnchor, constant: 16),
            hospitalCardView.leadingAnchor.constraint(equalTo: dateSelectionVC.view.leadingAnchor, constant: 20),
            hospitalCardView.trailingAnchor.constraint(equalTo: dateSelectionVC.view.trailingAnchor, constant: -20),
            
            datePicker.topAnchor.constraint(equalTo: hospitalCardView.bottomAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: dateSelectionVC.view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: dateSelectionVC.view.trailingAnchor, constant: -20),
            
            buttonStack.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: dateSelectionVC.view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: dateSelectionVC.view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 52),
            buttonStack.bottomAnchor.constraint(lessThanOrEqualTo: dateSelectionVC.view.bottomAnchor, constant: -20)
        ])
        
        present(dateSelectionVC, animated: true)
    }
    
    private func saveVaccinationData(hospital: Hospital, date: Date) {
        // Create a hospital location from coordinates
        var location = ""
        if let coordinates = hospital.coordinates {
            location = "\(coordinates.latitude),\(coordinates.longitude)"
        } else {
            // If no coordinates, use the address as location
            location = hospital.address
        }
        
        // Get the baby ID from UserDefaultsManager
        guard let babyId = UserDefaultsManager.shared.currentBabyId else {
            print("❌ Error: No baby ID available")
            return
        }
        
        // Get the vaccine ID from the provided vaccine or use default
        let finalVaccineId: UUID
        let finalVaccineName: String
        
        if let vaccine = self.vaccine {
            finalVaccineId = vaccine.id
            finalVaccineName = vaccine.name
            print("✅ Using vaccine from selection: \(finalVaccineName) (ID: \(finalVaccineId))")
        } else {
            finalVaccineId = self.vaccineId
            finalVaccineName = self.vaccineName
            print("⚠️ Using default vaccine ID: \(finalVaccineId)")
        }
        
        // Save the schedule using the VaccineScheduleManager
        Task {
            do {
                print("📝 Saving vaccine schedule with the following details:")
                print("   - Vaccine: \(finalVaccineName)")
                print("   - Vaccine ID: \(finalVaccineId)")
                print("   - Baby ID: \(babyId)")
                print("   - Hospital: \(hospital.name)")
                print("   - Date: \(date)")
                print("   - Location: \(location)")
                
                try await VaccineScheduleManager.shared.saveSchedule(
                    babyId: babyId,
                    vaccineId: finalVaccineId,
                    hospital: hospital.name,
                    date: date,
                    location: location
                )
                
                print("✅ Successfully saved vaccination schedule for \(finalVaccineName) at \(hospital.name)")
            } catch {
                print("❌ Error saving vaccination schedule: \(error)")
                
                // Show error alert on main thread
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "Failed to save vaccination: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        // Just dismiss this view controller
        dismiss(animated: true) {
            // Post a notification to navigate to VaccineReminderViewController
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToVaccineReminder"), object: nil)
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
