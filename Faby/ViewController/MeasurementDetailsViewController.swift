import UIKit
import SwiftUI

class MeasurementDetailsViewController: UIViewController {
    @IBOutlet weak var timeSpanSegmentedControl: UISegmentedControl!

    var measurementType: String?
    var currentGrowthData: [Double] = []
    var currentTimeLabels: [String] = []
    var selectedTimeSpan: String = "Year"
    var unitSettings = UnitSettingsViewModel()
    var baby: Baby? {
        return BabyDataModel.shared.babyList.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        title = measurementType

        setupSegmentedControl()
        setupDataForTimeSpan()
        embedSwiftUIView()
    }

    private func setupSegmentedControl() {
        // Setup the segmented control for selecting the time span
        timeSpanSegmentedControl.removeAllSegments()
        let segments = ["Week", "Month", "6 Months", "Year"]
        for (index, title) in segments.enumerated() {
            timeSpanSegmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        timeSpanSegmentedControl.selectedSegmentIndex = 3 // Default to "Year"
        NSLayoutConstraint.activate([
            timeSpanSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
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

        // Setup growth data based on the measurement type
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
    }

    private func embedSwiftUIView() {
        for subview in view.subviews {
            if let hostingController = subview.next as? UIHostingController<MeasurementDetailsView> {
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
            }
        }

        // Create the SwiftUI view
        let swiftUIView = MeasurementDetailsView(
            measurementType: measurementType ?? "",
            baby: baby,
            currentGrowthData: currentGrowthData,
            currentTimeLabels: currentTimeLabels
        )
        .environmentObject(unitSettings)

        // Create the UIHostingController for the SwiftUI view
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        // Set constraints for the hosting controller's view
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: timeSpanSegmentedControl.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        hostingController.didMove(toParent: self)
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        // Handle "Add" button tap to present the measurement input view
        presentMeasurementInputView()
    }

    func presentMeasurementInputView() {
        // Define the block to save the new measurement
        let saveMeasurement: (String, Date) -> Void = { [weak self] inputMeasurement, date in
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
            }
        }

        // Present the measurement input view using a hosting controller
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
            }
        )

        let hostingController = UIHostingController(rootView: measurementInputView)
        hostingController.modalPresentationStyle = .formSheet
        present(hostingController, animated: true, completion: nil)
    }

    private func convertToBaseUnit(_ value: Double) -> Double {
        // Convert measurement to base unit based on type
        switch measurementType {
        case "Height", "Head Circumference":
            return unitSettings.selectedUnit == "inches" ? value / 0.393701 : value
        case "Weight":
            return unitSettings.weightUnit == "lbs" ? value / 2.20462 : value
        default:
            return value
        }
    }
}
