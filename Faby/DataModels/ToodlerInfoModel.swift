//
//  ToodlerInfoModel.swift
//  Faby
//
//  Created by Adarsh Mishra on 24/01/25.
//

import Foundation

struct Toddler: Codable, Identifiable {
    var id: String  // Unique ID (UUID or database ID)
    var name: String
    var dob: Date   // Date of birth
    var gender: String
    var parentId: String
    
   
    var age: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dob, to: Date())
        return components.year ?? 0
    }
}
