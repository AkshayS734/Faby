import Foundation
import UIKit
import CoreLocation
import Supabase

// MARK: - Basic Vaccine Data
struct VaccineData: Identifiable {
    let id = UUID()
    let name: String
    let startDate: Date
    let endDate: Date
    var isScheduled: Bool
}

// MARK: - Vaccination Record Models
struct VaccineSchedule {
    let type: String
    let hospital: String
    let date: String
    let location: String
}

struct VaccinationSchedule: Identifiable {
    let id: UUID
    let type: String
    let hospitalName: String
    let hospitalAddress: String
    let scheduledDate: String
    let babyId: UUID
}

// MARK: - Supabase Models
// These models are specifically for Supabase database operations

/// VacciAlertRecord - Main Supabase table model for vaccine records
struct VacciAlertRecord: Codable, Identifiable {
    let id: UUID?
    let baby_id: UUID
    let vaccine_name: String
    let dose_type: String
    let scheduled_date: String?
    let administered_date: String?
    let hospital_name: String?
    let hospital_address: String?
    let location: String?
    let notes: String?
    let created_at: String?
    
    init(
        id: UUID? = nil,
        babyId: UUID,
        vaccineName: String,
        doseType: String,
        scheduledDate: String? = nil,
        administeredDate: String? = nil,
        hospitalName: String? = nil,
        hospitalAddress: String? = nil,
        location: String? = nil,
        notes: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.baby_id = babyId
        self.vaccine_name = vaccineName
        self.dose_type = doseType
        self.scheduled_date = scheduledDate
        self.administered_date = administeredDate
        self.hospital_name = hospitalName
        self.hospital_address = hospitalAddress
        self.location = location
        self.notes = notes
        self.created_at = createdAt
    }
}

// MARK: - Vaccine Dose Models
enum DoseType: String, Codable {
    case firstDose = "1st Dose"
    case secondDose = "2nd Dose"
    case booster = "Booster Dose"
}

struct AgeRange: Codable {
    let minMonths: Int
    let maxMonths: Int
    
    func isInRange(childAgeInMonths: Int) -> Bool {
        return childAgeInMonths >= minMonths && childAgeInMonths <= maxMonths
    }
}

struct VaccineDose: Codable {
    let doseType: DoseType
    let ageRange: AgeRange
    let monthsAfterPreviousDose: Int?
    var dateAdministered: Date?
    var location: String?
    var notes: String?
}

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

// MARK: - Hospital Model for Vaccination
struct Hospital: Codable, Hashable {
    let id: UUID
    let babyId: UUID
    let name: String
    let address: String
    let distance: Double
    let lastUpdated: Date
    
    struct Coordinates: Codable, Hashable {
        let latitude: Double
        let longitude: Double
        
        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        static func from(_ location: CLLocationCoordinate2D) -> Coordinates {
            return Coordinates(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    init(
        id: UUID = UUID(),
        babyId: UUID,
        name: String,
        address: String,
        distance: Double,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.address = address
        self.distance = distance
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Storage Managers
extension Notification.Name {
    static let vaccinesUpdated = Notification.Name("vaccinesUpdated")
}

// MARK: - Vaccination Storage Manager
class VaccinationStorageManager {
    static let shared = VaccinationStorageManager()
    
    // Dictionary to store schedules with UUID as key and VaccinationSchedule as value
    private var schedules: [UUID: VaccinationSchedule] = [:]
    
    private init() {}
    
    func saveSchedule(_ schedule: VaccinationSchedule) {
        schedules[schedule.id] = schedule
    }
    
    func getAllSchedules() -> [VaccinationSchedule] {
        return Array(schedules.values)
    }
    
    func getSchedulesForBaby(babyId: UUID) -> [VaccinationSchedule] {
        return schedules.values.filter { $0.babyId == babyId }
    }
    
    func deleteSchedule(id: UUID) {
        schedules.removeValue(forKey: id)
    }
}

// MARK: - Vaccine Tracker
// Storage for all babies' vaccine data - using a dictionary in memory
private var allBabiesVaccineData: [String: [String: [VaccineDose]]] = [:]

class BabyVaccineTracker {
    let baby: Baby
    
    // Vaccine storage key based on baby ID
    private var vaccineStorageKey: String {
        return baby.babyID.uuidString
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
        
        // Save to Supabase
        Task {
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let administeredDateString = dateFormatter.string(from: date)
                
                let record = VacciAlertRecord(
                    babyId: baby.babyID,
                    vaccineName: vaccine.name,
                    doseType: dose.doseType.rawValue,
                    scheduledDate: nil,
                    administeredDate: administeredDateString,
                    location: location,
                    notes: notes
                )
                
                try await VacciAlertSupabaseManager.shared.saveVaccineRecord(record)
                NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
            } catch {
                print("❌ Error saving vaccine to Supabase: \(error)")
            }
        }
    }
    
    // Get completed doses for a specific vaccine
    func getCompletedDoses(for vaccineName: String) -> [DoseType] {
        return completedVaccines[vaccineName]?.map { $0.doseType } ?? []
    }
    
    // Fetch records from Supabase
    func fetchVaccinationRecords() async {
        do {
            let records = try await VacciAlertSupabaseManager.shared.getVaccineRecordsForBaby(babyId: baby.babyID)
            
            // Convert to local data structure
            var loadedVaccines: [String: [VaccineDose]] = [:]
            
            for record in records {
                let doseType = DoseType(rawValue: record.dose_type) ?? .firstDose
                
                // Create a placeholder age range since we don't get this from Supabase
                // The actual age ranges are defined in VaccineDataManager's predefined vaccines
                let ageRange = AgeRange(minMonths: 0, maxMonths: 100)
                
                var dose = VaccineDose(
                    doseType: doseType,
                    ageRange: ageRange,
                    monthsAfterPreviousDose: nil
                )
                
                if let adminDateString = record.administered_date, 
                   let adminDate = dateFromString(adminDateString) {
                    dose.dateAdministered = adminDate
                }
                
                dose.location = record.location
                dose.notes = record.notes
                
                if loadedVaccines[record.vaccine_name] == nil {
                    loadedVaccines[record.vaccine_name] = []
                }
                loadedVaccines[record.vaccine_name]?.append(dose)
            }
            
            // Update the in-memory data structure
            completedVaccines = loadedVaccines
            
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        } catch {
            print("❌ Error fetching vaccine records from Supabase: \(error)")
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
}

// MARK: - Vaccine Data Manager
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
        ])
        // Add other vaccines as needed
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
    
    // Hospital-related vaccination functions
    func saveVaccinationSchedule(hospital: Hospital, date: String, vaccineType: String) {
        let vaccinationData: [String: Any] = [
            "id": UUID().uuidString,
            "hospitalId": hospital.id.uuidString,
            "babyId": hospital.babyId.uuidString,
            "type": vaccineType,
            "hospitalName": hospital.name,
            "address": hospital.address,
            "date": date,
            "scheduledAt": Date().timeIntervalSince1970
        ]
        
        var savedSchedules = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: Any]] ?? []
        savedSchedules.append(vaccinationData)
        UserDefaults.standard.set(savedSchedules, forKey: "VaccinationSchedules")
        
        // Save to Supabase as well
        Task {
            do {
                let record = VacciAlertRecord(
                    babyId: hospital.babyId,
                    vaccineName: vaccineType,
                    doseType: "Scheduled",
                    scheduledDate: date,
                    hospitalName: hospital.name,
                    hospitalAddress: hospital.address
                )
                
                try await VacciAlertSupabaseManager.shared.saveVaccineRecord(record)
            } catch {
                print("❌ Error saving vaccination schedule to Supabase: \(error)")
            }
        }
    }
}

// MARK: - Supabase Manager for VacciAlert
class VacciAlertSupabaseManager {
    static let shared = VacciAlertSupabaseManager()
    
    private init() {}
    
    // Access the shared SupabaseClient from SceneDelegate
    private var supabase: SupabaseClient? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        return nil
    }
    
    // MARK: - Save a vaccine record
    func saveVaccineRecord(_ record: VacciAlertRecord) async throws {
        guard let supabase = supabase else {
            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        try await supabase.from("Vaccination_table")
            .insert(record)
            .execute()
    }
    
    // MARK: - Get all vaccine records for a specific baby
    func getVaccineRecordsForBaby(babyId: UUID) async throws -> [VacciAlertRecord] {
        guard let supabase = supabase else {
            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("Vaccination_table")
            .select()
            .eq("baby_id", value: babyId.uuidString)
            .execute()
        
        // Fix: data is not optional, so we access it directly
        let data = response.data
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([VacciAlertRecord].self, from: data)
        } catch {
            print("Error decoding vaccine records: \(error)")
            return []
        }
    }
    
    // MARK: - Update an existing vaccine record
    func updateVaccineRecord(_ record: VacciAlertRecord) async throws {
        guard let supabase = supabase else {
            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        guard let id = record.id else {
            throw NSError(domain: "VacciAlertError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Record ID is missing"])
        }
        
        try await supabase.from("Vaccination_table")
            .update(record)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Delete a vaccine record
    func deleteVaccineRecord(id: UUID) async throws {
        guard let supabase = supabase else {
            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        try await supabase.from("Vaccination_table")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

// MARK: - Baby interface for VacciAlert feature
// This is a minimal interface to Baby class needed for the VacciAlert feature
// without copying the entire Baby class implementation
extension Baby {
    func getVaccineTracker() -> BabyVaccineTracker {
        return BabyVaccineTracker(baby: self)
    }
    
    func getAge() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dob = dateFormatter.date(from: self.dateOfBirth) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dob, to: Date())
        return components.month ?? 0
    }
}
    
