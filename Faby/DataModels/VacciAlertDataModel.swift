//
//  VacciAlertDataModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 10/02/25.
//

import Foundation
struct ParentDetail: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phoneNumber: String
    var babyIds: [String] // List of toddler IDs linked to this parent
}

struct BabyDetail: Identifiable, Codable {
    var id: String
    var parentId: String // Links to ParentDetail
    var name: String
    var dateOfBirth: Date
    var gender: String
}

