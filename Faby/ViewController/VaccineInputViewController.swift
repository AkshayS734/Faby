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
        self.title = "VacciTime"
        view.backgroundColor = .white
        
        // Add the label to the view
        view.addSubview(instructionsLabel)
        
        // Configure the table view
        configureTableView()
        
        // Configure the "Continue" button
        configureContinueButton()
        
        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        UserDefaults.standard.removeObject(forKey: "SavedVaccines") // Clear old data for testing
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
    private func storeVaccinationDetails(vaccines: [String]) {
        print("Attempting to save vaccines: \(vaccines)")
        
        var existingData = UserDefaults.standard.array(forKey: "SavedVaccines") as? [String] ?? []
        print("Existing data before saving: \(existingData)")
        
        // Append new vaccines and remove duplicates
        existingData.append(contentsOf: vaccines)
        existingData = Array(Set(existingData)) // Remove duplicates
        
        // Save to UserDefaults
        UserDefaults.standard.set(existingData, forKey: "SavedVaccines")
        UserDefaults.standard.synchronize()
        
        // Debug UserDefaults
        print("All UserDefaults after saving: \(UserDefaults.standard.dictionaryRepresentation())")
        print("Saved to UserDefaults: \(existingData)")
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
        print("Continue button tapped. Selected vaccines: \(selectedVaccines)")
        
        if selectedVaccines.isEmpty {
            let noSelectionAlert = UIAlertController(
                title: "No Vaccines Selected",
                message: "Please select at least one vaccine to continue.",
                preferredStyle: .alert
            )
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noSelectionAlert, animated: true)
            return
        }
        
        // Save vaccines
        storeVaccinationDetails(vaccines: selectedVaccines)
        
        // Show confirmation alert
        let confirmationAlert = UIAlertController(
            title: "Vaccines Selected",
            message: "You have selected the following vaccines:\n\n\(selectedVaccines.joined(separator: "\n"))",
            preferredStyle: .alert
        )
        
        // Add an "OK" action to navigate to VacciAlertViewController
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let vacciAlertVC = VacciAlertViewController()
            vacciAlertVC.selectedVaccines = self.selectedVaccines
            self.navigationController?.pushViewController(vacciAlertVC, animated: true)
        }
        confirmationAlert.addAction(okAction)
        
        // Present the confirmation alert
        present(confirmationAlert, animated: true)
    }
}
