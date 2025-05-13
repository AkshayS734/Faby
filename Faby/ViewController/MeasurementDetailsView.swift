import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var dataPoints: [Double]
    var timeLabels: [String]
    
    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var body: some View {
        VStack {
            if dataPoints.isEmpty {
                Text("No data available")
                    .foregroundColor(Color(UIColor.darkGray))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(0..<dataPoints.count, id: \.self) { index in
                        LineMark(
                            x: .value("Time", timeLabels[index]),
                            y: .value("Measurement", dataPoints[index])
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
}

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
