import UIKit
import SwiftUI

class MeasurementDetailsViewController: UIViewController {
    @IBOutlet weak var timeSpanSegmentedControl: UISegmentedControl!
    
    var measurementType: String?
    var currentGrowthData: [Double] = []
    var currentTimeLabels: [String] = []
    var selectedTimeSpan: String = "Year"
    var selectedHeightUnit: String = "cm"
    var selectedWeightUnit: String = "kg"
    var isUnitChanged: Bool = false
    
    var unitSettings = UnitSettingsViewModel()
    var baby: Baby? {
        return BabyDataModel.shared.babyList.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = measurementType
        
        configureSegmentedControl()
        setupDataForTimeSpan()
        embedSwiftUIView()
    }
    
    private func configureSegmentedControl() {
        timeSpanSegmentedControl.removeAllSegments()
        let segments = ["Week", "Month", "6 Months", "Year"]
        for (index, title) in segments.enumerated() {
            timeSpanSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        timeSpanSegmentedControl.selectedSegmentIndex = 3
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
        guard let measurementType = measurementType, let baby = baby else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeSpan {
        case "Week":
            let startOfWeek = calendar.date(byAdding: .day, value: -6, to: today)!
            filterData(from: startOfWeek, to: today)
            
        case "Month":
            let startOfMonth = calendar.date(byAdding: .month, value: -1, to: today)!
            filterData(from: startOfMonth, to: today)
            
        case "6 Months":
            let startOfSixMonths = calendar.date(byAdding: .month, value: -6, to: today)!
            filterData(from: startOfSixMonths, to: today)
            
        case "Year":
            let startOfYear = calendar.date(byAdding: .year, value: -1, to: today)!
            filterData(from: startOfYear, to: today)
            
        default:
            filterData(from: .distantPast, to: today)
        }
        
        if isUnitChanged {
            convertDataToSelectedUnits()
        }
    }
    
    private func filterData(from startDate: Date, to endDate: Date) {
        guard let baby = baby else { return }
        
        var allData: [Double: Date] = [:]
        switch measurementType {
        case "Height":
            allData = baby.height
        case "Weight":
            allData = baby.weight
        case "Head Circumference":
            allData = baby.headCircumference
        default:
            break
        }
        
        let filteredData = allData.filter { $0.value >= startDate && $0.value <= endDate }
        currentGrowthData = filteredData.keys.sorted()
        currentTimeLabels = filteredData.values.sorted().map {
            DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
        }
    }
    
    private func convertDataToSelectedUnits() {
        if selectedHeightUnit == "inches" {
            currentGrowthData = currentGrowthData.map { $0 * 0.393701 }
        } else if selectedHeightUnit == "cm" {
            currentGrowthData = currentGrowthData.map { $0 / 0.393701 }
        }
        
        if selectedWeightUnit == "lbs" {
            currentGrowthData = currentGrowthData.map { $0 * 2.20462 }
        } else if selectedWeightUnit == "kg" {
            currentGrowthData = currentGrowthData.map { $0 / 2.20462 }
        }
        isUnitChanged = false
    }
    
    private func embedSwiftUIView() {
        guard let measurementType = measurementType else { return }
        
        for subview in view.subviews {
            if let hostingController = subview.next as? UIHostingController<MeasurementDetailsView> {
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
            }
        }
        let baby = self.baby
        let swiftUIView = MeasurementDetailsView(
            measurementType: measurementType,
            baby: baby,
            currentGrowthData: currentGrowthData,
            currentTimeLabels: currentTimeLabels
        )
        .environmentObject(unitSettings)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: timeSpanSegmentedControl.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentMeasurementInputView()
    }
    
    private func presentMeasurementInputView() {
        let saveMeasurement: (String, Date) -> Void = { [weak self] inputMeasurement, date in
            guard let self = self, let baby = self.baby else { return }
            
            if let measurement = Double(inputMeasurement) {
                switch self.measurementType {
                case "Height":
                    baby.updateHeight(measurement, date: date)
                case "Weight":
                    baby.updateWeight(measurement, date: date)
                case "Head Circumference":
                    baby.updateHeadCircumference(measurement, date: date)
                default:
                    break
                }
            }
        }
        
        let measurementInputView = MeasurementInputView(
            measurementType: measurementType ?? "",
            saveMeasurement: saveMeasurement
        )
        let hostingController = UIHostingController(rootView: measurementInputView)
        hostingController.modalPresentationStyle = .formSheet
        present(hostingController, animated: true, completion: nil)
    }
}
