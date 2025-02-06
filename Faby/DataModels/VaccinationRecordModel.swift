//
//  VaccinationRecordModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation



struct VaccineSchedule {
    let type: String
    let hospital: String
    let date: String
    let location: String
}

class VaccinationDataManager {
    private let storageKey = "VaccinationSchedules"
    
    func saveVaccinations(_ vaccinations: [VaccineSchedule]) {
        let data = vaccinations.map {
            ["type": $0.type, "hospital": $0.hospital, "date": $0.date, "address": $0.location]
        }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    func loadVaccinations() -> [VaccineSchedule] {
        guard let savedData = UserDefaults.standard.array(forKey: storageKey) as? [[String: String]] else {
            return []
        }
        return savedData.compactMap { dict in
            guard let type = dict["type"], let hospital = dict["hospital"], let date = dict["date"], let location = dict["address"] else {
                return nil
            }
            return VaccineSchedule(type: type, hospital: hospital, date: date, location: location)
        }
    }
}
