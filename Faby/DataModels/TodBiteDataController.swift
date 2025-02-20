import Foundation

class BiteSampleData {
    static let shared = BiteSampleData()
    private init() {}

    // MARK: - Predefined Categories
    var categories: [BiteType: [FeedingMeal]] = [
        .EarlyBite: [
            FeedingMeal(name: "Dalia", description: "High in fiber, calcium, and protein.", image: "Dalia", category: .EarlyBite),
            FeedingMeal(name: "Poha with Vegetables", description: "Light, iron-rich, and full of vitamins.", image: "Poha with Vegetables", category: .EarlyBite),
            FeedingMeal(name: "Mashed Banana with Milk", description: "Rich in potassium and calcium.", image: "Mashed Banana with Milk", category: .EarlyBite),
            FeedingMeal(name: "Soft Aloo Paratha with Ghee", description: "Rich in potassium and calcium.", image: "Soft Aloo Paratha with Ghee", category: .EarlyBite)
            
        ],
        .NourishBite: [
            FeedingMeal(name: "Boiled Green Peas and Potatoes", description: "Rich in protein, iron, and healthy fats.", image: "Boiled Green Peas and Potatoes", category: .NourishBite),
            FeedingMeal(name: "Moong Dal Khichdi with Vegetables", description: "Packed with protein, fiber.", image: "Moong Dal Khichdi with Vegetables", category: .NourishBite),
            FeedingMeal(name: "Spinach Dal with Rice", description: "Packed with protein, fiber.", image: "Spinach Dal with Rice", category: .NourishBite),
            FeedingMeal(name: "Mashed Lentils with Ghee Rice", description: "Packed with protein, fiber.", image: "Mashed Lentils with Ghee Rice", category: .NourishBite)
            
        ],
        .MidDayBite: [
            FeedingMeal(name: "Dal Chawal with Ghee", description: "Provides protein, fiber, and fats.", image: "Dal Chawal with Ghee", category: .MidDayBite),
            FeedingMeal(name: "Palak Paneer with Rice", description: "High in iron, calcium, and protein.", image: "Palak Paneer with Rice", category: .MidDayBite),
            FeedingMeal(name: "Vegetable Pulao", description: "High in iron, calcium, and protein.", image: "Vegetable Pulao", category: .MidDayBite),
            FeedingMeal(name: "Aloo Gobhi with Roti", description: "High in iron, calcium, and protein.", image: "Aloo Gobhi with Roti", category: .MidDayBite)
        ],
        .SnackBite: [
            FeedingMeal(name: "Boiled Sweet Corns", description: "Rich in fiber, vitamins, and natural energy.", image: "Boiled Sweet Corns", category: .SnackBite),
            FeedingMeal(name: "Mashed Seasonal Fruits", description: "High in protein and easy to digest.", image: "Mashed Seasonal Fruits", category: .SnackBite),
            FeedingMeal(name: "Dhoklas", description: "High in protein and easy to digest.", image: "Dhoklas", category: .SnackBite)
        ],
        .NightBite: [
            FeedingMeal(name: "Milk with Dry Fruits", description: "Rich in protein, fiber, and essential nutrients.", image: "Milk with Dry Fruits", category: .NightBite),
            FeedingMeal(name: "Palak Paneer with Rice", description: "Loaded with iron, calcium, and vitamins.", image: "Palak Paneer with Rice", category: .NightBite),
            FeedingMeal(name: "Gobhi Aloo With Roti", description: "Loaded with iron, calcium, and vitamins.", image: "Gobhi Aloo With Roti", category: .NightBite)
        ]
    ]

    // MARK: - User-Defined Data
    var userAddedMeals: [FeedingMeal] = []  // Stores user-added meals
    var myBowl: [FeedingMeal] = []         // Stores user-selected meals
    var feedingPlans: [FeedingPlan] = [] // Stores feeding plans

    // MARK: - Get Meals by Category
    func getItems(for category: BiteType, in region: RegionType, for ageGroup: AgeGroup) -> [FeedingMeal] {
        let allItems = categories[category] ?? []
        
        // 🔹 Apply Filtering Based on Region & Age
        let filteredItems = allItems.filter { meal in
            return true  // 👉 Yahaan filtering logic add karo based on region & age
        }
        
        return filteredItems
    }


    // MARK: - Add Meal to "My Bowl"
    func addToMyBowl(_ item: FeedingMeal) {
        if !myBowl.contains(where: { $0.name == item.name }) {
            myBowl.append(item)
        }
    }

    // MARK: - Remove Meal from "My Bowl"
    func removeFromMyBowl(_ item: FeedingMeal) {
        myBowl.removeAll { $0.name == item.name }
    }

    // MARK: - Add User-Created Meals
    func addUserMeal(name: String, description: String, image: String, category: BiteType) {
        let newItem = FeedingMeal(name: name, description: description, image: image, category: category)
        userAddedMeals.append(newItem)
    }

    // MARK: - Plan Scheduling for Meals
    func scheduleFeedingPlan(for childId: String) {
        guard !myBowl.isEmpty else {
            print("Error: Cannot schedule feeding plan. MyBowl is empty!")
            return
        }
        let feedingPlan = FeedingPlan(childId: childId, schedule: Dictionary(uniqueKeysWithValues: myBowl.map { ($0.category, $0) }))
        feedingPlans.append(feedingPlan)
        print("Feeding Plan created for \(childId) with meals: \(feedingPlan.schedule.map { $0.value.name })")
    }
    
    var weeklyPlan: [String: [BiteType: [FeedingMeal]]] = [:]

    
    
}
