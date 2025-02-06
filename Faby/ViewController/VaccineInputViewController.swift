import UIKit

class VaccineInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let vaccineManager = VaccineManager.shared

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark the vaccines your child has received"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.title = "VacciTime"
        view.backgroundColor = .white

        vaccineManager.loadSelectedVaccines()
        
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

    // MARK: - UITableViewDataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return vaccineManager.vaccineData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccineManager.vaccineData[section].vaccines.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vaccineCell", for: indexPath)
        cell.textLabel?.text = vaccineManager.vaccineData[indexPath.section].vaccines[indexPath.row]
        let vaccine = vaccineManager.vaccineData[indexPath.section].vaccines[indexPath.row]
        cell.accessoryType = vaccineManager.selectedVaccines.contains(vaccine) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vaccineManager.vaccineData[section].stageTitle
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVaccine = vaccineManager.vaccineData[indexPath.section].vaccines[indexPath.row]
        if let index = vaccineManager.selectedVaccines.firstIndex(of: selectedVaccine) {
            vaccineManager.selectedVaccines.remove(at: index)
        } else {
            vaccineManager.selectedVaccines.append(selectedVaccine)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Continue Button

    @objc private func continueButtonTapped() {
        if vaccineManager.selectedVaccines.isEmpty {
            let noSelectionAlert = UIAlertController(
                title: "No Vaccines Selected",
                message: "Please select at least one vaccine to continue.",
                preferredStyle: .alert
            )
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noSelectionAlert, animated: true)
            return
        }

        vaccineManager.saveSelectedVaccines()

        let confirmationAlert = UIAlertController(
            title: "Vaccines Selected",
            message: "You have selected the following vaccines:\n\n\(vaccineManager.selectedVaccines.joined(separator: "\n"))",
            preferredStyle: .alert
        )

        // Add "Cancel" button
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Add "OK" button
        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let vacciAlertVC = VacciAlertViewController()
            vacciAlertVC.selectedVaccines = self.vaccineManager.selectedVaccines
            self.navigationController?.pushViewController(vacciAlertVC, animated: true)
        })

        present(confirmationAlert, animated: true)
    }
}
