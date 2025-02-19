//
//  VaccinationRecordModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation

struct VaccinationRecord: Codable, Identifiable {
    var id: String
    var toddlerId: String  // Reference to the Toddler model
    var vaccineId: String  // Reference to the Vaccine model
    var dateAdministered: Date?  // If already given
    var dateScheduled: Date?  // If scheduled
    var hospitalId: String?  // Reference to the Hospital model
    var status: VaccinationStatus  // Enum to track vaccination state
}

enum VaccinationStatus: String, Codable {
    case administered
    case scheduled
    case missed
}
