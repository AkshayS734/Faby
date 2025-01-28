import UIKit

class VaccineInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark the vaccines your child has received"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let vaccineData: [(sectionTitle: String, vaccines: [String])] = [
        ("Birth", ["Hepatitis B (Dose 1)"]),
        ("6 weeks", ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        ("10 weeks", ["DTaP (Dose 2)", "Hib (Dose 2)", "Rotavirus (Dose 1)", "Pneumococcal (Dose 1)"]),
        ("14 weeks", ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)", "Rotavirus (Dose 2)", "Pneumococcal (Dose 2)"]),
        ("6 Months", ["Hepatitis B (Dose 3)"]),
        ("9 months", ["MMR (Dose 1)"]),
        ("12 months", ["Hepatitis A (Dose 1)", "Varicella (Dose 1)"])
    ]

    var selectedVaccines: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.title = "VacciTime"
        view.backgroundColor = .white

        view.addSubview(instructionsLabel)
        configureTableView()
        configureButtons()

        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "vaccineCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }

    private func configureButtons() {
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.layer.cornerRadius = 10
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        view.addSubview(continueButton)

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func storeVaccinationDetails(vaccines: [String]) {
        var existingData = UserDefaults.standard.array(forKey: "SavedVaccines") as? [String] ?? []
        existingData.append(contentsOf: vaccines)
        existingData = Array(Set(existingData))
        UserDefaults.standard.set(existingData, forKey: "SavedVaccines")
        UserDefaults.standard.synchronize()
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
        let vaccine = vaccineData[indexPath.section].vaccines[indexPath.row]
        cell.accessoryType = selectedVaccines.contains(vaccine) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vaccineData[section].sectionTitle
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVaccine = vaccineData[indexPath.section].vaccines[indexPath.row]
        if let index = selectedVaccines.firstIndex(of: selectedVaccine) {
            selectedVaccines.remove(at: index)
        } else {
            selectedVaccines.append(selectedVaccine)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Continue Button

    @objc private func continueButtonTapped() {
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

        storeVaccinationDetails(vaccines: selectedVaccines)

        let confirmationAlert = UIAlertController(
            title: "Vaccines Selected",
            message: "You have selected the following vaccines:\n\n\(selectedVaccines.joined(separator: "\n"))",
            preferredStyle: .alert
        )

        // Add "Cancel" button (left position)
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Add "OK" button (right position)
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let vacciAlertVC = VacciAlertViewController()
            vacciAlertVC.selectedVaccines = self.selectedVaccines
            self.navigationController?.pushViewController(vacciAlertVC, animated: true)
        })

        present(confirmationAlert, animated: true)
    }
}
