//
//  HospitalDataModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 23/01/25.
//

import Foundation
import Foundation

struct Hospital: Codable, Hashable {
    let id: UUID
    let babyId: UUID
    let name: String
    let address: String
    let distance: Double
    let coordinates: Coordinates?
    
    struct Coordinates: Codable, Hashable {
        let latitude: Double
        let longitude: Double
    }
    
    init(
        id: UUID = UUID(),
        babyId: UUID,
        name: String,
        address: String,
        distance: Double,
        coordinates: Coordinates? = nil
    ) {
        self.id = id
        self.babyId = babyId
        self.name = name
        self.address = address
        self.distance = distance
        self.coordinates = coordinates
    }
}

