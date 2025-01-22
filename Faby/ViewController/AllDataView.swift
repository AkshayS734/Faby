import SwiftUI

struct AllDataView: View {
    var baby: Baby?
    var measurementType: String
    var onDataChanged: (() -> Void)?

    @State private var isEditing = false

    var body: some View {
        VStack {
            if let baby = baby {
                List {
                    switch measurementType {
                    case "Height":
                        ForEach(0..<baby.height.count, id: \.self) { index in
                            HStack {
                                Text("Height: \(baby.height.keys.sorted()[index], specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(baby.height.values.sorted()[index], formatter: DateFormatter.shortDateFormatter)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteHeight)

                    case "Weight":
                        ForEach(0..<baby.weight.count, id: \.self) { index in
                            HStack {
                                Text("Weight: \(baby.weight.keys.sorted()[index], specifier: "%.2f")")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(baby.weight.values.sorted()[index], formatter: DateFormatter.shortDateFormatter)")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .onDelete(perform: deleteWeight)

                    case "Head Circumference":
                        ForEach(0..<baby.headCircumference.count, id: \.self) { index in
                            HStack {
                                Text("Head Circumference: \(baby.headCircumference.keys.sorted()[index], specifier: "%.2f")")
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
            } else {
                Text("No data available")
                    .foregroundColor(.gray)
                    .padding()
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
