import Foundation
import CoreLocation

// MARK: - Hospital Model
struct Hospital: Codable, Hashable {
    let id: UUID
    let babyId: UUID
    let name: String
    let address: String
    let distance: Double
//    let coordinates: Coordinates
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
//        coordinates: Coordinates,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.address = address
        self.distance = distance
//        self.coordinates = coordinates
        self.lastUpdated = lastUpdated
    }
}

// MARK: - User Location Preferences
struct UserLocationPreference: Codable {
    let userId: UUID
    let babyId: UUID
    let lastKnownLocation: Hospital.Coordinates?
    let searchRadius: Double // in kilometers
    let lastUpdated: Date
    
    init(
        userId: UUID,
        babyId: UUID,
        lastKnownLocation: Hospital.Coordinates? = nil,
        searchRadius: Double = 5.0,
        lastUpdated: Date = Date()
    ) {
        self.userId = userId
        self.babyId = babyId
        self.lastKnownLocation = lastKnownLocation
        self.searchRadius = searchRadius
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Hospital Data Manager
class HospitalDataManager {
    static let shared = HospitalDataManager()
    private let userDefaults = UserDefaults.standard
    
    private let locationPreferencesKey = "userLocationPreferences"
    private let savedHospitalsKey = "savedHospitals"
    
    private init() {}
    
    // MARK: - Location Preferences Management
    func saveLocationPreference(preference: UserLocationPreference) {
        var preferences = getLocationPreferences()
        if let index = preferences.firstIndex(where: { $0.userId == preference.userId }) {
            preferences[index] = preference
        } else {
            preferences.append(preference)
        }
        
        if let encoded = try? JSONEncoder().encode(preferences) {
            userDefaults.set(encoded, forKey: locationPreferencesKey)
        }
    }
    
    func getLocationPreferences() -> [UserLocationPreference] {
        guard let data = userDefaults.data(forKey: locationPreferencesKey),
              let preferences = try? JSONDecoder().decode([UserLocationPreference].self, from: data) else {
            return []
        }
        return preferences
    }
    
    func getLocationPreference(for userId: UUID) -> UserLocationPreference? {
        return getLocationPreferences().first { $0.userId == userId }
    }
    
    // MARK: - Hospital Management
    func saveHospital(_ hospital: Hospital) {
        var hospitals = getSavedHospitals()
        if let index = hospitals.firstIndex(where: { $0.id == hospital.id }) {
            hospitals[index] = hospital
        } else {
            hospitals.append(hospital)
        }
        
        if let encoded = try? JSONEncoder().encode(hospitals) {
            userDefaults.set(encoded, forKey: savedHospitalsKey)
        }
    }
    
    func getSavedHospitals(for babyId: UUID? = nil) -> [Hospital] {
        guard let data = userDefaults.data(forKey: savedHospitalsKey),
              let hospitals = try? JSONDecoder().decode([Hospital].self, from: data) else {
            return []
        }
        
        if let babyId = babyId {
            return hospitals.filter { $0.babyId == babyId }
        }
        return hospitals
    }
    
    // MARK: - Scheduled Vaccination Management
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
        
        var savedSchedules = userDefaults.array(forKey: "VaccinationSchedules") as? [[String: Any]] ?? []
        savedSchedules.append(vaccinationData)
        userDefaults.set(savedSchedules, forKey: "VaccinationSchedules")
    }
}
