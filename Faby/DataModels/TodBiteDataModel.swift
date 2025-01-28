//
//  TodBiteDataModel.swift
//  Faby
//
//  Created by Batch - 2 on 20/01/25.
//

import Foundation

enum CategoryType: String, CaseIterable {
    case EarlyBite = "EarlyBite"
    case NourishBite = "NourishBite"
    case MidDayBite = "MidDayBite"
    case SnackBite = "SnackBite"
    case NightBite = "NightBite"
}

enum RegionType: String {
    case East = "East"
    case West = "West"
    case North = "North"
    case South = "South"
}

enum AgeGroup: String {
    case months12to15 = "12-15 months"
    case months15to18 = "15-18 months"
    case months18to21 = "18-21 months"
    case months21to24 = "21-24 months"
    case months24to27 = "24-27 months"
    case months27to30 = "27-30 months"
    case months30to33 = "30-33 months"
    case months33to36 = "33-36 months"
}

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

struct MealSchedule {
    let startDate: Date
    let endDate: Date
    let meals: [MealItem]
}

class Todbite {
    static let shared = Todbite()

    private init() {}

    var categories: [CategoryType: [MealItem]] = [
        .EarlyBite: [
            MealItem(name: "Dalia with Milk", imageName: "Dalia with Milk", description: "High in fiber, calcium, and protein."),
            MealItem(name: "Poha with Vegetables", imageName: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins."),
            MealItem(name: "Mashed Banana with Milk", imageName: "Mashed Banana with Milk", description: "Rich in potassium and calcium."),
            MealItem(name: "Poha with Vegetables", imageName: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins")
        ],
        .NourishBite: [
            MealItem(name: "Boiled Green Peas and Potatoes", imageName: "Boiled Green Peas and Potatoes", description: "High in fiber, vitamins, and natural energy."),
            MealItem(name: "Mashed Lentils with Ghee Rice ", imageName: "Mashed Lentils with Ghee Rice ", description: "Rich in protein, iron, and healthy fats."),
            MealItem(name: "Moong Dal Khichdi with Vegetables", imageName: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber"),
            MealItem(name: "Spinach Dal with Rice", imageName: "Spinach Dal with Rice", description: "Loaded with iron, calcium, and vitamins")
        ],
        .MidDayBite: [
            MealItem(name: "Aloo Gobhi with Roti ", imageName: "Aloo Gobhi with Roti ", description: "Stuffed flatbread served with fresh curd."),
            MealItem(name: "Dal Chawal with Ghee", imageName: "Dal Chawal with Ghee", description: "Provides protein, fiber and fats."),
            MealItem(name: "Palak Paneer with Rice", imageName: "Palak Paneer with Rice", description: "High in iron, calcium, and protein."),
            MealItem(name: "Vegetable Pulao", imageName: "Vegetable Pulao", description: "Packed with vitamins, fiber")
        ],
        .SnackBite: [
            MealItem(name: "Mashed Seasonal Fruits", imageName: "Mashed Seasonal Fruits", description: "Packed with vitamins, fiber, and natural sugars"),
            MealItem(name: "Boiled Sweet Corn ", imageName: "Boiled Sweet Corn ", description: "Rich in fiber, vitamins, and natural energy."),
            MealItem(name: "Dhokla (Steamed) ", imageName: "Dhokla (Steamed) ", description: "High in protein and easy to digest."),
            MealItem(name: "Puffed Rice with Jaggery", imageName: "Puffed Rice with Jaggery", description: "Iron-rich snack with natural sweetness.")
        ],
        .NightBite: [
            MealItem(name: "Gobhi Aloo With Roti", imageName: "Gobhi Aloo With Roti", description: "Rich in vitamins, fiber, and energy."),
            MealItem(name: "Moong Dal Khichdi with Vegetables", imageName: "Moong Dal Khichdi with Vegetables", description: "Rich protein, fiber, and essential nutrients"),
            MealItem(name: "Spinach Dal with Rice", imageName: "Spinach Dal with Rice", description: "Loaded with iron, calcium, and vitamins.")
        ]
    ]
    
    var myBowl: [MealItem] = []
    
    func getItems(for category: CategoryType, in region: RegionType, for ageGroup: AgeGroup) -> [MealItem] {
        return categories[category] ?? []
    }

    static var sectionHeaderNames: [String] = [
        "EarlyBite",
        "NourishBite",
        "MidDayBite",
        "SnackBite",
        "NightBite"
    ]

    // MARK: - New Feature: Add Plan Scheduling
    func schedulePlan(for items: [MealItem], startDate: Date, endDate: Date) -> MealSchedule {
        let mealSchedule = MealSchedule(startDate: startDate, endDate: endDate, meals: items)
        print("Plan scheduled from \(startDate) to \(endDate) with meals: \(items.map { $0.name })")
        return mealSchedule
    }
}
