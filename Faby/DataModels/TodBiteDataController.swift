//import Foundation
//
//class TodbiteController {
//    static let shared = TodbiteController()
//
//    private init() {}
////
//    private var categories: [CategoryType: [Item]] = [
//        .EarlyBite: [
//            Item(name: "Spinach Dal with Rice", description: "High in fiber, calcium, and protein.", image: "Spinach Dal with Rice"),
//            Item(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables"),
//            Item(name: "Mashed Banana with Milk", description: "Rich in potassium and calcium.", image: "Mashed Banana with Milk"),
//            Item(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables")
//        ],
//        .NourishBite: [
//            Item(name: "Boiled Green Peas and Potatoes", description: "High in fiber, vitamins, and natural energy.", image: "Boiled Green Peas and Potatoes"),
//            Item(name: "Vegetable Pulao", description: "Rich in protein, iron, and healthy fats.", image: "Vegetable Pulao"),
//            Item(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber", image: "Moong Dal Khichdi with Vegetables"),
//            Item(name: "Spinach Dal with Rice", description: "Loaded with iron, calcium, and vitamins", image: "Spinach Dal with Rice")
//        ],
//        .MidDayBite: [
//            Item(name: "Gobhi Aloo With Roti", description: "Stuffed flatbread served with fresh curd.", image: "Gobhi Aloo With Roti"),
//            Item(name: "Dal Chawal with Ghee", description: "Provides protein, fiber, and fats.", image: "Dal Chawal with Ghee"),
//            Item(name: "Palak Paneer with Rice", description: "High in iron, calcium, and protein.", image: "Palak Paneer with Rice"),
//            Item(name: "Vegetable Pulao", description: "Packed with vitamins, fiber", image: "Vegetable Pulao")
//        ],
//        .SnackBite: [
//            Item(name: "Mashed Seasonal Fruits", description: "Packed with vitamins, fiber, and natural sugars", image: "Mashed Seasonal Fruits"),
//            Item(name: "Boiled Sweet Corn", description: "Rich in fiber, vitamins, and natural energy.", image: "Boiled Sweet Corn"),
//            Item(name: "Dhokla (Steamed)", description: "High in protein and easy to digest.", image: "Dhokla (Steamed)"),
//            Item(name: "Puffed Rice with Jaggery", description: "Iron-rich snack with natural sweetness.", image: "Puffed Rice with Jaggery")
//        ],
//        .NightBite: [
//            Item(name: "Gobhi Aloo With Roti", description: "Rich in vitamins, fiber, and energy.", image: "Gobhi Aloo With Roti"),
//            Item(name: "Moong Dal Khichdi with Vegetables", description: "Rich protein, fiber, and essential nutrients", image: "Moong Dal Khichdi with Vegetables"),
//            Item(name: "Spinach Dal with Rice", description: "Loaded with iron, calcium, and vitamins.", image: "Spinach Dal with Rice")
//        ]
//    ]
//    
//    var myBowl: [Item] = []
//    
//    /// Get meals based on category, region, and age group.
//    func getItems(for category: CategoryType, in region: RegionType, for ageGroup: AgeGroup) -> [Item] {
//        return categories[category] ?? []
//    }
//
//    static var sectionHeaderNames: [String] = [
//        "EarlyBite",
//        "NourishBite",
//        "MidDayBite",
//        "SnackBite",
//        "NightBite"
//    ]
//
//    /// Schedule a meal plan.
//    func schedulePlan(for items: [Item], startDate: Date, endDate: Date) -> MealSchedule {
//        let mealSchedule = MealSchedule(startDate: startDate, endDate: endDate, meals: items)
//        print("Plan scheduled from \(startDate) to \(endDate) with meals: \(items.map { $0.name })")
//        return mealSchedule
//    }
//}
