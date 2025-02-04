//
//  TodBiteDataController.swift
//  Todbite_Deepak
//
//  Created by DEEPAK PRAJAPATI on 04/02/25.
//

import Foundation
class Todbite {
    static let shared = Todbite()
    private init() {}

    // MARK: - Predefined Categories
    var categories: [CategoryType: [Item]] = [
        .EarlyBite: [
            Item(name: "Spinach Dal with Rice", description: "High in fiber, calcium, and protein.", image: "Spinach Dal with Rice"),
            Item(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables"),
            Item(name: "Mashed Banana with Milk", description: "Rich in potassium and calcium.", image: "Mashed Banana with Milk")
        ],
        .NourishBite: [
            Item(name: "Vegetable Pulao", description: "Rich in protein, iron, and healthy fats.", image: "Vegetable Pulao"),
            Item(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber", image: "Moong Dal Khichdi with Vegetables"),
            Item(name: "Vegetable Pulao", description: "Rich in protein, iron, and healthy fats.", image: "Vegetable Pulao"),
            Item(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber", image: "Moong Dal Khichdi with Vegetables")
        ],
        .MidDayBite: [
            Item(name: "Dal Chawal with Ghee", description: "Provides protein, fiber, and fats.", image: "Dal Chawal with Ghee"),
            Item(name: "Palak Paneer with Rice", description: "High in iron, calcium, and protein.", image: "Palak Paneer with Rice")
        ],
        .SnackBite: [
            Item(name: "Boiled Sweet Corn", description: "Rich in fiber, vitamins, and natural energy.", image: "Boiled Sweet Corn"),
            Item(name: "Dhokla (Steamed)", description: "High in protein and easy to digest.", image: "Dhokla (Steamed)"),Item(name: "Dhokla (Steamed)", description: "High in protein and easy to digest.", image: "Dhokla (Steamed)")
        ],
        .NightBite: [
            Item(name: "Moong Dal Khichdi with Vegetables", description: "Rich in protein, fiber, and essential nutrients", image: "Moong Dal Khichdi with Vegetables"),
            Item(name: "Spinach Dal with Rice", description: "Loaded with iron, calcium, and vitamins.", image: "Spinach Dal with Rice")
        ]
    ]

    // MARK: - User-Defined Data
    var userAddedMeals: [Item] = []  // Stores user-added meals
    var myBowl: [Item] = []         // Stores user-selected meals
    var mealPlans: [MealSchedule] = [] // Stores meal plans

    // MARK: - Get Meals by Category, Region, and Age Group
    func getItems(for category: CategoryType, in region: RegionType, for ageGroup: AgeGroup) -> [Item] {
        let items = categories[category] ?? []
        return items // Future scope: Implement filtering by region & age
    }

    // MARK: - Add Meal to "My Bowl"
    func addToMyBowl(_ item: Item) {
        if !myBowl.contains(where: { $0.name == item.name }) {
            myBowl.append(item)
        }
    }

    // MARK: - Remove Meal from "My Bowl"
    func removeFromMyBowl(_ item: Item) {
        myBowl.removeAll { $0.name == item.name }
    }

    // MARK: - Add User-Created Meals
    func addUserMeal(name: String, description: String, image: String) {
        let newItem = Item(name: name, description: description, image: image)
        userAddedMeals.append(newItem)
    }

    // MARK: - Plan Scheduling for Meals
    func schedulePlan(for items: [Item], startDate: Date, endDate: Date) {
        let mealSchedule = MealSchedule(startDate: startDate, endDate: endDate, meals: items)
        mealPlans.append(mealSchedule)
        print("Plan scheduled from \(startDate) to \(endDate) with meals: \(items.map { $0.name })")
    }
}
