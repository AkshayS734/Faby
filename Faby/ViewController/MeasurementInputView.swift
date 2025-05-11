import Foundation
import SwiftUI

struct MeasurementInputView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputMeasurement: String = ""
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let measurementType: String
    let saveMeasurement: (Double, Date, String) -> Void
    
    private let heightUnits = ["cm", "inches"]
    private let weightUnits = ["kg", "lbs"]
    @State private var selectedUnit: String
    
    init(measurementType: String, saveMeasurement: @escaping (Double, Date, String) -> Void) {
        self.measurementType = measurementType
        self.saveMeasurement = saveMeasurement
        _selectedUnit = State(initialValue: measurementType == "Weight" ? "kg" : "cm")
    }
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Measurement Value")) {
                    TextField("Enter \(measurementType) value (e.g., 50)", text: $inputMeasurement)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("Measurement value input for \(measurementType)")
                        .foregroundColor(isValidInput ? .primary : .blue)
                }
                
                Section(header: Text("Measurement Date")) {
                    DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
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
                    Section(header: Text("Unit")) {
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
                        handleSave()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invalid Input", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(alertMessage)
            })
        }
    }
    
    private var isValidInput: Bool {
        if let value = Double(inputMeasurement), value > 0 {
            return true
        }
        return false
    }

    private func handleSave() {
        guard let measurementValue = Double(inputMeasurement), measurementValue > 0 else {
            alertMessage = "Please enter a valid measurement value greater than 0."
            showAlert = true
            return
        }
        saveMeasurement(measurementValue, selectedDate, selectedUnit)
        dismiss()
    }
}
