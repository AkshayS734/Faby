import Foundation
import UIKit
import CoreLocation
import Supabase

// MARK: - Core Vaccination Data Models

/// Base model for vaccine information
struct Vaccine: Identifiable,Codable {
    var id = UUID()
        let name: String
    let startWeek: Int
    let endWeek: Int
    let description: String
}

/// Record representing a vaccine schedule
struct VaccineSchedule: Codable, Identifiable {
    let id: UUID
    let babyID: UUID
    let vaccineId: UUID
    var hospital: String
    var date: Date
    var location: String
    let isAdministered: Bool
    
    // Add CodingKeys to map between Swift property names and database column names
    enum CodingKeys: String, CodingKey {
        case id
        case babyID = "baby_id"
        case vaccineId = "vaccine_id"
        case hospital
        case date
        case location
        case isAdministered = "is_administered"
    }
}

//for immunization report
struct VaccineAdministered: Identifiable, Codable {
    let id: UUID
    let babyId: UUID
    let vaccineId: UUID
    let scheduleId: UUID
    var administeredDate: Date
    
    // Add CodingKeys to map between Swift property names and database column names
    enum CodingKeys: String, CodingKey {
        case id
        case babyId = "baby_id"
        case vaccineId = "vaccine_id"
        case scheduleId = "schedule_id"
        case administeredDate = "administered_date"
    }
}

// MARK: - Hospital Model
struct Hospital: Identifiable {
    let id: UUID
    let babyId: UUID
    let name: String
    let address: String
    let distance: Double
    var coordinates: CLLocationCoordinate2D?
    
    init(id: UUID = UUID(),
         babyId: UUID,
         name: String,
         address: String,
         distance: Double,
         coordinates: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.address = address
        self.distance = distance
        self.coordinates = coordinates
    }
}

// MARK: - Hospital Address Model
struct HospitalAddress {
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    var latitude: Double
    var longitude: Double
    
    var formattedAddress: String {
        return "\(street), \(city), \(state) \(postalCode), \(country)"
    }
    
    init(street: String, city: String = "", state: String = "", postalCode: String = "", country: String = "", latitude: Double = 0.0, longitude: Double = 0.0) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}


/// Dose type enumeration for tracking vaccination stages
//enum DoseType: String, Codable {
//    case firstDose = "1st Dose"
//    case secondDose = "2nd Dose"
//    case booster = "Booster Dose"
//    case scheduled = "Scheduled"
//    case completed = "Completed"
//}
//
/// Age range for recommended vaccinations
//struct AgeRange: Codable {
//    let minMonths: Int
//    let maxMonths: Int
//    
//    func isInRange(childAgeInMonths: Int) -> Bool {
//        return childAgeInMonths >= minMonths && childAgeInMonths <= maxMonths
//    }
//}
//
/// Specific vaccine dose information
//struct VaccineDose: Codable {
//    let doseType: DoseType
//    let ageRange: AgeRange
//    let monthsAfterPreviousDose: Int?
//    var dateAdministered: Date?
//    var location: String?
//    var notes: String?
//}
//
/// Vaccine definition with its required doses
//struct Vaccine: Codable {
//    let name: String
//    var doses: [VaccineDose]
//    
//    func getNextRequiredDose(childAgeInMonths: Int, completedDoses: [DoseType]) -> VaccineDose? {
//        return doses.first { dose in
//            !completedDoses.contains(dose.doseType) &&
//            dose.ageRange.isInRange(childAgeInMonths: childAgeInMonths)
//        }
//    }
//}
//
/// Hospital information for vaccination appointments
//struct Hospital: Codable, Hashable {
//    let id: UUID
//    let babyId: UUID
//    let name: String
//    let address: String
//    let distance: Double
//    let lastUpdated: Date
//    
//    struct Coordinates: Codable, Hashable {
//        let latitude: Double
//        let longitude: Double
//        
//        func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
//            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        }
//        
//        static func from(_ location: CLLocationCoordinate2D) -> Coordinates {
//            return Coordinates(latitude: location.latitude, longitude: location.longitude)
//        }
//    }
//    
//    init(
//        id: UUID = UUID(),
//        babyId: UUID,
//        name: String,
//        address: String,
//        distance: Double,
//        lastUpdated: Date = Date()
//    ) {
//        self.id = id
//        self.babyId = babyId
//        self.name = name
//        self.address = address
//        self.distance = distance
//        self.lastUpdated = lastUpdated
//    }
//}
//
//// MARK: - Database Record Model
//
///// Main database record model for storing vaccination data in Supabase
//struct VacciAlertRecord: Codable, Identifiable {
//    // Primary fields
//    let id: UUID
//    let babyId: UUID
//    let vaccine_name: String
//    let dose_type: String
//    
//    // Field groups
//    // 1. Date fields
//    let scheduled_date: String?
//    let administered_date: String?
//    
//    // 2. Location fields
//    let hospital_name: String?
//    let hospital_address: String?
//    let location: String
//    
//    // 3. Additional fields
//    let notes: String?
//    let created_at: String?
//    
//    // Legacy fields (for backward compatibility)
//    let type: String
//    let date: String
//    let hospital: String
//    
//    // Computed properties for consistent access
//    var scheduledDate: String? { scheduled_date }
//    var administeredDate: String? { administered_date }
//    var hospitalName: String? { hospital_name }
//    var hospitalAddress: String? { hospital_address }
//    var baby_id: UUID { babyId }
//    
//    init(
//        id: UUID = UUID(),
//        type: String = "",
//        date: String = "",
//        hospital: String = "",
//        babyId: UUID,
//        vaccineName: String,
//        doseType: String,
//        scheduledDate: String? = nil,
//        administeredDate: String? = nil,
//        hospitalName: String? = nil,
//        hospitalAddress: String? = nil,
//        location: String,
//        notes: String? = nil,
//        createdAt: String? = nil
//    ) {
//        self.id = id
//        self.type = type
//        self.date = date
//        self.hospital = hospital
//        self.babyId = babyId
//        self.vaccine_name = vaccineName
//        self.dose_type = doseType
//        self.scheduled_date = scheduledDate
//        self.administered_date = administeredDate
//        self.hospital_name = hospitalName
//        self.hospital_address = hospitalAddress
//        self.location = location
//        self.notes = notes
//        self.created_at = createdAt
//    }
//}
//
//// MARK: - Storage Managers
//
///// Custom notification names
//extension Notification.Name {
//    static let vaccinesUpdated = Notification.Name("vaccinesUpdated")
//    static let newVaccineScheduled = Notification.Name("NewVaccineScheduled")
//}
//
///// Local storage manager for vaccination data
//class VaccinationStorageManager {
//    static let shared = VaccinationStorageManager()
//    
//    // Dictionary to store records with UUID as key
//    private var schedules: [UUID: VacciAlertRecord] = [:]
//    
//    private init() {}
//    
//    /// Save a vaccination schedule to local storage
//    func saveSchedule(_ schedule: VacciAlertRecord) {
//        schedules[schedule.id] = schedule
//        print("📝 Saved vaccine schedule locally: \(schedule.vaccine_name)")
//    }
//    
//    /// Get all vaccination schedules from local storage
//    func getAllSchedules() -> [VacciAlertRecord] {
//        return Array(schedules.values)
//    }
//    
//    /// Get vaccination schedules for a specific baby
//    func getSchedulesForBaby(babyId: UUID) -> [VacciAlertRecord] {
//        return schedules.values.filter { $0.babyId == babyId }
//    }
//    
//    /// Delete a vaccination schedule by ID
//    func deleteSchedule(id: UUID) {
//        schedules.removeValue(forKey: id)
//        print("🗑️ Deleted vaccine schedule with ID: \(id)")
//    }
//    
//    /// Load vaccination schedules as dictionaries for UI display
//    func loadVaccinationSchedules(completion: @escaping ([[String: String]]) -> Void) {
//        print("📋 VaccinationStorageManager: Loading vaccination schedules...")
//        
//        // Convert local schedules to dictionaries
//        var localSchedules: [[String: String]] = []
//        for schedule in getAllSchedules() {
//            let dict: [String: String] = [
//                "type": schedule.type,
//                "date": schedule.scheduledDate ?? "",
//                "hospital": schedule.hospitalName ?? "",
//                "location": schedule.hospitalAddress ?? ""
//            ]
//            localSchedules.append(dict)
//        }
//        
//        print("📋 VaccinationStorageManager: Retrieved \(localSchedules.count) local schedules")
//        
//        // Return local schedules first (faster)
//        completion(localSchedules)
//    }
//}
//
//// MARK: - Vaccine Tracking for Babies
//
///// Tracks vaccination data for a specific baby
//class BabyVaccineTracker {
//    let baby: Baby
//    
//    // Storage for all babies' vaccine data - using a dictionary in memory
//    private static var allBabiesVaccineData: [String: [String: [VaccineDose]]] = [:]
//    
//    // Vaccine storage key based on baby ID
//    private var vaccineStorageKey: String {
//        return baby.babyID.uuidString
//    }
//    
//    // Vaccine data for this baby
//    var completedVaccines: [String: [VaccineDose]] {
//        get {
//            return BabyVaccineTracker.allBabiesVaccineData[vaccineStorageKey] ?? [:]
//        }
//        set {
//            BabyVaccineTracker.allBabiesVaccineData[vaccineStorageKey] = newValue
//        }
//    }
//    
//    // Initialize with a baby reference
//    init(baby: Baby) {
//        self.baby = baby
//    }
//    
//    // Calculate baby's age in months
//    var ageInMonths: Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        guard let dob = dateFormatter.date(from: baby.dateOfBirth) else { return 0 }
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.month], from: dob, to: Date())
//        return components.month ?? 0
//    }
//    
//    /// Update a vaccine record for this baby
//    func updateVaccine(_ vaccine: Vaccine, dose: VaccineDose, date: Date, location: String? = nil, notes: String? = nil) {
//        var updatedDose = dose
//        updatedDose.dateAdministered = date
//        updatedDose.location = location
//        updatedDose.notes = notes
//        
//        var currentVaccines = completedVaccines
//        if currentVaccines[vaccine.name] == nil {
//            currentVaccines[vaccine.name] = []
//        }
//        currentVaccines[vaccine.name]?.append(updatedDose)
//        completedVaccines = currentVaccines
//        
//        // Save to Supabase
//        Task {
//            do {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                let administeredDateString = dateFormatter.string(from: date)
//                
//                let record = VacciAlertRecord(
//                    id: UUID(),
//                    type: "Administered",
//                    date: administeredDateString,
//                    hospital: location ?? "Unknown",
//                    babyId: baby.babyID,
//                    vaccineName: vaccine.name,
//                    doseType: dose.doseType.rawValue,
//                    scheduledDate: nil,
//                    administeredDate: administeredDateString,
//                    hospitalName: nil,
//                    hospitalAddress: nil,
//                    location: location ?? "Unknown",
//                    notes: notes
//                )
//                
//                try await VacciAlertSupabaseManager.shared.saveVaccineRecord(record)
//                NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
//            } catch {
//                print("❌ Error saving vaccine to Supabase: \(error)")
//            }
//        }
//    }
//    
//    /// Get completed doses for a specific vaccine
//    func getCompletedDoses(for vaccineName: String) -> [DoseType] {
//        return completedVaccines[vaccineName]?.map { $0.doseType } ?? []
//    }
//    
//    /// Fetch vaccination records from Supabase
//    func fetchVaccinationRecords() async {
//        do {
//            let records = try await VacciAlertSupabaseManager.shared.getVaccineRecordsForBaby(babyId: baby.babyID)
//            
//            // Convert to local data structure
//            var loadedVaccines: [String: [VaccineDose]] = [:]
//            
//            for record in records {
//                let doseType = DoseType(rawValue: record.dose_type) ?? .firstDose
//                
//                // Create a placeholder age range since we don't get this from Supabase
//                // The actual age ranges are defined in VaccineDataManager's predefined vaccines
//                let ageRange = AgeRange(minMonths: 0, maxMonths: 100)
//                
//                var dose = VaccineDose(
//                    doseType: doseType,
//                    ageRange: ageRange,
//                    monthsAfterPreviousDose: nil
//                )
//                
//                if let adminDateString = record.administered_date,
//                   let adminDate = dateFromString(adminDateString) {
//                    dose.dateAdministered = adminDate
//                }
//                
//                dose.location = record.location
//                dose.notes = record.notes
//                
//                if loadedVaccines[record.vaccine_name] == nil {
//                    loadedVaccines[record.vaccine_name] = []
//                }
//                loadedVaccines[record.vaccine_name]?.append(dose)
//            }
//            
//            // Update the in-memory data structure
//            completedVaccines = loadedVaccines
//            
//            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
//        } catch {
//            print("❌ Error fetching vaccine records from Supabase: \(error)")
//        }
//    }
//    
//    private func dateFromString(_ dateString: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        return dateFormatter.date(from: dateString)
//    }
//}
//
//// MARK: - Vaccine Data Management
//
///// Manages predefined vaccine data and recommendations
//class VaccineDataManager {
//    static let shared = VaccineDataManager()
//    
//    /// Predefined list of vaccines with their recommended doses
//    let vaccines: [Vaccine] = [
//        Vaccine(name: "MMR", doses: [
//            VaccineDose(doseType: .firstDose,
//                       ageRange: AgeRange(minMonths: 9, maxMonths: 12),
//                       monthsAfterPreviousDose: nil),
//            VaccineDose(doseType: .secondDose,
//                       ageRange: AgeRange(minMonths: 15, maxMonths: 18),
//                       monthsAfterPreviousDose: nil)
//        ]),
//        Vaccine(name: "Varicella", doses: [
//            VaccineDose(doseType: .firstDose,
//                       ageRange: AgeRange(minMonths: 15, maxMonths: 15),
//                       monthsAfterPreviousDose: nil),
//            VaccineDose(doseType: .secondDose,
//                       ageRange: AgeRange(minMonths: 48, maxMonths: 72),
//                       monthsAfterPreviousDose: nil)
//        ]),
//        Vaccine(name: "Hepatitis A", doses: [
//            VaccineDose(doseType: .firstDose,
//                       ageRange: AgeRange(minMonths: 12, maxMonths: 23),
//                       monthsAfterPreviousDose: nil),
//            VaccineDose(doseType: .secondDose,
//                       ageRange: AgeRange(minMonths: 18, maxMonths: 35),
//                       monthsAfterPreviousDose: 6)
//        ])
//        // Add other vaccines as needed
//    ]
//    
//    /// Get upcoming vaccinations for a baby
//    func getUpcomingVaccinations(for vaccineTracker: BabyVaccineTracker) -> [(name: String, dose: VaccineDose)] {
//        var upcoming: [(name: String, dose: VaccineDose)] = []
//        
//        for vaccine in vaccines {
//            let completedDoses = vaccineTracker.getCompletedDoses(for: vaccine.name)
//            if let nextDose = vaccine.getNextRequiredDose(childAgeInMonths: vaccineTracker.ageInMonths,
//                                                        completedDoses: completedDoses) {
//                upcoming.append((vaccine.name, nextDose))
//            }
//        }
//        
//        return upcoming
//    }
//    
//    /// Save vaccination schedule to local storage and Supabase
//    func saveVaccinationSchedule(hospital: Hospital, date: String, vaccineType: String) {
//        let storageDateFormatter = DateFormatter()
//        storageDateFormatter.dateFormat = "yyyy-MM-dd"
//        
//        let selectedDateFormatter = DateFormatter()
//        selectedDateFormatter.dateStyle = .medium
//        
//        var storageDateString = date
//        if let selectedDate = selectedDateFormatter.date(from: date) {
//            storageDateString = storageDateFormatter.string(from: selectedDate)
//        }
//        
//        // Save to Supabase
//        Task {
//            do {
//                let record = VacciAlertRecord(
//                    id: UUID(),
//                    type: "Scheduled",
//                    date: date,
//                    hospital: hospital.name,
//                    babyId: hospital.babyId,
//                    vaccineName: vaccineType,
//                    doseType: DoseType.scheduled.rawValue,
//                    scheduledDate: storageDateString,
//                    administeredDate: nil,
//                    hospitalName: hospital.name,
//                    hospitalAddress: hospital.address,
//                    location: hospital.address,
//                    notes: "Scheduled vaccination"
//                )
//                
//                try await VacciAlertSupabaseManager.shared.saveVaccineRecord(record)
//                print("✅ Successfully saved vaccination schedule to Supabase with address: \(hospital.address)")
//            } catch {
//                print("❌ Error saving vaccination schedule to Supabase: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - Supabase Integration
//
///// Manages Supabase database operations for vaccination data
//class VacciAlertSupabaseManager {
//    static let shared = VacciAlertSupabaseManager()
//    
//    private init() {}
//    
//    /// Access the shared SupabaseClient from SceneDelegate
//    private var supabase: SupabaseClient? {
//        // Ensure we're on the main thread when accessing UIApplication
//        if !Thread.isMainThread {
//            var result: SupabaseClient?
//            let semaphore = DispatchSemaphore(value: 0)
//            
//            DispatchQueue.main.async {
//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    result = appDelegate.supabase
//                } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//                    result = sceneDelegate.supabase
//                }
//                semaphore.signal()
//            }
//            
//            // Wait for main thread execution to complete
//            semaphore.wait()
//            return result
//        } else {
//            // Already on main thread
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                return appDelegate.supabase
//            } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//                return sceneDelegate.supabase
//            }
//            return nil
//        }
//    }
//    
//    /// Get all vaccination records (callback version)
//    func getAllRecords(completion: @escaping (Result<[VacciAlertRecord], Error>) -> Void) {
//        Task {
//            do {
//                guard let supabase = supabase else {
//                    let error = NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
//                    completion(.failure(error))
//                    return
//                }
//                
//                let response = try await supabase.from("Vaccination_table")
//                    .select()
//                    .execute()
//                
//                let data = response.data
//                let decoder = JSONDecoder()
//                let records = try decoder.decode([VacciAlertRecord].self, from: data)
//                
//                DispatchQueue.main.async {
//                    completion(.success(records))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    /// Save a vaccination record to Supabase
//    func saveVaccineRecord(_ record: VacciAlertRecord) async throws {
//        guard let supabase = supabase else {
//            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
//        }
//        
//        // Enhanced debug printing for record details
//        print("🔷 SAVING RECORD TO SUPABASE 🔷")
//        print("📊 Record Details:")
//        print("   - ID: \(record.id.uuidString)")
//        print("   - Baby ID: \(record.babyId.uuidString)")
//        print("   - Vaccine: \(record.vaccine_name)")
//        print("   - Dose Type: \(record.dose_type)")
//        print("📅 Date Fields:")
//        print("   - Scheduled Date: \(record.scheduled_date ?? "nil")")
//        print("   - Administered Date: \(record.administered_date ?? "nil")")
//        print("📍 Location Fields:")
//        print("   - Hospital: \(record.hospital_name ?? "nil")")
//        print("   - Hospital Address: \(record.hospital_address ?? "nil")")
//        print("   - Location: \(record.location)")
//        print("📝 Notes: \(record.notes ?? "nil")")
//        
//        do {
//            // Insert the record into Supabase
//            let response = try await supabase.from("Vaccination_table")
//                .insert(record)
//                .execute()
//            
//            print("✅ Successfully inserted record into Supabase")
//            
//            // Notify that vaccines have been updated
//            await MainActor.run {
//                NotificationCenter.default.post(name: .newVaccineScheduled, object: nil)
//                print("📣 Posted NewVaccineScheduled notification")
//            }
//        } catch {
//            print("❌ ERROR saving record to Supabase: \(error)")
//            throw error
//        }
//    }
//    
//    /// Get vaccination records for a specific baby
//    func getVaccineRecordsForBaby(babyId: UUID) async throws -> [VacciAlertRecord] {
//        guard let supabase = supabase else {
//            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
//        }
//        
//        let response = try await supabase.from("Vaccination_table")
//            .select()
//            .eq("baby_id", value: babyId.uuidString)
//            .execute()
//        
//        // Fix: data is not optional, so we access it directly
//        let data = response.data
//        
//        let decoder = JSONDecoder()
//        do {
//            let records = try decoder.decode([VacciAlertRecord].self, from: data)
//            print("✅ Retrieved \(records.count) vaccination records for baby: \(babyId.uuidString)")
//            return records
//        } catch {
//            print("❌ Error decoding vaccine records: \(error)")
//            return []
//        }
//    }
//    
//    /// Update an existing vaccination record
//    func updateVaccineRecord(_ record: VacciAlertRecord) async throws {
//        guard let supabase = supabase else {
//            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
//        }
//        
//        try await supabase.from("Vaccination_table")
//            .update(record)
//            .eq("id", value: record.id.uuidString)
//            .execute()
//        
//        print("✅ Updated vaccination record: \(record.id.uuidString)")
//    }
//    
//    /// Delete a vaccination record
//    func deleteVaccineRecord(id: UUID) async throws {
//        guard let supabase = supabase else {
//            throw NSError(domain: "VacciAlertError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
//        }
//        
//        try await supabase.from("Vaccination_table")
//            .delete()
//            .eq("id", value: id.uuidString)
//            .execute()
//        
//        print("✅ Deleted vaccination record: \(id.uuidString)")
//    }
//}
//
//// MARK: - Baby Extensions
//
///// Extensions to the Baby class for vaccination features
//extension Baby {
//    /// Get a vaccine tracker for this baby
//    func getVaccineTracker() -> BabyVaccineTracker {
//        return BabyVaccineTracker(baby: self)
//    }
//    
//    /// Get the baby's age in months
//    func getAge() -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        guard let dob = dateFormatter.date(from: self.dateOfBirth) else { return 0 }
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.month], from: dob, to: Date())
//        return components.month ?? 0
//    }
//}
