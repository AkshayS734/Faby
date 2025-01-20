import Foundation
import SwiftUI

struct MeasurementInputView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDate = Date()
    @State private var selectedUnit = "cm"
    @State private var selectedWeightUnit = "kg"
    @State private var inputMeasurement: String = ""
    let measurementType: String
    
    let heightUnits = ["cm", "inches"]
    let weightUnits = ["kg", "lbs"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Measurement Value")) {
                    TextField("Enter \(measurementType) value", text: $inputMeasurement)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Measurement Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                if measurementType == "Height" || measurementType == "Head Circumference" {
                    Section(header: Text("Unit")) {
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(heightUnits, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                if measurementType == "Weight" {
                    Section(header: Text("Unit (Weight)")) {
                        Picker("Unit", selection: $selectedWeightUnit) {
                            ForEach(weightUnits, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .navigationTitle("Add \(measurementType)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let measurement = Double(inputMeasurement) {
                            print("Saved - Date: \(selectedDate), Type: \(measurementType), Value: \(measurement), Unit: \(measurementType == "Weight" ? selectedWeightUnit : selectedUnit)")
                            dismiss()
                        } else {
                            print("Invalid measurement value")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
struct MeasurementInputView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementInputView(measurementType: "Height")
    }
}
