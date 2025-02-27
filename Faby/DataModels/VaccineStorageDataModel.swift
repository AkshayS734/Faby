// VaccineModel.swift

import Foundation
import UIKit

// Enum to represent vaccine doses
enum DoseType: String, Codable {
    case firstDose = "1st Dose"
    case secondDose = "2nd Dose"
    case booster = "Booster Dose"
}

// Struct to represent age range
struct AgeRange: Codable {
    let minMonths: Int
    let maxMonths: Int
    
    func isInRange(childAgeInMonths: Int) -> Bool {
        return childAgeInMonths >= minMonths && childAgeInMonths <= maxMonths
    }
}

// Struct to represent a vaccine dose
struct VaccineDose: Codable {
    let doseType: DoseType
    let ageRange: AgeRange
    let monthsAfterPreviousDose: Int?
    var dateAdministered: Date?
    var location: String?
    var notes: String?
}

// Main vaccine model
struct Vaccine: Codable {
    let name: String
    var doses: [VaccineDose]
    
    func getNextRequiredDose(childAgeInMonths: Int, completedDoses: [DoseType]) -> VaccineDose? {
        return doses.first { dose in
            !completedDoses.contains(dose.doseType) &&
            dose.ageRange.isInRange(childAgeInMonths: childAgeInMonths)
        }
    }
}

// Extension to Baby class to handle vaccine-related data
extension Baby {
    // Store completed vaccines for this baby
    var vaccineStorageKey: String {
        "vaccines_\(self.babyID.uuidString)"
    }
    var completedVaccines: [String: [VaccineDose]] {
        get {
            if let data = UserDefaults.standard.data(forKey: vaccineStorageKey),
               let decoded = try? JSONDecoder().decode([String: [VaccineDose]].self, from: data) {
                return decoded
            }
            return [:]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: vaccineStorageKey)
            }
        }
    }
    
    var ageInMonths: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dob = dateFormatter.date(from: dateOfBirth) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dob, to: Date())
        return components.month ?? 0
    }
    
    func updateVaccine(_ vaccine: Vaccine, dose: VaccineDose, date: Date, location: String? = nil, notes: String? = nil) {
        var updatedDose = dose
        updatedDose.dateAdministered = date
        updatedDose.location = location
        updatedDose.notes = notes
        
        var currentVaccines = completedVaccines
        if currentVaccines[vaccine.name] == nil {
            currentVaccines[vaccine.name] = []
        }
        currentVaccines[vaccine.name]?.append(updatedDose)
        completedVaccines = currentVaccines
        
        NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
    }
}

// Notification name extension
extension Notification.Name {
    static let vaccinesUpdated = Notification.Name("vaccinesUpdated")
}

// Vaccine data manager
class VaccineDataManager {
    static let shared = VaccineDataManager()
    
    let vaccines: [Vaccine] = [
        Vaccine(name: "MMR", doses: [
            VaccineDose(doseType: .firstDose,
                       ageRange: AgeRange(minMonths: 9, maxMonths: 12),
                       monthsAfterPreviousDose: nil),
            VaccineDose(doseType: .secondDose,
                       ageRange: AgeRange(minMonths: 15, maxMonths: 18),
                       monthsAfterPreviousDose: nil)
        ]),
        Vaccine(name: "Varicella", doses: [
            VaccineDose(doseType: .firstDose,
                       ageRange: AgeRange(minMonths: 15, maxMonths: 15),
                       monthsAfterPreviousDose: nil),
            VaccineDose(doseType: .secondDose,
                       ageRange: AgeRange(minMonths: 48, maxMonths: 72),
                       monthsAfterPreviousDose: nil)
        ]),
        Vaccine(name: "Hepatitis A", doses: [
            VaccineDose(doseType: .firstDose,
                       ageRange: AgeRange(minMonths: 12, maxMonths: 23),
                       monthsAfterPreviousDose: nil),
            VaccineDose(doseType: .secondDose,
                       ageRange: AgeRange(minMonths: 18, maxMonths: 35),
                       monthsAfterPreviousDose: 6)
        ]),
        // Add other vaccines...
    ]
    
    func getUpcomingVaccinations(for baby: Baby) -> [(name: String, dose: VaccineDose)] {
        var upcoming: [(name: String, dose: VaccineDose)] = []
        
        for vaccine in vaccines {
            let completedDoses = baby.completedVaccines[vaccine.name]?.map { $0.doseType } ?? []
            if let nextDose = vaccine.getNextRequiredDose(childAgeInMonths: baby.ageInMonths,
                                                        completedDoses: completedDoses) {
                upcoming.append((vaccine.name, nextDose))
            }
        }
        
        return upcoming
    }
}
