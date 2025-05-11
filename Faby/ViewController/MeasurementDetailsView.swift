import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var measurements: [BabyMeasurement]
    
    @EnvironmentObject var unitSettings: UnitSettingsViewModel
    
    var currentGrowthData: [Double] {
        let sorted = measurements.sorted(by: { $0.date < $1.date })
        return sorted.map { convertValue($0.value) }
    }
    
    var currentTimeLabels: [String] {
        let sorted = measurements.sorted(by: { $0.date < $1.date })
        return sorted.map { $0.date.formattedDate() }
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
