import UIKit
import SwiftUI
class UnitSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var measurementType: String
    var onUnitChanged: ((String) -> Void)?
    
    private let tableView = UITableView()
    
    private let heightOptions = ["cm", "inches"]
    private let weightOptions = ["kg", "lbs"]
    
    init(measurementType: String, onUnitChanged: @escaping (String) -> Void) {
        self.measurementType = measurementType
        self.onUnitChanged = onUnitChanged
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        title = "Change Units"
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = false
        tableView.sectionHeaderHeight = 0
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 86)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        let viewModel = UnitSettingsViewModel.shared
        let options = (measurementType == "Weight") ? weightOptions : heightOptions
        let unit = options[indexPath.row]
        cell.textLabel?.text = unit
        cell.accessoryType = (unit == (measurementType == "Weight" ? viewModel.weightUnit : viewModel.selectedUnit)) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = UnitSettingsViewModel.shared
        let options = (measurementType == "Weight") ? weightOptions : heightOptions
        let newUnit = options[indexPath.row]

        if measurementType == "Weight" {
            viewModel.weightUnit = newUnit
        } else {
            viewModel.selectedUnit = newUnit
        }
        
        viewModel.isUnitChanged = true
        onUnitChanged?(newUnit)
        
        tableView.reloadData()
        
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.05, animations: {
                cell.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    cell.backgroundColor = .white
                }
            }
        }
    }
}

struct UnitSettingsView: UIViewControllerRepresentable {
    var measurementType: String
    var onUnitChanged: (String) -> Void

    func makeUIViewController(context: Context) -> UnitSettingsViewController {
        return UnitSettingsViewController(measurementType: measurementType, onUnitChanged: onUnitChanged)
    }

    func updateUIViewController(_ uiViewController: UnitSettingsViewController, context: Context) {}
}
