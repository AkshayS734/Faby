import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var growthData: [Double]
    var timeLabels: [String]
    var timeSpan: String
    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var body: some View {
        VStack {
            if let latestMeasurement = growthData.last {
                Text("\(latestMeasurement, specifier: "%.f") \(unitSettings.selectedUnit)")
                    .font(.title2)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Chart {
                ForEach(0..<growthData.count, id: \.self) { index in
                    LineMark(
                        x: .value("Time", timeLabels[index]),
                        y: .value("Measurement", growthData[index])
                    )
                    .foregroundStyle(Color.blue)
                    .symbol(Circle())
                }
            }
            .frame(height: 300)
            .padding()
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            
            
            .padding(.top)
        }
        .navigationBarTitle("\(measurementType)", displayMode: .inline)  // Title for navigation bar
        .onChange(of: unitSettings.isUnitChanged) { _ in
            reloadGraphData()
        }
    }

    func reloadGraphData() {
        if unitSettings.isUnitChanged {
            print("Unit changed: \(unitSettings.selectedUnit) for \(measurementType)")
        }
    }
}
