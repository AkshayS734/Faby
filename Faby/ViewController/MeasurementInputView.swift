import Foundation
import SwiftUI

struct MeasurementInputView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputMeasurement: String = ""
    @State private var selectedDate = Date()
    
    let measurementType: String
    let saveMeasurement: (String, Date) -> Void  // Closure for saving the measurement
    
    let heightUnits = ["cm", "inches"]
    let weightUnits = ["kg", "lbs"]
    @State private var selectedUnit: String = "cm"  // Default to cm for height and "kg" for weight

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
                        Picker("Unit", selection: $selectedUnit) {
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
                            // Call the saveMeasurement closure with the input value and selected date
                            saveMeasurement(inputMeasurement, selectedDate)
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
