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

// Storage for all babies' vaccine data - using a dictionary in memory
private var allBabiesVaccineData: [String: [String: [VaccineDose]]] = [:]

// Notification name for vaccine updates
extension Notification.Name {
    static let vaccinesUpdated = Notification.Name("vaccinesUpdated")
}

// Vaccine tracker class that works with Baby
class BabyVaccineTracker {
    let baby: Baby
    
    // Vaccine storage key based on baby ID
    private var vaccineStorageKey: String {
        return baby.id.uuidString
    }
    
    // Vaccine data for this baby
    var completedVaccines: [String: [VaccineDose]] {
        get {
            return allBabiesVaccineData[vaccineStorageKey] ?? [:]
        }
        set {
            allBabiesVaccineData[vaccineStorageKey] = newValue
        }
    }
    
    // Initialize with a baby reference
    init(baby: Baby) {
        self.baby = baby
    }
    
    // Calculate baby's age in months
    var ageInMonths: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dob = dateFormatter.date(from: baby.dateOfBirth) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dob, to: Date())
        return components.month ?? 0
    }
    
    // Update a vaccine for this baby
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
    
    // Get completed doses for a specific vaccine
    func getCompletedDoses(for vaccineName: String) -> [DoseType] {
        return completedVaccines[vaccineName]?.map { $0.doseType } ?? []
    }
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
    
    func getUpcomingVaccinations(for vaccineTracker: BabyVaccineTracker) -> [(name: String, dose: VaccineDose)] {
        var upcoming: [(name: String, dose: VaccineDose)] = []
        
        for vaccine in vaccines {
            let completedDoses = vaccineTracker.getCompletedDoses(for: vaccine.name)
            if let nextDose = vaccine.getNextRequiredDose(childAgeInMonths: vaccineTracker.ageInMonths,
                                                        completedDoses: completedDoses) {
                upcoming.append((vaccine.name, nextDose))
            }
        }
        
        return upcoming
    }
}
