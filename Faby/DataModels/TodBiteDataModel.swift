//
//  TodBiteDataModel.swift
//  Faby
//
//  Created by Batch - 2 on 20/01/25.
//

import Foundation
struct MealItem {
    let name: String
    let imageName: String // Name of the image in your assets folder
    let description: String // Example: "Rich in calcium, protein, vitamin D"
}
struct MealCategory {
    let title: String // Example: "EarlyBite"
    let interval: String // Example: "7:00 AM - 8:00 AM"
    let items: [MealItem] // Array of MealItem objects
}

