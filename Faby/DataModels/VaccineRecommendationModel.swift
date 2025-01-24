//
//  VaccineRecommendationModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation

struct UpcomingVaccinationRecommendation: Codable, Identifiable {
    var id: String
    var toddlerId: String  // Reference to the Toddler model
    var vaccineId: String  // Reference to the Vaccine model
    var regionId: String   // Reference to the Area/Region model
    var age: Int           // Age of the toddler in months
    var dateRange: DateRange
}

struct DateRange: Codable {
    var startDate: Date
    var endDate: Date
}
