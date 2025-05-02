//
//  DataControllerFile.swift
//  Faby
//
//  Created by Adarsh Mishra on 22/04/25.
//
import Foundation
import UIKit
import CoreLocation
import Supabase
import MapKit

// MARK: - Vaccines (Fetch)
class FetchingVaccines{
    static let shared = FetchingVaccines()
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    /// Fetch all available vaccines from database
    func fetchAllVaccines() async throws -> [Vaccine] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // Update to use correct table name "vaccines" (lowercase) as used in SupabaseVaccineManager
        let response = try await supabase.from("vaccines")
            .select()
            .execute()
        
        let data = response.data
        let decoder = JSONDecoder()
        return try decoder.decode([Vaccine].self, from: data)
    }
    
    /// Fetch vaccines appropriate for a baby's age
    func fetchRecommendedVaccines(forBaby baby: Baby) async throws -> [Vaccine] {
        // First fetch all vaccines
        let allVaccines = try await fetchAllVaccines()
        
        // Calculate age in months - preserving your original method of using the Baby object
        let ageInMonths = baby.getAge()
        
        // Filter vaccines based on age - matching the logic from SupabaseVaccineManager
        return allVaccines.filter { vaccine in
            let minMonth = vaccine.startWeek / 4
            let maxMonth = vaccine.endWeek / 4
            return ageInMonths >= minMonth && ageInMonths <= maxMonth
        }
    }
    
    /// Helper function to get Supabase client
    private func getSupabaseClient() -> SupabaseClient? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        return nil
    }
}

// MARK: - Vaccine Schedule (Save, Fetch, Update)

class VaccineScheduleManager {
    static let shared = VaccineScheduleManager()
    
    /// Save a new vaccination schedule
    func saveSchedule(babyId: UUID, vaccineId: UUID,
                      hospital: String, date: Date,
                      location: String) async throws {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // Validate required fields
        guard !hospital.isEmpty, !location.isEmpty else {
            throw NSError(domain: "VacciAlertError", code: 2,
                         userInfo: [NSLocalizedDescriptionKey: "Hospital and location are required"])
        }
        
        // Check for existing schedule to prevent duplicates
        let existingSchedules = try await fetchSchedules(forBaby: babyId)
        if existingSchedules.contains(where: { $0.vaccineId == vaccineId && !$0.isAdministered }) {
            throw NSError(domain: "VacciAlertError", code: 3,
                         userInfo: [NSLocalizedDescriptionKey: "This vaccine is already scheduled"])
        }
        
        // Create record with the structure needed for the vaccination_schedules table
        let record = VaccineSchedule(
            id: UUID(),
            babyID: babyId,
            vaccineId: vaccineId,
            hospital: hospital,
            date: date,
            location: location,
            isAdministered: false
        )

        try await supabase.from("vaccination_schedules")
            .insert(record)
            .execute()
        
        // Notify listeners only after successful save
        await MainActor.run {
            NotificationCenter.default.post(name: .newVaccineScheduled, object: nil)
        }
    }
    
    /// Fetch all scheduled vaccinations for a baby
    func fetchSchedules(forBaby babyId: UUID) async throws -> [VaccineSchedule] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("vaccination_schedules")
            .select()
            .eq("baby_id", value: babyId.uuidString)
            .execute()
        
        let data = response.data
        let rawSchedules = try JSONDecoder().decode([SupabaseVaccineSchedule].self, from: data)
        
        return rawSchedules.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let scheduledDate = dateFormatter.date(from: raw.date) ?? Date()
            
            return VaccineSchedule(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyID: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                hospital: raw.hospital,
                date: scheduledDate,
                location: raw.location,
                isAdministered: raw.is_administered
            )
        }
    }

    /// Fetch all scheduled vaccinations for all babies
    func fetchAllSchedules() async throws -> [VaccineSchedule] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        let response = try await supabase.from("vaccination_schedules")
            .select()
            .execute()
        let data = response.data
        let rawSchedules = try JSONDecoder().decode([SupabaseVaccineSchedule].self, from: data)
        return rawSchedules.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let scheduledDate = dateFormatter.date(from: raw.date) ?? Date()
            return VaccineSchedule(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyID: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                hospital: raw.hospital,
                date: scheduledDate,
                location: raw.location,
                isAdministered: raw.is_administered
            )
        }
    }
    
    /// Update an existing vaccination schedule
    func updateSchedule(recordId: UUID, newDate: Date, newHospital: Hospital? = nil) async throws {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // First fetch the existing record
        let response = try await supabase.from("vaccination_schedules")
            .select()
            .eq("id", value: recordId.uuidString)
            .single()
            .execute()
        
        var schedule = try JSONDecoder().decode(SupabaseVaccineSchedule.self, from: response.data)
        
        let dateFormatter = ISO8601DateFormatter()
        schedule.date = dateFormatter.string(from: newDate)
        
        if let hospital = newHospital {
            schedule.hospital = hospital.name
            schedule.location = hospital.address
        }
        
        try await supabase.from("vaccination_schedules")
            .update(schedule)
            .eq("id", value: recordId.uuidString)
            .execute()
        
        await MainActor.run {
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        }
    }
    
    /// Helper function to get Supabase client
    private func getSupabaseClient() -> SupabaseClient? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        return nil
    }
}

// MARK: - Administered Vaccines (Add, Fetch)

class AdministeredVaccineManager {
    static let shared = AdministeredVaccineManager()
    
    /// Add a new administered vaccine record
    func addAdministeredVaccine(babyId: UUID, vaccineId: UUID, scheduleId: UUID,
                               date: Date, location: String) async throws {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let administeredDateString = dateFormatter.string(from: date)
        
        let record = [
            "id": UUID().uuidString,
            "baby_id": babyId.uuidString,
            "vaccine_id": vaccineId.uuidString,
            "schedule_id": scheduleId.uuidString,
            "administered_date": administeredDateString
        ]
        
        try await supabase.from("administered_vaccines")
            .insert(record)
            .execute()
        
        try await supabase.from("vaccination_schedules")
            .update(["is_administered": true])
            .eq("id", value: scheduleId.uuidString)
            .execute()
        
        await MainActor.run {
            NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
        }
    }
    
    /// Fetch all administered vaccines for a baby
    func fetchAdministeredVaccines(forBaby babyId: UUID) async throws -> [VaccineAdministered] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("administered_vaccines")
            .select()
            .eq("baby_id", value: babyId.uuidString)
            .execute()
        
        let data = response.data
        let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: data)
        
        return rawAdministered.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let administeredDate = dateFormatter.date(from: raw.administered_date) ?? Date()
            
            return VaccineAdministered(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                scheduleId: UUID(uuidString: raw.schedule_id) ?? UUID(),
                administeredDate: administeredDate
            )
        }
    }

    /// Fetch all administered vaccines for all babies
    func fetchAllAdministeredVaccines() async throws -> [VaccineAdministered] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        let response = try await supabase.from("administered_vaccines")
            .select()
            .execute()
        let data = response.data
        let rawAdministered = try JSONDecoder().decode([SupabaseVaccineAdministered].self, from: data)
        return rawAdministered.map { raw in
            let dateFormatter = ISO8601DateFormatter()
            let administeredDate = dateFormatter.date(from: raw.administered_date) ?? Date()
            return VaccineAdministered(
                id: UUID(uuidString: raw.id) ?? UUID(),
                babyId: UUID(uuidString: raw.baby_id) ?? UUID(),
                vaccineId: UUID(uuidString: raw.vaccine_id) ?? UUID(),
                scheduleId: UUID(uuidString: raw.schedule_id) ?? UUID(),
                administeredDate: administeredDate
            )
        }
    }
    
    /// Helper function to get Supabase client
    private func getSupabaseClient() -> SupabaseClient? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        return nil
    }
}

// MARK: - Helper Extensions

extension Baby {
    func getAge() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dob = dateFormatter.date(from: self.dateOfBirth) else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dob, to: Date())
        return components.month ?? 0
    }
}

// MARK: - Hospital Search Manager
class HospitalSearchManager {
    static let shared = HospitalSearchManager()
    private let locationManager = LocationManager()
    
    // Find hospitals near a specific location
    func findNearbyHospitals(completion: @escaping ([Hospital]) -> Void) {
        // Set up success callback
        locationManager.onLocationUpdate = { [weak self] location in
            self?.searchHospitals(near: location, completion: completion)
        }
        
        // Set up error callback
        locationManager.onLocationError = { error in
            print("❌ Location error: \(error.localizedDescription)")
            completion([])
        }
        
        // Set up permission denied callback
        locationManager.onPermissionDenied = {
            print("❌ Location permission denied")
            completion([])
        }
        
        // Request location
        locationManager.requestLocation()
    }
    
    // Search for hospitals using the user's location
    private func searchHospitals(near location: CLLocation, completion: @escaping ([Hospital]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "hospital"
        request.region = MKCoordinateRegion(center: location.coordinate,
                                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("❌ Error searching for hospitals: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            // Convert map items to Hospital objects
            let hospitals = response.mapItems.map { item -> Hospital in
                let distance = location.distance(from: item.placemark.location ?? location) / 1000 // in km
                
                // Get current baby ID (defaulting to a new UUID if not available)
                let babyId = UserDefaultsManager.shared.currentBabyId ?? (BabyDataModel.shared.babyList.first?.babyID ?? UUID())
                
                return Hospital(
                    babyId: babyId,
                    name: item.name ?? "Unknown Hospital",
                    address: self.formatAddress(from: item.placemark),
                    distance: distance,
                    coordinates: item.placemark.coordinate
                )
            }
            
            // Sort by distance
            let sortedHospitals = hospitals.sorted { $0.distance < $1.distance }
            completion(sortedHospitals)
        }
    }
    
    // Helper method to format address from placemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

// Helper for managing current baby ID
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    var currentBabyId: UUID? {
        get {
            guard let uuidString = UserDefaults.standard.string(forKey: "currentBabyId") else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set {
            UserDefaults.standard.set(newValue?.uuidString, forKey: "currentBabyId")
        }
    }
}

extension Notification.Name {
    static let vaccinesUpdated = Notification.Name("vaccinesUpdated")
    static let newVaccineScheduled = Notification.Name("NewVaccineScheduled")
}

//// MARK: - Supabase-compatible Data Structures
//// Added these structures to match Supabase table schemas for encoding/decoding
//
//struct SupabaseVaccineSchedule: Codable {
//    let id: String
//    let baby_id: String
//    let vaccine_id: String
//    var hospital: String
//    var date: String
//    var location: String
//    var is_administered: Bool
//}
//
//struct SupabaseVaccineAdministered: Codable {
//    let id: String
//    let baby_id: String
//    let vaccine_id: String
//    let schedule_id: String
//    let administered_date: String
//}
