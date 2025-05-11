import UIKit
import SwiftUI

class MeasurementDataViewController: UIViewController {
    var measurements: [BabyMeasurement] = []
    var measurementType: String?
    var onDataChanged: (() -> Void)?
    var dataController: DataController {
        return DataController.shared
    }
    private var tableView: UITableView!
    private var noDataLabel: UILabel!
    private var tableViewHeightConstraint: NSLayoutConstraint?

    private var baby: Baby? {
        return dataController.baby
    }
    func dataWasUpdated() {
        onDataChanged?()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupNoDataLabel()
        setupTableView()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let measurementType = measurementType else {
            print("❌ Measurement type not set")
            return
        }
        title = "\(measurementType.capitalized) Data"
        updateUI()
    }
    
    private func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "No data"
        noDataLabel.textColor = .darkGray
        noDataLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        noDataLabel.textAlignment = .center
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)

        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(MeasurementDataTableViewCell.self, forCellReuseIdentifier: "DataCell")
        tableView.allowsSelectionDuringEditing = true
        tableView.sectionHeaderHeight = 0
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)

//        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            tableViewHeightConstraint!
        ])
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEditMode)
        )
    }

    @objc private func toggleEditMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        navigationItem.rightBarButtonItem?.title = tableView.isEditing ? "Done" : "Edit"
    }

    private func updateUI() {
        let dataCount = dataCountForSelectedMeasurementType()

        if dataCount == 0 {
            noDataLabel.isHidden = false
            tableView.isHidden = true
            tableViewHeightConstraint?.constant = 0
        } else {
            noDataLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.tableView.layoutIfNeeded()
                self.tableViewHeightConstraint?.constant = self.tableView.contentSize.height
            }
        }
    }

    private func unitForMeasurementType() -> String {
        switch measurementType {
        case "Height", "Head Circumference": return "cm"
        case "Weight": return "kg"
        default: return ""
        }
    }

    private func dataCountForSelectedMeasurementType() -> Int {
        return measurements.count
    }

    private func deleteEntry(at index: Int) {
        guard index < measurements.count else { return }
        let measurement = measurements.sorted { $0.date > $1.date }[index]

        Task {
            do {
                try await dataController.deleteMeasurement(id: measurement.id)
                print(measurement.id)
                if let idx = measurements.firstIndex(where: { $0.id == measurement.id }) {
                    print("Inside : \(idx)")
                    measurements.remove(at: idx)
                }
                onDataChanged?()
                tableView.reloadData()
                updateUI()
            } catch {
                print("❌ Failed to delete measurement:", error.localizedDescription)
            }
        }
    }
}

extension MeasurementDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCountForSelectedMeasurementType()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? MeasurementDataTableViewCell else {
            return UITableViewCell()
        }

        let unit = unitForMeasurementType()

        let sortedMeasurements = measurements.sorted(by: { $0.date > $1.date })

        if indexPath.row < sortedMeasurements.count {
            let measurement = sortedMeasurements[indexPath.row]
            cell.configure(value: measurement.value, unit: unit, date: measurement.date)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == measurements.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.width)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEntry(at: indexPath.row)
        }
    }
}
