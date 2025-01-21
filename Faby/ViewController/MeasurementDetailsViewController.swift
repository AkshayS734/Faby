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
        print("\(measurementType!)")
        title = measurementType
        
        timeSpanSegmentedControl.removeAllSegments()
        let segments = ["Week", "Month", "6 Months", "Year"]
        for (index, title) in segments.enumerated() {
            timeSpanSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
        timeSpanSegmentedControl.selectedSegmentIndex = 3
        setupDataForTimeSpan()
        embedSwiftUIView()
        
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
        guard let measurementType = measurementType else { return }
        guard let baby = BabyDataModel.shared.babyList.first else { return }
        
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
        
        if isUnitChanged {
            convertDataToSelectedUnits()
        }
    }
    private func convertDataToSelectedUnits() {
            // Conversion logic if necessary
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
        let baby = BabyDataModel.shared.babyList.first
        let swiftUIView = MeasurementDetailsView(
            measurementType: measurementType,
            baby: baby
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
    func presentMeasurementInputView() {
        let saveMeasurement: (String, Date) -> Void = { [weak self] inputMeasurement, date in
            guard let self = self, let baby = self.baby else { return }
                    
                    // Convert the input measurement to Double
            if let measurement = Double(inputMeasurement) {
                        // Update the corresponding measurement for the Baby object
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
                        
                        // You can reload data here if necessary
            }
        }
                
                // Create the MeasurementInputView with the closure for saving the measurement
        let measurementInputView = MeasurementInputView(
            measurementType: measurementType ?? "",
            saveMeasurement: saveMeasurement
        )
                
        let hostingController = UIHostingController(rootView: measurementInputView)
        hostingController.modalPresentationStyle = .formSheet
        present(hostingController, animated: true, completion: nil)
    }
    
}
