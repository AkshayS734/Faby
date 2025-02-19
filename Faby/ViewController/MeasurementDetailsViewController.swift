import UIKit
import SwiftUI
import Combine
class MeasurementDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeSpanSegmentedControl: UISegmentedControl!
    
    var measurementType: String?
    var currentGrowthData: [Double] = []
    var currentTimeLabels: [String] = []
    var selectedTimeSpan: String = "Year"
    var unitSettings = UnitSettingsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    var baby: Baby? {
        return BabyDataModel.shared.babyList.first
    }
    private var hostingController: UIHostingController<AnyView>?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var tableView : UITableView!
    private let latestMeasurementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let latestMeasurementUnitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = measurementType
        
        setupMeasurementLabels()
        embedSwiftUIView()
        setupTableView()
        setupDataForTimeSpan()
    }
    private func observeUnitChanges() {
        unitSettings.$selectedUnit
            .sink { [weak self] _ in
                self?.updateLatestMeasurementLabel()
                self?.embedSwiftUIView()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
            
        unitSettings.$weightUnit
            .sink { [weak self] _ in
                self?.updateLatestMeasurementLabel()
                self?.embedSwiftUIView()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupMeasurementLabels() {
        let stackView = UIStackView(arrangedSubviews: [latestMeasurementLabel, latestMeasurementUnitLabel])
        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: timeSpanSegmentedControl.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func embedSwiftUIView() {
        let swiftUIView = AnyView(
            MeasurementDetailsView(measurementType: measurementType ?? "", baby: baby)
                .environmentObject(unitSettings)
        )

        let hostingVC = UIHostingController(rootView: swiftUIView)

        if let oldHostingController = hostingController {
            oldHostingController.willMove(toParent: nil)
            oldHostingController.view.removeFromSuperview()
            oldHostingController.removeFromParent()
        }

        addChild(hostingVC)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingVC.view)

        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: latestMeasurementUnitLabel.bottomAnchor, constant: 7),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hostingVC.view.heightAnchor.constraint(equalToConstant: 356),
        ])

        hostingVC.didMove(toParent: self)
        hostingController = hostingVC
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 12
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.register(MeasurementDataTableViewCell.self, forCellReuseIdentifier: "DataCell")
        tableView.allowsSelectionDuringEditing = true
        tableView.sectionHeaderHeight = 0
        tableView.isScrollEnabled = false

        view.addSubview(tableView)

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 87)
        tableViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: hostingController?.view.bottomAnchor ?? latestMeasurementUnitLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -115)
        ])
    }
    
    @IBAction func timeSpanChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedTimeSpan = "Week"
        case 1: selectedTimeSpan = "Month"
        case 2: selectedTimeSpan = "6 Months"
        case 3: selectedTimeSpan = "Year"
        default: selectedTimeSpan = "Year"
        }
        setupDataForTimeSpan()
        embedSwiftUIView()
    }
    
    private func setupDataForTimeSpan() {
        guard let baby = baby else { return }
        
        switch measurementType {
        case "Height":
            currentGrowthData = Array(baby.height.keys).sorted()
            currentTimeLabels = Array(baby.height.values).map {
                DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
            }
        case "Weight":
            currentGrowthData = Array(baby.weight.keys).sorted()
            currentTimeLabels = Array(baby.weight.values).map {
                DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
            }
        case "Head Circumference":
            currentGrowthData = Array(baby.headCircumference.keys).sorted()
            currentTimeLabels = Array(baby.headCircumference.values).map {
                DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
            }
        default:
            break
        }
        updateLatestMeasurementLabel()
    }
    
    private func updateLatestMeasurementLabel() {
        guard let lastMeasurement = currentGrowthData.last else {
            latestMeasurementLabel.text = ""
            latestMeasurementUnitLabel.text = ""
            return
        }
            
        let unit: String
        let convertedValue: Double
            
        if measurementType == "Weight" {
            unit = unitSettings.weightUnit
            convertedValue = convertMeasurement(value: lastMeasurement, to: unit, isWeight: true)
        } else {
            unit = unitSettings.selectedUnit
            convertedValue = convertMeasurement(value: lastMeasurement, to: unit, isWeight: false)
        }
            
        latestMeasurementLabel.text = String(format: "%.2f", convertedValue)
        latestMeasurementUnitLabel.text = "\(unit)"
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentMeasurementInputView()
    }
    
    func presentMeasurementInputView() {
        let _: (String, Date) -> Void = { [weak self] inputMeasurement, date in
            guard let self = self, let baby = self.baby else { return }
            if let measurement = Double(inputMeasurement) {
                let convertedMeasurement = self.convertToBaseUnit(measurement)
                switch self.measurementType {
                case "Height":
                    baby.updateHeight(convertedMeasurement, date: date)
                case "Weight":
                    baby.updateWeight(convertedMeasurement, date: date)
                case "Head Circumference":
                    baby.updateHeadCircumference(convertedMeasurement, date: date)
                default:
                    break
                }
                self.setupDataForTimeSpan()
                self.embedSwiftUIView()
                self.updateLatestMeasurementLabel()
            }
        }
        
        let measurementInputView = MeasurementInputView(
            measurementType: measurementType ?? "",
            saveMeasurement: { measurement, date, unit in
                let convertedMeasurement: Double
                if unit == "inches" {
                    convertedMeasurement = measurement * 2.54
                } else if unit == "lbs" {
                    convertedMeasurement = measurement / 2.20462
                } else {
                    convertedMeasurement = measurement
                }
                
                switch self.measurementType {
                case "Height":
                    self.baby?.updateHeight(convertedMeasurement, date: date)
                case "Weight":
                    self.baby?.updateWeight(convertedMeasurement, date: date)
                case "Head Circumference":
                    self.baby?.updateHeadCircumference(convertedMeasurement, date: date)
                default:
                    break
                }
                
                self.setupDataForTimeSpan()
                self.embedSwiftUIView()
                self.updateLatestMeasurementLabel()
            }
        )
        
        let hostingController = UIHostingController(rootView: measurementInputView)
        hostingController.modalPresentationStyle = .formSheet
        present(hostingController, animated: true, completion: nil)
    }
    
    private func convertToBaseUnit(_ value: Double) -> Double {
        switch measurementType {
        case "Height", "Head Circumference":
            return unitSettings.selectedUnit == "inches" ? value / 0.393701 : value
        case "Weight":
            return unitSettings.weightUnit == "lbs" ? value / 2.20462 : value
        default:
            return value
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Show All Data"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Unit"
            if measurementType == "Weight" {
                cell.detailTextLabel?.text = unitSettings.weightUnit
            } else {
                cell.detailTextLabel?.text = unitSettings.selectedUnit
            }
            cell.detailTextLabel?.textColor = .gray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let allDataVC = MeasurementDataViewController(
                measurementType: measurementType ?? "Height",
                baby: baby,
                onDataChanged: { [weak self] in
                    self?.reloadChartView()
                }
            )
            navigationController?.pushViewController(allDataVC, animated: true)
        } else if indexPath.row == 1 {
            let unitSettingsVC = UnitSettingsViewController(measurementType: measurementType ?? "Height") { [weak self] newUnit in
                if self?.measurementType == "Weight" {
                    self?.unitSettings.weightUnit = newUnit
                } else {
                    self?.unitSettings.selectedUnit = newUnit
                }
                self?.tableView.reloadData()
                self?.updateLatestMeasurementLabel()
            }
            navigationController?.pushViewController(unitSettingsVC, animated: true)
        }
    }
    private func reloadChartView() {
        setupDataForTimeSpan()
        embedSwiftUIView()
        updateLatestMeasurementLabel()
        tableView.reloadData()
    }
    
    private func convertMeasurement(value: Double, to unit: String, isWeight: Bool) -> Double {
        if isWeight {
            return unit == "lbs" ? value * 2.205 : value
        } else {
            return unit == "inches" ? value / 2.54 : value
        }
    }
}

