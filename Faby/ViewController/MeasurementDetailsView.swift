import SwiftUI
import Charts

import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var dataPoints: [Double]
    var timeLabels: [String]
    
    @EnvironmentObject var unitSettings: UnitSettingsViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if dataPoints.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(0..<dataPoints.count, id: \.self) { index in
                        LineMark(
                            x: .value("Time", timeLabels[index]),
                            y: .value("Measurement", dataPoints[index])
                        )
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                    }
                }
                .frame(height: 360)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitle(measurementType, displayMode: .inline)
    }
}
