import Foundation
struct VaccineData : Identifiable {
    let id = UUID()
        let name: String
        let startDate: Date
        let endDate: Date
        var isScheduled: Bool
    }
    
