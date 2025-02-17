import Foundation

struct VaccineStage {
    let id: UUID
    let stageTitle: String
    let vaccines: [String]

    init(stageTitle: String, vaccines: [String]) {
        self.id = UUID()
        self.stageTitle = stageTitle
        self.vaccines = vaccines
    }
}

class VaccineManager {
    static let shared = VaccineManager() // Singleton for managing vaccine data

    // Temporary storage instead of UserDefaults
    private var selectedVaccineDict: [String: Bool] = [:]

    let vaccineData: [VaccineStage] = [
        VaccineStage(stageTitle: "Birth", vaccines: ["Hepatitis B (Dose 1)"]),
        VaccineStage(stageTitle: "6 weeks", vaccines: ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        VaccineStage(stageTitle: "10 weeks", vaccines: ["DTaP (Dose 2)", "Hib (Dose 2)", "Rotavirus (Dose 1)", "Pneumococcal (Dose 1)"]),
        VaccineStage(stageTitle: "14 weeks", vaccines: ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)", "Rotavirus (Dose 2)", "Pneumococcal (Dose 2)"]),
        VaccineStage(stageTitle: "6 Months", vaccines: ["Hepatitis B (Dose 3)"]),
        VaccineStage(stageTitle: "9 months", vaccines: ["MMR (Dose 1)"]),
        VaccineStage(stageTitle: "12 months", vaccines: ["Hepatitis A (Dose 1)", "Varicella (Dose 1)"])
    ]

    // Mark vaccine as selected
    func selectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = true
    }

    // Unselect a vaccine
    func unselectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = false
    }

    // Get all selected vaccines
    func getSelectedVaccines() -> [String] {
        return selectedVaccineDict.filter { $0.value }.map { $0.key }
    }
}
