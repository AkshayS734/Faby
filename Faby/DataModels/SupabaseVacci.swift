import Foundation
import UIKit
import CoreLocation
import Supabase

class SupabaseVaccineManager {
    static var shared: SupabaseVaccineManager!

    let client: SupabaseClient

    private init(client: SupabaseClient) {
        self.client = client
    }

    static func initialize(client: SupabaseClient) {
        self.shared = SupabaseVaccineManager(client: client)
    }
    // Use your existing Supabase client setup
//    private var client: SupabaseClient? {
//        // Assuming you have the client configured in your AppDelegate or SceneDelegate
//        DispatchQueue.main.sync {
//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    client = appDelegate.supabase
//                } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//                    client = sceneDelegate.supabase
//                }
//            }
//
//        
//        // Fallback to direct client initialization if needed
//        return SupabaseClient(
//            supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
//            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
//        )
//    }
    
    // MARK: - Vaccine Management
    
    /// Fetch all vaccines from Supabase
    func fetchAllVaccines() async throws -> [Vaccine] {
        
        let response = try await client
            .from("vaccines")
            .select()
            .execute()
        
        return try JSONDecoder().decode([Vaccine].self, from: response.data)
    }
    
    /// Fetch vaccines recommended for a specific baby based on age
    func fetchRecommendedVaccines(forBabyId babyId: String) async throws -> [Vaccine] {
        // First fetch all vaccines
        let allVaccines = try await fetchAllVaccines()
        let babyResponse = try await client
            .from("baby")
            .select("dob")
            .eq("uid", value: babyId)
            .single()
            .execute()
        
        // Manually extract date of birth from response data
        guard let babyData = try? JSONSerialization.jsonObject(with: babyResponse.data, options: []) as? [String: Any],
              let dateOfBirthString = babyData["dateOfBirth"] as? String else {
            throw NSError(domain: "VacciAlertError", code: 3,
                         userInfo: [NSLocalizedDescriptionKey: "Unable to extract baby data"])
        }
        
        // Calculate age in months
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dob = dateFormatter.date(from: dateOfBirthString) else {
            throw NSError(domain: "VacciAlertError", code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid date of birth"])
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.month], from: dob, to: Date())
        let ageInMonths = ageComponents.month ?? 0
        
        // Filter vaccines based on age
        return allVaccines.filter { vaccine in
            let minMonth = vaccine.startWeek / 4
            let maxMonth = vaccine.endWeek / 4
            return ageInMonths >= minMonth && ageInMonths <= maxMonth
        }
    }
    
    // MARK: - Vaccine Schedule Management
    
    /// Save a new vaccination schedule to Supabase
    func saveVaccineSchedule(babyId: String, vaccineId: String, hospital: String, date: Date, location: CLLocation) async throws {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let locationString = "\(latitude),\(longitude)"
        
        let scheduleId = UUID().uuidString
        
        // Create Encodable struct instead of dictionary
        let schedule = SupabaseVaccineSchedule(
            id: scheduleId,
            baby_id: babyId,
            vaccine_id: vaccineId,
            hospital: hospital,
            date: ISO8601DateFormatter().string(from: date),
            location: locationString,
            is_administered: false
        )
        
        try await client
            .from("vaccination_schedules")
            .insert(schedule)
            .execute()
        
        // Notify listeners about the new schedule
        await MainActor.run {
            NotificationCenter.default.post(name: .newVaccineScheduled, object: nil)
        }
    }
    
    /// Fetch all scheduled vaccinations for a specific baby
    func fetchVaccineSchedules(forBabyId babyId: String) async throws -> [VaccineSchedule] {
        let response = try await client
            .from("vaccination_schedules")
            .select()
            .eq("baby_id", value: babyId)
            .execute()
        
        // Process the raw data to convert to VaccineSchedule objects
        let rawSchedules = try JSONDecoder().decode([SupabaseVaccineSchedule].self, from: response.data)
        
        return rawSchedules.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: raw.date) ?? Date()
            
            return VaccineSchedule(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyID: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                hospital: raw.hospital,
                date: date,
                location: raw.location,
                isAdministered: raw.is_administered
            )
        }
    }
    
    /// Update an existing vaccination schedule
    func updateVaccineSchedule(scheduleId: String, newDate: Date?, newHospital: String?, newLocation: CLLocation?) async throws {
        let response = try await client
            .from("vaccination_schedules")
            .select()
            .eq("id", value: scheduleId)
            .single()
            .execute()
        
        var schedule = try JSONDecoder().decode(SupabaseVaccineSchedule.self, from: response.data)
        
        // Update fields
        if let date = newDate {
            schedule.date = ISO8601DateFormatter().string(from: date)
        }
        
        if let hospital = newHospital {
            schedule.hospital = hospital
        }
        
        if let location = newLocation {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            schedule.location = "\(latitude),\(longitude)"
        }
        
        // Save updates
        try await client
            .from("vaccination_schedules")
            .update(schedule)
            .eq("id", value: scheduleId)
            .execute()
        
        // Notify listeners about the update
        await MainActor.run {
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        }
    }
    
    // MARK: - Administered Vaccines Management
    
    /// Save administered vaccines directly (for manually entered vaccines)
    /// - Parameters:
    ///   - vaccines: Array of vaccines to save as administered
    ///   - babyId: The UUID of the baby who received the vaccines
    ///   - administeredDates: Dictionary mapping vaccine names to administered dates
    /// - Throws: An error if saving fails
    func saveAdministeredVaccines(vaccines: [Vaccine], babyId: UUID, administeredDates: [String: Date]) async throws {
        
        print("DEBUG: SupabaseVaccineManager - Saving \(vaccines.count) administered vaccines for baby ID: \(babyId)")
        
        // Create administered vaccine records for each vaccine
        for vaccine in vaccines {
            // Variables for the new record
            let recordId = UUID().uuidString
            let babyIdString = babyId.uuidString
            let vaccineIdString = vaccine.id.uuidString
            var administeredDateString: String? = nil
            
            // Check if user has selected a date for this vaccine
            if let selectedDate = administeredDates[vaccine.name] {
                // User selected a date - use it
                print("DEBUG: Using user-selected date for \(vaccine.name): \(selectedDate)")
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                administeredDateString = formatter.string(from: selectedDate)
            } else {
                // User did not select a date - don't send any date to backend
                print("DEBUG: No date selected for \(vaccine.name) - not sending a date")
                administeredDateString = nil
            }
            
            // Create the administered vaccine record
            let administeredVaccine = SupabaseVaccineAdministered(
                id: recordId,
                baby_id: babyIdString,
                vaccineID: vaccineIdString,
                scheduleId: nil, // No schedule for manually entered vaccines
                administeredDate: administeredDateString
            )
            
            try await client
                .from("administered_vaccines")
                .insert(administeredVaccine)
                .execute()
            
            print("DEBUG: SupabaseVaccineManager - Saved administered vaccine: \(vaccine.name)")
            if let dateStr = administeredDateString {
                print("DEBUG: With date: \(dateStr)")
            } else {
                print("DEBUG: Without date (date not selected by user)")
            }
        }
        
        // Notify listeners about the update
        await MainActor.run {
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        }
    }
    
    /// Mark a vaccine as administered
    func markVaccineAsAdministered(scheduleId: String, administeredDate: Date) async throws {
        
        // First get the schedule details
        let scheduleResponse = try await client
            .from("vaccination_schedules")
            .select()
            .eq("id", value: scheduleId)
            .single()
            .execute()
        
        let schedule = try JSONDecoder().decode(SupabaseVaccineSchedule.self, from: scheduleResponse.data)
        
        // Create a new administered vaccine record
        let administeredVaccine = SupabaseVaccineAdministered(
            id: UUID().uuidString,
            baby_id: schedule.baby_id,
            vaccineID: schedule.vaccine_id,
            scheduleId: scheduleId,
            administeredDate: ISO8601DateFormatter().string(from: administeredDate)
        )
        
        try await client
            .from("administered_vaccines")
            .insert(administeredVaccine)
            .execute()
        
        // Update the schedule to mark it as administered
        var updatedSchedule = schedule
        updatedSchedule.is_administered = true
        
        try await client
            .from("vaccination_schedules")
            .update(updatedSchedule)
            .eq("id", value: scheduleId)
            .execute()
        
        // Notify listeners about the update
        await MainActor.run {
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        }
    }
    
    /// Fetch all administered vaccines for a specific baby
    func fetchAdministeredVaccines(forBabyId babyId: String) async throws -> [VaccineAdministered] {
        
        let response = try await client
            .from("administered_vaccines")
            .select()
            .eq("baby_id", value: babyId)
            .execute()
        
        // Process the raw data to convert to VaccineAdministered objects
        let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: response.data)
        
        return rawAdministered.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            
            // Handle the optional administeredDate
            let date: Date
            if let dateString = raw.administeredDate, !dateString.isEmpty {
                date = dateFormatter.date(from: dateString) ?? Date()
            } else {
                // If no date was provided, use nil (this will be handled by the VaccineAdministered initializer)
                date = Date() // Default to current date if parsing fails
            }
            
            let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
            
            return VaccineAdministered(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                scheduleId: scheduleUUID,
                administeredDate: date
            )
        }
    }
    
    /// Fetch all administered vaccines (not filtered by baby)
    func fetchAllAdministeredVaccines() async throws -> [VaccineAdministered] {
        print("DEBUG: SupabaseVaccineManager - About to query administered_vaccines table")
        do {
            let response = try await client
                .from("administered_vaccines")
                .select()
                .execute()
            
            print("DEBUG: SupabaseVaccineManager - Query successful, data size: \(response.data.count) bytes")
            
            // Print raw data for debugging
            if let jsonString = String(data: response.data, encoding: .utf8) {
                print("DEBUG: SupabaseVaccineManager - Raw JSON: \(jsonString)")
            }
            
            // Process the raw data to convert to VaccineAdministered objects
            do {
                let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: response.data)
                print("DEBUG: SupabaseVaccineManager - Decoded \(rawAdministered.count) administered vaccines")
                
                let result = rawAdministered.map { raw in
                    let dateFormatter = ISO8601DateFormatter()
                    
                    // Handle the optional administeredDate
                    let date: Date
                    if let dateString = raw.administeredDate, !dateString.isEmpty {
                        date = dateFormatter.date(from: dateString) ?? Date()
                    } else {
                        // If no date was provided, use nil (this will be handled by the VaccineAdministered initializer)
                        date = Date() // Default to current date if parsing fails
                    }
                    
                    let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
                    
                    return VaccineAdministered(
                        id: UUID(uuidString: raw.id) ?? UUID(),
                        babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                        vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                        scheduleId: scheduleUUID,
                        administeredDate: date
                    )
                }
                
                print("DEBUG: SupabaseVaccineManager - Returned \(result.count) VaccineAdministered objects")
                return result
            } catch {
                print("DEBUG: SupabaseVaccineManager - JSON decoding error: \(error)")
                throw error
            }
        } catch {
            print("DEBUG: SupabaseVaccineManager - Supabase query error: \(error)")
            throw error
        }
    }
    
    /// Update the administered date for a vaccine
    /// - Parameters:
    ///   - scheduleId: The UUID string of the schedule
    ///   - newDate: The new administered date
    /// - Throws: An error if the update fails
    func updateAdministeredDate(scheduleId: String, newDate: Date) async throws {
        
        // Convert date to ISO8601 string format
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: newDate)
        
        // Create a struct that conforms to Encodable for the update
        struct UpdateDatePayload: Encodable {
            let administereddate: String
        }
        
        // Create the payload with the new date
        let updatePayload = UpdateDatePayload(administereddate: dateString)
        
        // Update the record in Supabase
        do {
            let _ = try await client
                .from("administered_vaccines")
                .update(updatePayload)
                .eq("scheduleId", value: scheduleId)
                .execute()
            
            // Notify listeners about the update
            NotificationCenter.default.post(name: Notification.Name("VaccinesUpdated"), object: nil)
            
        } catch {
            print("ERROR: Failed to update administered date - \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Supabase-compatible Data Structures

// These structures match Supabase table schemas and are used for encoding/decoding
struct SupabaseVaccineSchedule: Codable {
    let id: String
    let baby_id: String
    let vaccine_id: String
    var hospital: String
    var date: String
    var location: String
    var is_administered: Bool
}

struct SupabaseVaccineAdministered: Codable {
    let id: String
    let baby_id: String
    let vaccineID: String  // This matches the actual JSON field name "vaccineID"
    let scheduleId: String? // Optional - This matches the actual JSON field name "scheduleId"
    let administeredDate: String? // Modified to be optional to allow for no date selection
    
    // CodingKeys to map between Swift property names and database column names
    enum CodingKeys: String, CodingKey {
        case id
        case baby_id
        case vaccineID // Exact match with field name in JSON
        case scheduleId // Exact match with field name in JSON
        case administeredDate // Exact match with field name in JSON
    }
}


