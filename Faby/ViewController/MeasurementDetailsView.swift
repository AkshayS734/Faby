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
                .frame(height: 400)
                .padding(.top, 20)
                .background(Color.white)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                List {
                    NavigationLink(destination: AllDataView(baby: baby)) {
                        Text("Show All Data")
                            .foregroundColor(.black)
                            .onAppear { print("Show All Data Link Appeared") }
                    }

                    NavigationLink(destination: UnitSettingsView()) {
                        Text("Change Units")
                            .foregroundColor(.black)
                            .onAppear { print("Change Units Link Appeared") }
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, maxHeight: 88)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitle("\(measurementType)", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
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
