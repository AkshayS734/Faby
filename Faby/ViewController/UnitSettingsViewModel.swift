import SwiftUI

class UnitSettingsViewModel: ObservableObject {
    @Published var selectedUnit: String = "cm"
    @Published var weightUnit: String = "kg"
    @Published var isUnitChanged: Bool = false
}
