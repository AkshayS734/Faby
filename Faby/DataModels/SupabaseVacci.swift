import Foundation
import UIKit
import CoreLocation
import Supabase

class SupabaseVaccineManager {
    static let shared = SupabaseVaccineManager()
    
    // Use your existing Supabase client setup
    private var client: SupabaseClient? {
        // Get the client from AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        }
        return nil
    }
    
    private init() {} // Private initializer for singleton pattern
    
    // MARK: - Vaccine Management
    
    /// Fetch all vaccines from Supabase
    func fetchAllVaccines() async throws -> [Vaccine] {
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
        
        // Then get baby's age (using a direct query instead of relying on Baby model)
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
    
    /// Fetch overdue vaccines (scheduled for yesterday or earlier)
    func fetchOverdueVaccines() async throws -> [(VaccineSchedule, String)] {
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // Get all scheduled vaccines
        let response = try await client
            .from("vaccination_schedules")
            .select()
            .eq("is_administered", value: false)
            .execute()
        
        // Convert response to VaccineSchedule objects
        let decoder = JSONDecoder()
        let rawSchedules = try decoder.decode([SupabaseVaccineSchedule].self, from: response.data)
        
        // Filter to find overdue vaccines (scheduled for yesterday or earlier)
        let today = Calendar.current.startOfDay(for: Date())
        var overdueVaccines: [(VaccineSchedule, String)] = []
        
        for rawSchedule in rawSchedules {
            let dateFormatter = ISO8601DateFormatter()
            if let scheduledDate = dateFormatter.date(from: rawSchedule.date) {
                // Check if the date is in the past (before today)
                if Calendar.current.startOfDay(for: scheduledDate) < today {
                    let schedule = VaccineSchedule(
                        id: UUID(uuidString: rawSchedule.id) ?? UUID(),
                        babyID: UUID(uuidString: rawSchedule.baby_id) ?? UUID(),
                        vaccineId: UUID(uuidString: rawSchedule.vaccine_id) ?? UUID(),
                        hospital: rawSchedule.hospital,
                        date: scheduledDate,
                        location: rawSchedule.location,
                        isAdministered: rawSchedule.is_administered
                    )
                    
                    // Fetch the vaccine name
                    let allVaccines = try await self.fetchAllVaccines()
                    var vaccineName = "Unknown Vaccine"
                    
                    if let vaccine = allVaccines.first(where: { $0.id == schedule.vaccineId }) {
                        vaccineName = vaccine.name
                    }
                    
                    overdueVaccines.append((schedule, vaccineName))
                }
            }
        }
        
        return overdueVaccines
    }
    
    /// Fetch all scheduled vaccinations for a specific baby
    func fetchVaccineSchedules(forBabyId babyId: String) async throws -> [VaccineSchedule] {
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // First fetch the existing schedule
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        print("DEBUG: SupabaseVaccineManager - Saving \(vaccines.count) administered vaccines for baby ID: \(babyId)")
        
        // Create administered vaccine records for each vaccine
        for vaccine in vaccines {
            // Variables for the new record
            let vaccineId = UUID().uuidString
            let babyIdString = babyId.uuidString
            let vaccineIdString = vaccine.id.uuidString
            var administeredDateString: String? = nil
            
            // Check if user has selected a date for this vaccine
            if let selectedDate = administeredDates[vaccine.name] {
                // User selected a date - use it
                print("DEBUG: Using user-selected date for \(vaccine.name): \(selectedDate)")
                administeredDateString = ISO8601DateFormatter().string(from: selectedDate)
            } else {
                // User did not select a date - don't send a date to backend
                print("DEBUG: No date selected for \(vaccine.name) - not sending a date")
            }
            
            // Create the administered vaccine record
            let administeredVaccine = SupabaseVaccineAdministered(
                id: vaccineId,
                baby_id: babyIdString,
                vaccineID: vaccineIdString,
                scheduleId: nil, // No schedule for manually entered vaccines
                administeredDate: administeredDateString // This will be nil if no date was selected
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        print("DEBUG: Fetching administered vaccines for baby ID: \(babyId)")
        
        let response = try await client
            .from("administered_vaccines")
            .select()
            .eq("baby_id", value: babyId)
            .execute()
        
        print("DEBUG: Retrieved \(response.data.count) bytes of administered vaccines data")
        
        // Process the raw data to convert to VaccineAdministered objects
        let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: response.data)
        
        print("DEBUG: Decoded \(rawAdministered.count) administered vaccines")
        
        return rawAdministered.map { raw in
            // Print the raw date string for debugging
            print("DEBUG: Raw administered date string: \(raw.administeredDate ?? "nil")")
            
            // Determine if this vaccine has a date based on the string's existence and content
            let hasActualDate = raw.administeredDate != nil && !raw.administeredDate!.isEmpty
            
            // Check if we have a date string
            if hasActualDate, let dateString = raw.administeredDate {
                print("DEBUG: Attempting to parse date: \(dateString)")
                
                // Create multiple date formatters to try different formats
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let altFormatter1 = DateFormatter()
                altFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                let altFormatter2 = DateFormatter()
                altFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                let altFormatter3 = DateFormatter()
                altFormatter3.dateFormat = "yyyy-MM-dd"
                
                // Add new formatter for the specific format we're seeing
                let altFormatter4 = DateFormatter()
                altFormatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                // Try multiple date formats
                let date: Date
                if let parsedDate = iso8601Formatter.date(from: dateString) {
                    print("DEBUG: Successfully parsed with ISO8601Formatter")
                    date = parsedDate
                } else if let parsedDate = altFormatter1.date(from: dateString) {
                    print("DEBUG: Successfully parsed with altFormatter1")
                    date = parsedDate
                } else if let parsedDate = altFormatter2.date(from: dateString) {
                    print("DEBUG: Successfully parsed with altFormatter2")
                    date = parsedDate
                } else if let parsedDate = altFormatter3.date(from: dateString) {
                    print("DEBUG: Successfully parsed with altFormatter3")
                    date = parsedDate
                } else if let parsedDate = altFormatter4.date(from: dateString) {
                    print("DEBUG: Successfully parsed with altFormatter4")
                    date = parsedDate
                } else {
                    print("DEBUG: Failed to parse date string: \(dateString), using fallback date")
                    // Try one more approach - manually parse the string
                    let components = dateString.components(separatedBy: ["T", ":", "-"])
                    if components.count >= 6 {
                        let year = Int(components[0]) ?? 0
                        let month = Int(components[1]) ?? 0
                        let day = Int(components[2]) ?? 0
                        let hour = Int(components[3]) ?? 0
                        let minute = Int(components[4]) ?? 0
                        let second = Int(components[5]) ?? 0
                        
                        var dateComponents = DateComponents()
                        dateComponents.year = year
                        dateComponents.month = month
                        dateComponents.day = day
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        dateComponents.second = second
                        
                        if let manualDate = Calendar.current.date(from: dateComponents) {
                            print("DEBUG: Successfully parsed with manual components")
                            date = manualDate
                        } else {
                            date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                        }
                    } else {
                        date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                    }
                }
                
                let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
                
                return VaccineAdministered(
                    id: UUID(uuidString: raw.id) ?? UUID(),
                    babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                    vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                    scheduleId: scheduleUUID,
                    administeredDate: date,
                    hasDate: true  // We successfully parsed a date
                )
            } else {
                print("DEBUG: No date string available, creating a vaccine without date")
                let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
                
                return VaccineAdministered(
                    id: UUID(uuidString: raw.id) ?? UUID(),
                    babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                    vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                    scheduleId: scheduleUUID,
                    administeredDate: Date(), // Placeholder date
                    hasDate: false // No date was selected
                )
            }
        }
    }
    
    /// Fetch all administered vaccines (not filtered by baby)
    func fetchAllAdministeredVaccines() async throws -> [VaccineAdministered] {
        print("DEBUG: SupabaseVaccineManager - About to query administered_vaccines table")
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        do {
            let response = try await client
                .from("administered_vaccines")
                .select()
                .execute()
            
            print("DEBUG: SupabaseVaccineManager - Query successful, data size: \(response.data.count) bytes")
            
            // Process the raw data to convert to VaccineAdministered objects
            do {
                let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: response.data)
                print("DEBUG: SupabaseVaccineManager - Decoded \(rawAdministered.count) administered vaccines")
                
                let result = rawAdministered.map { raw in
                    // Print the raw date string for debugging
                    print("DEBUG: Raw administered date string: \(raw.administeredDate ?? "nil")")
                    
                    // Determine if this vaccine has a date based on the string's existence and content
                    let hasActualDate = raw.administeredDate != nil && !raw.administeredDate!.isEmpty
                    
                    // Check if we have a date string
                    if hasActualDate, let dateString = raw.administeredDate {
                        print("DEBUG: Attempting to parse date: \(dateString)")
                        
                        // Create multiple date formatters to try different formats
                        let iso8601Formatter = ISO8601DateFormatter()
                        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        
                        let altFormatter1 = DateFormatter()
                        altFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        
                        let altFormatter2 = DateFormatter()
                        altFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        
                        let altFormatter3 = DateFormatter()
                        altFormatter3.dateFormat = "yyyy-MM-dd"
                        
                        // Add new formatter for the specific format we're seeing
                        let altFormatter4 = DateFormatter()
                        altFormatter4.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        
                        // Try multiple date formats
                        let date: Date
                        if let parsedDate = iso8601Formatter.date(from: dateString) {
                            print("DEBUG: Successfully parsed with ISO8601Formatter")
                            date = parsedDate
                        } else if let parsedDate = altFormatter1.date(from: dateString) {
                            print("DEBUG: Successfully parsed with altFormatter1")
                            date = parsedDate
                        } else if let parsedDate = altFormatter2.date(from: dateString) {
                            print("DEBUG: Successfully parsed with altFormatter2")
                            date = parsedDate
                        } else if let parsedDate = altFormatter3.date(from: dateString) {
                            print("DEBUG: Successfully parsed with altFormatter3")
                            date = parsedDate
                        } else if let parsedDate = altFormatter4.date(from: dateString) {
                            print("DEBUG: Successfully parsed with altFormatter4")
                            date = parsedDate
                        } else {
                            print("DEBUG: Failed to parse date string: \(dateString), using fallback date")
                            // Try one more approach - manually parse the string
                            let components = dateString.components(separatedBy: ["T", ":", "-"])
                            if components.count >= 6 {
                                let year = Int(components[0]) ?? 0
                                let month = Int(components[1]) ?? 0
                                let day = Int(components[2]) ?? 0
                                let hour = Int(components[3]) ?? 0
                                let minute = Int(components[4]) ?? 0
                                let second = Int(components[5]) ?? 0
                                
                                var dateComponents = DateComponents()
                                dateComponents.year = year
                                dateComponents.month = month
                                dateComponents.day = day
                                dateComponents.hour = hour
                                dateComponents.minute = minute
                                dateComponents.second = second
                                
                                if let manualDate = Calendar.current.date(from: dateComponents) {
                                    print("DEBUG: Successfully parsed with manual components")
                                    date = manualDate
                                } else {
                                    date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                                }
                            } else {
                                date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                            }
                        }
                        
                        let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
                        
                        return VaccineAdministered(
                            id: UUID(uuidString: raw.id) ?? UUID(),
                            babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                            vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                            scheduleId: scheduleUUID,
                            administeredDate: date,
                            hasDate: true
                        )
                    } else {
                        print("DEBUG: No date string available, creating a vaccine without date")
                        let scheduleUUID: UUID? = raw.scheduleId != nil ? UUID(uuidString: raw.scheduleId!) : nil
                        
                        return VaccineAdministered(
                            id: UUID(uuidString: raw.id) ?? UUID(),
                            babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                            vaccineId: UUID(uuidString: raw.vaccineID) ?? UUID(),
                            scheduleId: scheduleUUID,
                            administeredDate: Date(), // Placeholder date
                            hasDate: false // No date was selected
                        )
                    }
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
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
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
    
    /// Update or remove the administered date for a vaccine
    /// - Parameters:
    ///   - vaccineId: The ID of the administered vaccine to update
    ///   - newDate: The new date to set (or nil to remove the date)
    /// - Throws: An error if the update fails
    func updateAdministeredVaccineDate(vaccineId: String, newDate: Date?) async throws {
        guard let client = client else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // Update the record in Supabase
        do {
            if let date = newDate {
                // Convert date to ISO8601 string format
                let dateFormatter = ISO8601DateFormatter()
                let dateString = dateFormatter.string(from: date)
                
                // Create a properly encodable struct without has_date
                let updatePayload = VaccineDateUpdate(administeredDate: dateString)
                
                print("DEBUG: Updating vaccine \(vaccineId) with date: \(dateString)")
                
                let _ = try await client
                    .from("administered_vaccines")
                    .update(updatePayload)
                    .eq("id", value: vaccineId)
                    .execute()
            } else {
                // Use a dedicated struct for date removal (without has_date)
                let removalPayload = VaccineDateRemoval()
                
                print("DEBUG: Removing date for vaccine \(vaccineId)")
                
                let _ = try await client
                    .from("administered_vaccines")
                    .update(removalPayload)
                    .eq("id", value: vaccineId)
                    .execute()
            }
            
            // Notify listeners about the update
            await MainActor.run {
                NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
            }
            print("DEBUG: Successfully updated administered vaccine date")
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
        // Removed has_date as it doesn't exist in the database
    }
}

// Update the VaccineDateUpdate and VaccineDateRemoval structs
struct VaccineDateUpdate: Encodable {
    let administeredDate: String
    // Removed has_date field since it doesn't exist in the database
}

struct VaccineDateRemoval: Encodable {
    // Using null for the date in Supabase
    // We're using a special encoding strategy to make this null in JSON
    let administeredDate: String?
    
    init() {
        self.administeredDate = nil
    }
}


