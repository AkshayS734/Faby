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

        switch measurementType {
        case "Height":
            if selectedTimeSpan == "Week" {
                currentGrowthData = [50, 51, 52, 53]
                currentTimeLabels = ["Mon", "Tue", "Wed", "Thu"]
            } else if selectedTimeSpan == "Month" {
                currentGrowthData = [50, 51, 52, 53, 54]
                currentTimeLabels = ["W1", "W2", "W3", "W4", "W5"]
            } else if selectedTimeSpan == "6 Months" {
                currentGrowthData = [50, 55, 60, 62, 65]
                currentTimeLabels = ["0M", "1M", "3M", "5M", "6M"]
            } else { // Year
                currentGrowthData = [50, 55, 60, 62, 65]
                currentTimeLabels = ["0M", "6M", "12M", "18M", "24M"]
            }
        case "Weight":
            if selectedTimeSpan == "Week" {
                currentGrowthData = [3.5, 4.0, 4.5, 5.0]
                currentTimeLabels = ["Mon", "Tue", "Wed", "Thu"]
            } else if selectedTimeSpan == "Month" {
                currentGrowthData = [3.5, 4.0, 5.0, 6.0, 7.0]
                currentTimeLabels = ["W1", "W2", "W3", "W4", "W5"]
            } else if selectedTimeSpan == "6 Months" {
                currentGrowthData = [3.5, 4.5, 5.5, 6.5, 7.5]
                currentTimeLabels = ["0M", "1M", "3M", "5M", "6M"]
            } else { // Year
                currentGrowthData = [3.5, 4.5, 5.5, 6.5, 7.5]
                currentTimeLabels = ["0M", "6M", "12M", "18M", "24M"]
            }
        case "Head Circumference":
            if selectedTimeSpan == "Week" {
                currentGrowthData = [35, 36, 37, 38]
                currentTimeLabels = ["Mon", "Tue", "Wed", "Thu"]
            } else if selectedTimeSpan == "Month" {
                currentGrowthData = [35, 36, 37, 38, 39]
                currentTimeLabels = ["W1", "W2", "W3", "W4", "W5"]
            } else if selectedTimeSpan == "6 Months" {
                currentGrowthData = [35, 37, 39, 40, 41]
                currentTimeLabels = ["0M", "1M", "3M", "5M", "6M"]
            } else { // Year
                currentGrowthData = [35, 37, 39, 40, 41]
                currentTimeLabels = ["0M", "6M", "12M", "18M", "24M"]
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
    
        let swiftUIView = MeasurementDetailsView(
            measurementType: measurementType,
            growthData: currentGrowthData,
            timeLabels: currentTimeLabels,
            timeSpan: selectedTimeSpan
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
        let measurementInputView = MeasurementInputView(measurementType: measurementType ?? "")
        let hostingController = UIHostingController(rootView: measurementInputView)
        
        hostingController.modalPresentationStyle = .formSheet
        present(hostingController, animated: true, completion: nil)
    }
    
}
