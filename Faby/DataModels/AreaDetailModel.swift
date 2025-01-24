//
//  AreaDetailModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation

struct Area: Codable, Identifiable {
    var id: String
    var name: String
    var recommendedVaccines: [String]  // List of vaccine IDs recommended in this area
}
