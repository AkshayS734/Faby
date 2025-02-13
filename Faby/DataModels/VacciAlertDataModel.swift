
import Foundation
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

