import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var baby: Baby?
    
    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var currentGrowthData: [Double] {
        guard let baby = baby else { return [] }
        switch measurementType {
        case "Height":
            return baby.height.keys.sorted().map { convertValue($0) }
        case "Weight":
            return baby.weight.keys.sorted().map { convertValue($0) }
        case "Head Circumference":
            return baby.headCircumference.keys.sorted().map { convertValue($0) }
        default:
            return []
        }
    }

    var currentTimeLabels: [String] {
        guard let baby = baby else { return [] }
        switch measurementType {
        case "Height":
            return baby.height.values.sorted().map { $0.formattedDate() }
        case "Weight":
            return baby.weight.values.sorted().map { $0.formattedDate() }
        case "Head Circumference":
            return baby.headCircumference.values.sorted().map { $0.formattedDate() }
        default:
            return []
        }
    }

    var body: some View {
        VStack {
            if currentGrowthData.isEmpty {
                Text("No data available")
                    .foregroundColor(Color(UIColor.darkGray))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(0..<currentGrowthData.count, id: \.self) { index in
                        LineMark(
                            x: .value("Time", currentTimeLabels[index]),
                            y: .value("Measurement", currentGrowthData[index])
                        )
                        .foregroundStyle(Color.blue)
                        .symbol(Circle())
                    }
                }
                .frame(height: 300)
                .padding(.top, 20)
                .background(Color.white)
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitle("\(measurementType)", displayMode: .inline)
    }

    private func unitLabel() -> String {
        switch measurementType {
        case "Height", "Head Circumference":
            return unitSettings.selectedUnit
        case "Weight":
            return unitSettings.weightUnit
        default:
            return ""
        }
    }

    private func convertValue(_ value: Double) -> Double {
        switch measurementType {
        case "Height", "Head Circumference":
            return unitSettings.selectedUnit == "inches" ? value * 0.393701 : value
        case "Weight":
            return unitSettings.weightUnit == "lbs" ? value * 2.20462 : value
        default:
            return value
        }
    }
}

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
