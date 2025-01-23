import SwiftUI
import Charts

struct MeasurementDetailsView: View {
    var measurementType: String
    var baby: Baby?
    @State private var currentGrowthData: [Double] = []
    @State private var currentTimeLabels: [String] = []

    @EnvironmentObject var unitSettings: UnitSettingsViewModel

    var body: some View {
        VStack {
            if currentGrowthData.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .center)
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
                .padding(.top, 20)
                .background(Color.white)
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                List {
                    NavigationLink(
                        destination: AllDataView(
                            baby: baby,
                            measurementType: measurementType,
                            onDataChanged: updateGrowthData
                        )
                    ) {
                        Text("Show All Data")
                            .foregroundColor(.black)
                    }

                    NavigationLink(destination: UnitSettingsView()) {
                        Text("Change Units")
                            .foregroundColor(.black)
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: 88)
            .padding(.bottom, 80)
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitle("\(measurementType)", displayMode: .inline)
        .onAppear {
            updateGrowthData()
        }
    }

    private func updateGrowthData() {
        guard let baby = baby else { return }
        switch measurementType {
        case "Height":
            currentGrowthData = baby.height.sorted(by: { $0.value < $1.value }).map { $0.key }
            currentTimeLabels = baby.height.sorted(by: { $0.value < $1.value }).map { $0.value.formattedDate() }
        case "Weight":
            currentGrowthData = baby.weight.sorted(by: { $0.value < $1.value }).map { $0.key }
            currentTimeLabels = baby.weight.sorted(by: { $0.value < $1.value }).map { $0.value.formattedDate() }
        case "Head Circumference":
            currentGrowthData = baby.headCircumference.sorted(by: { $0.value < $1.value }).map { $0.key }
            currentTimeLabels = baby.headCircumference.sorted(by: { $0.value < $1.value }).map { $0.value.formattedDate() }
        default:
            break
        }
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
