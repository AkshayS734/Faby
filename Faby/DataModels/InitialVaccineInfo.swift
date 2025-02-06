//
//  InitialVaccineInfo.swift
//  Faby
//
//  Created by Adarsh Mishra on 06/02/25.
//

import Foundation

struct VaccineStage {
    let stageTitle: String
    let vaccines: [String]
}

class VaccineManager {
    static let shared = VaccineManager() // Singleton for managing vaccine data

    private let vaccineKey = "SavedVaccines"

    var selectedVaccines: [String] = []

    let vaccineData: [VaccineStage] = [
        VaccineStage(stageTitle: "Birth", vaccines: ["Hepatitis B (Dose 1)"]),
        VaccineStage(stageTitle: "6 weeks", vaccines: ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        VaccineStage(stageTitle: "10 weeks", vaccines: ["DTaP (Dose 2)", "Hib (Dose 2)", "Rotavirus (Dose 1)", "Pneumococcal (Dose 1)"]),
        VaccineStage(stageTitle: "14 weeks", vaccines: ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)", "Rotavirus (Dose 2)", "Pneumococcal (Dose 2)"]),
        VaccineStage(stageTitle: "6 Months", vaccines: ["Hepatitis B (Dose 3)"]),
        VaccineStage(stageTitle: "9 months", vaccines: ["MMR (Dose 1)"]),
        VaccineStage(stageTitle: "12 months", vaccines: ["Hepatitis A (Dose 1)", "Varicella (Dose 1)"])
    ]

    func saveSelectedVaccines() {
        var existingData = UserDefaults.standard.array(forKey: vaccineKey) as? [String] ?? []
        existingData.append(contentsOf: selectedVaccines)
        existingData = Array(Set(existingData)) // Remove duplicates
        UserDefaults.standard.set(existingData, forKey: vaccineKey)
        UserDefaults.standard.synchronize()
    }

    func loadSelectedVaccines() {
        selectedVaccines = UserDefaults.standard.array(forKey: vaccineKey) as? [String] ?? []
    }
}
