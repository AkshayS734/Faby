//
//  VaccineRecommendationModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation

struct UpcomingVaccinationRecommendation: Codable, Identifiable {
    var id: String
    var toddlerId: String
    var vaccineId: String
    var regionId: String
    var age: Int          
    var dateRange: DateRange
}

struct DateRange: Codable {
    var startDate: Date
    var endDate: Date
}
