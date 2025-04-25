import Foundation
import UIKit
import CoreLocation
import Supabase

class SupabaseVaccineManager {
    static let shared = SupabaseVaccineManager()
    
    // Use your existing Supabase client setup
    private var client: SupabaseClient? {
        // Assuming you have the client configured in your AppDelegate or SceneDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        
        // Fallback to direct client initialization if needed
        return SupabaseClient(
            supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
        )
    }
    
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
            vaccine_id: schedule.vaccine_id,
            schedule_id: scheduleId,
            administered_date: ISO8601DateFormatter().string(from: administeredDate)
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
        
        let response = try await client
            .from("administered_vaccines")
            .select()
            .eq("baby_id", value: babyId)
            .execute()
        
        // Process the raw data to convert to VaccineAdministered objects
        let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: response.data)
        
        return rawAdministered.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: raw.administered_date) ?? Date()
            
            return VaccineAdministered(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                scheduleId: UUID(uuidString: raw.schedule_id) ?? UUID(),
                administeredDate: date
            )
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
    let vaccine_id: String
    let schedule_id: String
    let administered_date: String
}


