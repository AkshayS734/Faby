import Foundation
import SwiftUI

struct UnitSettingsView: View {
    @EnvironmentObject var unitSettings: UnitSettingsViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Height Unit")) {
                Picker("Unit", selection: $unitSettings.selectedUnit) {
                    Text("cm").tag("cm")
                    Text("inches").tag("inches")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Weight Unit")) {
                Picker("Unit", selection: $unitSettings.weightUnit) {
                    Text("kg").tag("kg")
                    Text("lbs").tag("lbs")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Unit Settings")
    }
}
