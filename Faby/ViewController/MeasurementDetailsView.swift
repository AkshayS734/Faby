import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var baby: Baby?

    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var growthData: [Double] {
        guard let baby = baby else { return [] }
        switch measurementType {
        case "Height":
            return baby.height.keys.sorted(by: { baby.height[$0]! < baby.height[$1]! })
        case "Weight":
            return baby.weight.keys.sorted(by: { baby.weight[$0]! < baby.weight[$1]! })
        case "Head Circumference":
            return baby.headCircumference.keys.sorted(by: { baby.headCircumference[$0]! < baby.headCircumference[$1]! })
        default:
            return []
        }
    }

    var timeLabels: [String] {
        guard let baby = baby else { return [] }
        let dates = growthData.compactMap {
            switch measurementType {
            case "Height":
                return baby.height[$0]
            case "Weight":
                return baby.weight[$0]
            case "Head Circumference":
                return baby.headCircumference[$0]
            default:
                return nil
            }
        }
        return dates.map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none) }
    }

    var body: some View {
        if let baby = baby {
            VStack {
                if growthData.isEmpty {
                    Text("No data available for \(baby.name)")
                        .foregroundColor(.gray)
                } else {
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
                }
            }
            .navigationBarTitle("\(measurementType)", displayMode: .inline)
        } else {
            Text("No baby data available.")
                .foregroundColor(.red)
                .padding()
        }
    }
}
