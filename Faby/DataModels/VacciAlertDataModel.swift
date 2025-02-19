
import Foundation



struct VaccineData : Identifiable {
    let id = UUID()
    
    // MARK: - Models
    struct VaccineData {
        
        let name: String
        let startDate: Date
        let endDate: Date
        var isScheduled: Bool
    }
    
    struct VaccineSchedule {
        static let timelines: [(name: String, startMonth: Int, endMonth: Int)] = [
            // Newborn vaccines
            ("Hepatitis B (Dose 1)", 0, 1),
            ("RSV Antibody", 0, 1),
            
            // 2-month vaccines
            ("Hepatitis B (Dose 2)", 2, 3),
            ("Rotavirus (Dose 1)", 2, 3),
            ("DTaP (Dose 1)", 2, 3),
            ("Hib (Dose 1)", 2, 3),
            ("PCV (Dose 1)", 2, 3),
            ("IPV (Dose 1)", 2, 3),
            
            // 4-month vaccines
            ("Rotavirus (Dose 2)", 4, 5),
            ("DTaP (Dose 2)", 4, 5),
            ("Hib (Dose 2)", 4, 5),
            ("PCV (Dose 2)", 4, 5),
            ("IPV (Dose 2)", 4, 5),
            
            // 6-month vaccines
            ("Hepatitis B (Dose 3)", 6, 7),
            ("Rotavirus (Dose 3)", 6, 7),
            ("DTaP (Dose 3)", 6, 7),
            ("Hib (Dose 3)", 6, 7),
            ("PCV (Dose 3)", 6, 7),
            ("IPV (Dose 3)", 6, 7),
            ("Flu Vaccine", 6, 7),
            ("COVID-19 Vaccine", 6, 7),
            
            // 12-month vaccines
            ("MMR (Dose 1)", 12, 15),
            ("Hepatitis A (Dose 1)", 12, 15),
            ("PCV (Dose 4)", 12, 15),
            
            // 15-month vaccines
            ("Varicella (Dose 1)", 15, 18),
            ("DTaP (Dose 4)", 15, 18),
            ("Hib (Final Dose)", 15, 18),
            
            // 18-month vaccines
            ("Hepatitis A (Dose 2)", 18, 24)
        ]
    }
    
    // MARK: - View Model
    class VaccineViewModel {
        private var babyBirthDate: Date
        private var vaccineDataDict: [String: VaccineData] = [:]
        private var selectedVaccines: [String] = []
        
        init(babyBirthDate: Date) {
            self.babyBirthDate = babyBirthDate
            setupVaccineData()
        }
        
        func getVaccineData() -> [VaccineData] {
            return vaccineDataDict.values.sorted { $0.startDate < $1.startDate }
        }
        
        func scheduleVaccine(_ vaccine: String) -> Bool {
            guard var vaccineData = vaccineDataDict[vaccine] else { return false }
            vaccineData.isScheduled = true
            vaccineDataDict[vaccine] = vaccineData
            selectedVaccines.append(vaccine)
            return true
        }
        
        func updateSelectedVaccines(_ vaccines: [String]) {
            selectedVaccines = vaccines
            setupVaccineData()
        }
        
        private func setupVaccineData() {
            let calendar = Calendar.current
            let babyAgeInMonths = 12 // Fixed at 1 year for now
            
            vaccineDataDict.removeAll()
            
            for timeline in VaccineSchedule.timelines {
                if timeline.startMonth >= babyAgeInMonths &&
                    timeline.startMonth <= babyAgeInMonths + 3 && // Adjust window as needed
                    !selectedVaccines.contains(timeline.name) {
                    
                    let vaccineStartDate = calendar.date(byAdding: .month, value: timeline.startMonth, to: babyBirthDate) ?? Date()
                    let vaccineEndDate = calendar.date(byAdding: .month, value: timeline.endMonth, to: babyBirthDate) ?? Date()
                    
                    vaccineDataDict[timeline.name] = VaccineData(
                        name: timeline.name,
                        startDate: vaccineStartDate,
                        endDate: vaccineEndDate,
                        isScheduled: false
                    )
                }
            }
        }
        
        struct VaccineRecord: Codable, Hashable {
            let id: UUID
            let babyId: UUID
            let type: String
            let hospital: Hospital
            let date: Date
            let location: String
            var notes: String?
            var isCompleted: Bool
            var doseNumber: Int
            var nextDoseDate: Date?
            var sideEffects: [String]?
            var documentUrls: [String]?
            var administeredBy: String?
            var batchNumber: String?
            var cost: Double?
            var insuranceCovered: Bool?
            
            init(id: UUID = UUID(), babyId: UUID, type: String, hospital: Hospital,
                 date: Date, location: String, notes: String? = nil, isCompleted: Bool = false,
                 doseNumber: Int, nextDoseDate: Date? = nil, sideEffects: [String]? = nil,
                 documentUrls: [String]? = nil, administeredBy: String? = nil,
                 batchNumber: String? = nil, cost: Double? = nil, insuranceCovered: Bool? = nil) {
                self.id = id
                self.babyId = babyId
                self.type = type
                self.hospital = hospital
                self.date = date
                self.location = location
                self.notes = notes
                self.isCompleted = isCompleted
                self.doseNumber = doseNumber
                self.nextDoseDate = nextDoseDate
                self.sideEffects = sideEffects
                self.documentUrls = documentUrls
                self.administeredBy = administeredBy
                self.batchNumber = batchNumber
                self.cost = cost
                self.insuranceCovered = insuranceCovered
                
            }
        }
        
    }
}
