import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var baby: Baby?
    var currentGrowthData: [Double]
    var currentTimeLabels: [String]

    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var body: some View {
        VStack {
            if currentGrowthData.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                if let latestMeasurement = currentGrowthData.last {
                    Text("\(convertValue(latestMeasurement), specifier: "%.2f") \(unitLabel())")
                        .font(.title2)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Chart {
                    ForEach(0..<currentGrowthData.count, id: \.self) { index in
                        LineMark(
                            x: .value("Time", currentTimeLabels[index]),
                            y: .value("Measurement", convertValue(currentGrowthData[index]))
                        )
                        .foregroundStyle(Color.blue)
                        .symbol(Circle())
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
        .navigationBarTitle("\(measurementType)", displayMode: .inline)
    }

    /// Returns the appropriate unit label based on the measurement type
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
