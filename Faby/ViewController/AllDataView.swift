import SwiftUI

struct AllDataView: View {
    var baby: Baby?
    var measurementType: String
    var onDataChanged: (() -> Void)?
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading) {
            if let baby = baby , dataCountForSelectedMeasurementType() > 0 {
                Text("\(unitForMeasurementType())".uppercased())
                    .font(.caption)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                List {
                    switch measurementType {
                    case "Height":
                        ForEach(0..<baby.height.count, id: \.self) { index in
                            HStack {
                                Text("\(baby.height.keys.sorted()[index], specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(baby.height.values.sorted()[index], formatter: DateFormatter.shortDateFormatter)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteHeight)

                    case "Weight":
                        ForEach(0..<baby.weight.count, id: \.self) { index in
                            HStack {
                                Text("\(baby.weight.keys.sorted()[index], specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(baby.weight.values.sorted()[index], formatter: DateFormatter.shortDateFormatter)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteWeight)

                    case "Head Circumference":
                        ForEach(0..<baby.headCircumference.count, id: \.self) { index in
                            HStack {
                                Text("\(baby.headCircumference.keys.sorted()[index], specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(baby.headCircumference.values.sorted()[index], formatter: DateFormatter.shortDateFormatter)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteHeadCircumference)

                    default:
                        EmptyView()
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.white)
                .cornerRadius(baby.height.count > 0 ? 10 : 0)
                .frame(height: CGFloat(44 * (baby.height.count > 0 ? baby.height.count : 0)))
                .padding(.leading, 16)
                .padding(.trailing, 16)
                Spacer()
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("\(measurementType) Data")
        .navigationBarItems(
            trailing: Button(action: {
                isEditing.toggle()
            }) {
                Text(isEditing ? "Done" : "Edit")
            }
        )
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        .background(Color(UIColor.systemGray6))
        .frame(alignment: .top)
    }
    
    private func unitForMeasurementType() -> String {
        switch measurementType {
        case "Height":
            return "cm"
        case "Weight":
            return "kg"
        case "Head Circumference":
            return "cm"
        default:
            return ""
        }
    }
    
    private func dataCountForSelectedMeasurementType() -> Int {
        switch measurementType {
        case "Height":
            return baby?.height.count ?? 0
        case "Weight":
            return baby?.weight.count ?? 0
        case "Head Circumference":
            return baby?.headCircumference.count ?? 0
        default:
            return 0
        }
    }

    private func deleteHeight(at offsets: IndexSet) {
        if let index = offsets.first {
            let heightValue = Array(baby?.height.keys.sorted() ?? [])[index]
            baby?.removeHeight(heightValue)
            onDataChanged?()
        }
    }

    private func deleteWeight(at offsets: IndexSet) {
        if let index = offsets.first {
            let weightValue = Array(baby?.weight.keys.sorted() ?? [])[index]
            baby?.removeWeight(weightValue)
            onDataChanged?()
        }
    }

    private func deleteHeadCircumference(at offsets: IndexSet) {
        if let index = offsets.first {
            let headCircumferenceValue = Array(baby?.headCircumference.keys.sorted() ?? [])[index]
            baby?.removeHeadCircumference(headCircumferenceValue)
            onDataChanged?()
        }
    }
}

extension DateFormatter {
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
