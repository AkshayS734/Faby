import SwiftUI
import Combine

class UnitSettingsViewModel: ObservableObject {
    static let shared = UnitSettingsViewModel()
    
    @Published var selectedUnit: String = "cm" {
        didSet {
            notifyUnitChange()
        }
    }
    
    @Published var weightUnit: String = "kg" {
        didSet {
            notifyUnitChange()
        }
    }
    
    @Published var isUnitChanged: Bool = false
    
    private var unitChangeSubject = PassthroughSubject<Void, Never>()
    
    var unitChangePublisher: AnyPublisher<Void, Never> {
        return unitChangeSubject.eraseToAnyPublisher()
    }
    
    private func notifyUnitChange() {
        isUnitChanged = true
        unitChangeSubject.send()
    }
}
