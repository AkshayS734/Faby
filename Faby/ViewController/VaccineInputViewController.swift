import UIKit

class VaccineInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Define the table view
    private let tableView = UITableView()
    
    // Create a label for instructions
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark the vaccines your child has received"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0 // Allow multiline if needed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Vaccine data with sections and rows
    let vaccineData: [(sectionTitle: String, vaccines: [String])] = [
        ("Birth", ["Hepatitis B(Dose 1)"]),
        ("6 weeks", ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        ("10 weeks", ["DTAP (Dose 2) ","Hib (Dose 2)","Rotavirus (Dose 1)", "Pneumococcal (Dose 1) "]),
        ("14 weeks", ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)","Rotavirus (Dose 2)","Pneumococcal(Dose 2)"]),
        ("6 Months", ["Hepatitis B (Dose 3)"]),
        ("9 months", ["MMR (Dose 1)"]),
        ("12 months",["Hepatitis A(Dose 1)","Varicella(Dose 1)"])
    ]
    
    // Array to store selected vaccines
    var selectedVaccines: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        // Set up the navigation bar title
        self.title = "VacciTime"
        view.backgroundColor = .white
        
        // Add the label to the view
        view.addSubview(instructionsLabel)
        
        // Configure the table view
        configureTableView()
        
        // Set up Auto Layout constraints for the label
        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToNextPage), name: .popupProceedTapped, object: nil)
    }
    @objc private func navigateToNextPage() {
        let vacciAlertVC = VacciAlertViewController()
        vacciAlertVC.selectedVaccines = selectedVaccines
        navigationController?.pushViewController(vacciAlertVC, animated: true)
    }
    
    private func configureTableView() {
        // Add the table view to the view hierarchy
        view.addSubview(tableView)
        
        // Set the delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the default cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vaccineCell")
        
        // Set up Auto Layout constraints for the table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20), // Space between label and table
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80) // Leave space for the "Continue" button
        ])
    }
    private func storeVaccinationDetails(childName: String, vaccines: [String]) {
        // Create a dictionary to hold the vaccine details
        let vaccinationDetails: [String: Any] = [
            "childName": childName,
            "vaccines": vaccines,
            "date": Date()  // You can store the current date when vaccines were marked as completed
        ]
        
        // Retrieve existing data from UserDefaults
        var existingData = UserDefaults.standard.array(forKey: "ChildrenVaccinations") as? [[String: Any]] ?? []
        
        // Add the new vaccination details to the list
        existingData.append(vaccinationDetails)
        
        // Store the updated data back into UserDefaults
        UserDefaults.standard.set(existingData, forKey: "ChildrenVaccinations")
        
        print("Vaccination details saved for \(childName): \(vaccines)")
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vaccineData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccineData[section].vaccines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vaccineCell", for: indexPath)
        cell.textLabel?.text = vaccineData[indexPath.section].vaccines[indexPath.row]
        
        // Mark selected vaccines with a checkmark
        let vaccine = vaccineData[indexPath.section].vaccines[indexPath.row]
        if selectedVaccines.contains(vaccine) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vaccineData[section].sectionTitle
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVaccine = vaccineData[indexPath.section].vaccines[indexPath.row]
        
        // Toggle the selection of the vaccine
        if selectedVaccines.contains(selectedVaccine) {
            // Deselect the vaccine
            if let index = selectedVaccines.firstIndex(of: selectedVaccine) {
                selectedVaccines.remove(at: index)
            }
        } else {
            // Select the vaccine
            selectedVaccines.append(selectedVaccine)
        }
        
        // Reload the selected vaccine row
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        print("Selected vaccines: \(selectedVaccines)")
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Continue Button
    
    private func configureContinueButton() {
        // Create the continue button
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 10
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Add the button to the view hierarchy
        view.addSubview(continueButton)
        
        // Set up Auto Layout constraints for the button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func continueButtonTapped() {
        if selectedVaccines.isEmpty {
            // Show an alert if no vaccines are selected
            let noSelectionAlert = UIAlertController(
                title: "No Vaccines Selected",
                message: "Please select at least one vaccine to continue.",
                preferredStyle: .alert
            )
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noSelectionAlert, animated: true)
            return
        }
        
        // Create and present the custom popup
        let popupVC = VaccinePopupViewController()
        popupVC.selectedVaccines = selectedVaccines
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true)
    }
}
