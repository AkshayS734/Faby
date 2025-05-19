import Foundation
import UIKit
import CoreLocation
import Supabase

// MARK: - Core Vaccination Data Models

/// Base model for vaccine information
struct Vaccine: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let startWeek: Int
    let endWeek: Int
    let description: String
    
    // Implement Equatable to properly compare vaccine instances
    static func == (lhs: Vaccine, rhs: Vaccine) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.startWeek == rhs.startWeek &&
               lhs.endWeek == rhs.endWeek
    }
}

/// Record representing a vaccine schedule
struct VaccineSchedule: Codable, Identifiable, Equatable {
    let id: UUID
    let babyID: UUID
    let vaccineId: UUID
    var hospital: String
    var date: Date
    var location: String
    var isAdministered: Bool
    
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
    let scheduleId: UUID?
    var administeredDate: Date
    var hasDate: Bool = true // Default to true for backward compatibility, not stored in database
    
    // Add CodingKeys to map between Swift property names and database column names
    enum CodingKeys: String, CodingKey {
        case id
        case babyId = "baby_id"
        case vaccineId = "vaccine_id"
        case scheduleId = "schedule_id"
        case administeredDate = "administereddate"  // Without underscore
        // hasDate is not included here because it's not a database column
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



