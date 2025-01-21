import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var baby: Baby?
    var currentGrowthData: [Double]  // Data passed from the ViewController
    var currentTimeLabels: [String] // Labels for the current time span

    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var body: some View {
        VStack {
            if currentGrowthData.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Display the latest measurement
                if let latestMeasurement = currentGrowthData.last {
                    Text("\(latestMeasurement, specifier: "%.2f") \(unitSettings.selectedUnit)")
                        .font(.title2)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

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
                .padding()
            }
        }
        .navigationBarTitle("\(measurementType)", displayMode: .inline)
    }
}
