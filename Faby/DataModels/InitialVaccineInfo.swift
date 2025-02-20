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
    static let shared = VaccineManager()
    private var selectedVaccineDict: [String: Bool] = [:]
    
    let vaccineData: [VaccineStage] = [
        // Birth to 12 months
        VaccineStage(stageTitle: "Birth", vaccines: ["Hepatitis B (Dose 1)"]),
        VaccineStage(stageTitle: "6 weeks", vaccines: ["DTaP (Dose 1)", "Hib (Dose 1)", "Polio (Dose 1)", "Hepatitis B (Dose 2)"]),
        VaccineStage(stageTitle: "10 weeks", vaccines: ["DTaP (Dose 2)", "Hib (Dose 2)", "Rotavirus (Dose 1)", "Pneumococcal (Dose 1)"]),
        VaccineStage(stageTitle: "14 weeks", vaccines: ["DTaP (Dose 3)", "Hib (Dose 3)", "Polio (Dose 3)", "Rotavirus (Dose 2)", "Pneumococcal (Dose 2)"]),
        VaccineStage(stageTitle: "6 Months", vaccines: ["Hepatitis B (Dose 3)", "Influenza (Annual)"]),
        VaccineStage(stageTitle: "9 months", vaccines: ["MMR (Dose 1)"]),
        VaccineStage(stageTitle: "12 months", vaccines: ["Hepatitis A (Dose 1)", "Varicella (Dose 1)"]),
        
        // 1-3 years
        VaccineStage(stageTitle: "15 months", vaccines: [
            "DTaP (Dose 4)",
            "Hib (Dose 4)",
            "MMR (Dose 2)",
            "Varicella (Dose 2)",
            "Pneumococcal (Dose 4)"
        ]),
        VaccineStage(stageTitle: "18 months", vaccines: [
            "Hepatitis A (Dose 2)",
            "DTaP (Dose 4 if not given at 15 months)"
        ]),
        VaccineStage(stageTitle: "2 years", vaccines: [
            "Influenza (Annual)",
            "Pneumococcal polysaccharide (if at risk)"
        ]),
        VaccineStage(stageTitle: "2.5 years", vaccines: [
            "Influenza (Annual)"
        ]),
        VaccineStage(stageTitle: "3 years", vaccines: [
            "Influenza (Annual)",
            "DTaP (Dose 5)",
            "Polio (Dose 4)"
        ])
    ]
    
    func selectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = true
    }
    
    func unselectVaccine(_ vaccine: String) {
        selectedVaccineDict[vaccine] = false
    }
    
    func getSelectedVaccines() -> [String] {
        return selectedVaccineDict.filter { $0.value }.map { $0.key }
    }
}
