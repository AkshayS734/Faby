import UIKit
import SwiftUI
import Combine
class MeasurementDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeSpanSegmentedControl: UISegmentedControl!
    var dataController: DataController {
        return DataController.shared
    }
    var measurements: [BabyMeasurement] = []
    var measurementType: String?
    var currentGrowthData: [Double] = []
    var currentTimeLabels: [String] = []
    var selectedTimeSpan: String = "Year"
    var unitSettings = UnitSettingsViewModel.shared
    var onDataChanged: (() -> Void)?
    var dataChanged: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    var baby: Baby? {
        return dataController.baby
    }
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var hostingController: UIHostingController<AnyView>?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var tableView : UITableView!
    private let latestMeasurementLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .black
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let latestMeasurementUnitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .gray
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let latestMeasurementDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .darkGray
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = measurementType
        setupScrollView()
        setupMeasurementLabels()
        embedSwiftUIView()

        DispatchQueue.main.async {
            self.setupTableView()
        }

        guard let baby = baby else { return }

        dataController.loadMeasurements(for: baby.babyID) {
            DispatchQueue.main.async {
                self.setupDataForTimeSpan()
            }
        }
        observeUnitChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dataChanged {
            guard let measurementType = measurementType else { return }
            let typeKey = measurementType == "Head Circumference" ? "head_circumference" : measurementType.lowercased()

            measurements = dataController.measurements.filter { $0.measurement_type == typeKey }
            setupDataForTimeSpan()
            updateLatestMeasurementLabel()
            
            // ✅ Update content, not view structure
            if let existingHostingController = hostingController {
                let newView = AnyView(
                    MeasurementDetailsView(
                        measurementType: measurementType,
                        dataPoints: currentGrowthData,
                        timeLabels: currentTimeLabels
                    ).environmentObject(unitSettings)
                )
                existingHostingController.rootView = newView
            }

            tableView.reloadData()
            dataChanged = false
        }
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    private func observeUnitChanges() {
        unitSettings.$selectedUnit
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateLatestMeasurementLabel()
                self.embedSwiftUIView()
                if let tableView = self.tableView {
                    tableView.reloadData()
                }
            }
            .store(in: &cancellables)
            
        unitSettings.$weightUnit
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateLatestMeasurementLabel()
                self.embedSwiftUIView()
                if let tableView = self.tableView {
                    tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    private let verticalStack = UIStackView()

    private func setupMeasurementLabels() {
        // Stack with measurement value and unit
        let topRowStack = UIStackView(arrangedSubviews: [latestMeasurementLabel, latestMeasurementUnitLabel])
        topRowStack.axis = .horizontal
        topRowStack.alignment = .lastBaseline
        topRowStack.spacing = 4

        // Full vertical stack for measurement info
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.alignment = .leading
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.addArrangedSubview(topRowStack)
        verticalStack.addArrangedSubview(latestMeasurementDateLabel)

        // Add segmented control
        contentView.addSubview(timeSpanSegmentedControl)
        timeSpanSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        timeSpanSegmentedControl.addTarget(self, action: #selector(timeSpanChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            timeSpanSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            timeSpanSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeSpanSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        contentView.addSubview(verticalStack)
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: timeSpanSegmentedControl.bottomAnchor, constant: 20),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func embedSwiftUIView() {
        let swiftUIView = AnyView(
            MeasurementDetailsView(
                measurementType: measurementType ?? "",
                dataPoints: currentGrowthData,
                timeLabels: currentTimeLabels
            )
            .environmentObject(unitSettings)
        )

        if let hostingVC = hostingController {
            hostingVC.rootView = swiftUIView
        } else {
            let hostingVC = UIHostingController(rootView: swiftUIView)
            addChild(hostingVC)
            let hostedView = hostingVC.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(hostedView)

            NSLayoutConstraint.activate([
                hostedView.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant: 20),
                hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                hostedView.heightAnchor.constraint(equalToConstant: 380)
            ])

            hostingVC.didMove(toParent: self)
            hostingController = hostingVC
        }
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
        tableView.isScrollEnabled = false // important for scrollView use

        contentView.addSubview(tableView)

        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 87)
        tableViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: hostingController?.view.bottomAnchor ?? verticalStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
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
        guard baby != nil else { return }

        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        var timeLabels: [String] = []
        var values: [Double?] = []

        switch selectedTimeSpan {
        case "Week":
            formatter.dateFormat = "EEE"
            guard let startOfWeek = calendar.date(byAdding: .day, value: -((calendar.component(.weekday, from: now) + 5) % 7), to: now) else { return }

            for i in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
                timeLabels.append(formatter.string(from: date))

                let value = measurements.first(where: { calendar.isDate($0.date, inSameDayAs: date) })?.value
                values.append(value)
            }

        case "Month":
            formatter.dateFormat = "MMM d"
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return }

            var weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!

            while weekStart <= endOfMonth {
                guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { break }

                timeLabels.append(formatter.string(from: weekStart))

                let dataInWeek = measurements
                    .filter { $0.date >= weekStart && $0.date <= weekEnd }
                    .sorted(by: { $0.date > $1.date })

                if let latest = dataInWeek.first {
                    values.append(latest.value)
                } else {
                    values.append(Double.nan)
                }

                guard let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: weekStart) else { break }
                weekStart = nextWeekStart
            }

        case "6 Months":
            formatter.dateFormat = "MMM"
            let currentMonth = calendar.component(.month, from: now)
            let year = calendar.component(.year, from: now)

            let startMonth = (currentMonth <= 6) ? 1 : 7
            for i in 0..<6 {
                let month = startMonth + i
                guard let start = calendar.date(from: DateComponents(year: year, month: month)),
                      let end = calendar.date(byAdding: .month, value: 1, to: start)?.addingTimeInterval(-1) else { continue }

                timeLabels.append(formatter.string(from: start))

                let dataInRange = measurements.filter {
                    $0.date >= start && $0.date <= end
                }

                // Use the last measurement in the range, if available
                if let lastMeasurement = dataInRange.max(by: { $0.date < $1.date }) {
                    values.append(lastMeasurement.value)
                } else {
                    values.append(nil)
                }
            }

        case "Year":
            formatter.dateFormat = "MMM"
            let year = calendar.component(.year, from: now)

            for month in 1...12 {
                guard let start = calendar.date(from: DateComponents(year: year, month: month)),
                      let end = calendar.date(byAdding: .month, value: 1, to: start)?.addingTimeInterval(-1) else { continue }

                timeLabels.append(formatter.string(from: start))

                let dataInRange = measurements.filter {
                    $0.date >= start && $0.date <= end
                }

                // Use the last measurement in the range, if available
                if let lastMeasurement = dataInRange.max(by: { $0.date < $1.date }) {
                    values.append(lastMeasurement.value)
                } else {
                    values.append(nil)
                }
            }

        default:
            return
        }

        currentTimeLabels = timeLabels
        currentGrowthData = values.map { $0 ?? Double.nan }
        updateLatestMeasurementLabel()
        embedSwiftUIView()
    }
    
    private func updateLatestMeasurementLabel() {
        guard let lastIndex = currentGrowthData.lastIndex(where: { !$0.isNaN }) else {
            latestMeasurementLabel.text = "No data"
            latestMeasurementUnitLabel.text = ""
            latestMeasurementDateLabel.text = ""
            return
        }

        let lastValue = currentGrowthData[lastIndex]
        
        let unit: String
        let convertedValue: Double
        
        if measurementType == "Weight" {
            unit = unitSettings.weightUnit
            convertedValue = convertMeasurement(value: lastValue, to: unit, isWeight: true)
        } else {
            unit = unitSettings.selectedUnit
            convertedValue = convertMeasurement(value: lastValue, to: unit, isWeight: false)
        }

        latestMeasurementLabel.text = String(format: "%.2f", convertedValue)
        latestMeasurementUnitLabel.text = unit

        if let measurement = measurements.filter({ !$0.value.isNaN })
            .sorted(by: { $0.date < $1.date })
            .last(where: { $0.value == lastValue }) {
            
            let formattedTime: String
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            formattedTime = formatter.string(from: measurement.date)
            latestMeasurementDateLabel.text = "\(formattedTime)"
        } else {
            latestMeasurementDateLabel.text = ""
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentMeasurementInputView()
    }

    func presentMeasurementInputView() {
        let measurementInputView = MeasurementInputView(
            measurementType: measurementType ?? "",
            saveMeasurement: { [weak self] measurement, date, unit in
                guard let self = self else { return }
                
                Task {
                    let convertedMeasurement: Double
                    if unit == "inches" {
                        convertedMeasurement = measurement * 2.54
                    } else if unit == "lbs" {
                        convertedMeasurement = measurement / 2.20462
                    } else {
                        convertedMeasurement = measurement
                    }
                    
                    do {
                        switch self.measurementType {
                        case "Height":
                            try await self.dataController.addHeight(convertedMeasurement, date: date)
                        case "Weight":
                            try await self.dataController.addWeight(convertedMeasurement, date: date)
                        case "Head Circumference":
                            try await self.dataController.addHeadCircumference(convertedMeasurement, date: date)
                        default:
                            break
                        }
                        
                        guard let baby = self.baby else { return }
                        self.dataController.loadMeasurements(for: baby.babyID) {
                            DispatchQueue.main.async {
                                let type = (self.measurementType == "Head Circumference") ? "head_circumference" : self.measurementType?.lowercased() ?? ""
                                self.measurements = self.dataController.measurements.filter { $0.measurement_type == type }
                                
                                self.setupDataForTimeSpan()
                                self.updateLatestMeasurementLabel()
                                self.embedSwiftUIView()
                                self.tableView.reloadData()
                            }
                        }
                        
                        self.onDataChanged?()
                        
                    } catch {
                        print("❌ Failed to save measurement:", error.localizedDescription)
                    }
                }
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
            let storyboard = UIStoryboard(name: "GrowTrack", bundle: nil)
            if let allDataVC = storyboard.instantiateViewController(withIdentifier: "MeasurementDataViewController") as? MeasurementDataViewController {
                allDataVC.measurementType = self.measurementType ?? "Height"
                allDataVC.measurements = self.measurements
                allDataVC.onDataChanged = { [weak self] in
                    guard let self = self, let measurementType = self.measurementType else { return }

                    let typeKey = measurementType == "Head Circumference" ? "head_circumference" : measurementType.lowercased()
                    self.measurements = self.dataController.measurements.filter { $0.measurement_type == typeKey }
                    self.tableView.reloadData()
                    self.onDataChanged?()
                    self.dataChanged = true
                }
                
                navigationController?.pushViewController(allDataVC, animated: true)
            }
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
