import Foundation

class BiteSampleData {
    static let shared = BiteSampleData()
    private init() {}

    // MARK: - Predefined Categories
    var categories: [BiteType: [FeedingMeal]] = [
        .EarlyBite: [
            FeedingMeal(name: "Ragi Porridge", description: "Softened ragi porridge, easy to digest for little ones.", image: "Ragi Porridge", category: .EarlyBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Banana Pancakes", description: "Banana pancakes cut into small, easy-to-eat pieces.", image: "Banana Pancakes", category: .EarlyBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Aloo Paratha", description: "Soft whole wheat paratha with mashed potato filling.", image: "Aloo Paratha", category: .EarlyBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Moong Dal Cheela", description: "Soft moong dal pancakes, gentle on the tummy.", image: "Moong Dal Cheela", category: .EarlyBite, region: .north, ageGroup: .months12to15)
        ],
        .NourishBite: [
            FeedingMeal(name: "Suji Halwa", description: "Semolina halwa with minimal sugar, soft and nutritious.", image: "Suji Halwa", category: .NourishBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Besan Cheela", description: "Soft gram flour pancakes, easy to chew.", image: "Besan Cheela", category: .NourishBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Soft Poha Vegetable", description: "Flattened rice cooked soft with mild veggies.", image: "Soft Poha Vegetable", category: .NourishBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Milk with Almonds", description: "Warm milk with finely ground almonds for nutrition.", image: "Milk with Almonds", category: .NourishBite, region: .north, ageGroup: .months12to15)
        ],
        .MidDayBite: [
            FeedingMeal(name: "Vegetable Upma", description: "Soft semolina upma with finely chopped vegetables.", image: "Vegetable Upma", category: .MidDayBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Oats Porridge", description: "Creamy oats porridge, gentle and filling.", image: "Oats Porridge", category: .MidDayBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Dal Khichdi", description: "Lentil and rice khichdi, mashed for easy eating.", image: "Dal Khichdi", category: .MidDayBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Curd Rice", description: "Soft rice mixed with curd for a cooling meal.", image: "Curd Rice", category: .MidDayBite, region: .north, ageGroup: .months12to15)
        ],
        .SnackBite: [
            FeedingMeal(name: "Soft Vegetable Pulav", description: "Soft vegetable pulao with mild spices.", image: "Soft Vegetable Pulav", category: .SnackBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Rajma Chawal", description: "Kidney beans and rice, mashed for easy chewing.", image: "Rajma Chawal", category: .SnackBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Paneer Bhurji with Roti", description: "Soft paneer bhurji served with soft roti.", image: "Paneer Bhurji with Roti", category: .SnackBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Mixed Vegetable Curry", description: "Mixed vegetable curry, mashed for little ones.", image: "Mixed Vegetable Curry", category: .SnackBite, region: .north, ageGroup: .months12to15)
        ],
        .NightBite: [
            FeedingMeal(name: "Aloo Gobi with Rice", description: "Potato and cauliflower curry with rice, mashed.", image: "Aloo Gobi with Rice", category: .NightBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Mashed Apple", description: "Nutritious Mashed Apple", image: "Mashed Apple", category: .NightBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Cereal with Milk", description: "Mild hot milk with cereal.", image: "Cereal with Milk", category: .NightBite, region: .north, ageGroup: .months12to15),
            FeedingMeal(name: "Soya Milk", description: "Milk with Protein", image: "Soya Milk", category: .NightBite, region: .north, ageGroup: .months12to15)
        ]
    ]

    // MARK: - User-Defined Data
    var userAddedMeals: [FeedingMeal] = []
    var myBowl: [FeedingMeal] = []
    var feedingPlans: [FeedingPlan] = []

    // MARK: - Get Meals by Category
    func getItems(for category: BiteType, in region: RegionType, for ageGroup: AgeGroup) -> [FeedingMeal] {
        let allItems = categories[category] ?? []

        let filteredItems = allItems.filter { meal in
            return meal.region == region && meal.ageGroup == ageGroup
        }

        print("\n📌 Fetching Meals for \(category.rawValue), Region: \(region.rawValue), Age: \(ageGroup.rawValue)")
        print("🔍 Found \(filteredItems.count) meals.")

        return filteredItems
    }
    
    // New method that includes country filtering
    func getItems(for category: BiteType, in country: CountryType, in region: RegionType, for ageGroup: AgeGroup) -> [FeedingMeal] {
        let allItems = categories[category] ?? []

        let filteredItems = allItems.filter { meal in
            return meal.region.country == country && meal.region == region && meal.ageGroup == ageGroup
        }

        print("\n📌 Fetching Meals for \(category.rawValue), Country: \(country.rawValue), Region: \(region.rawValue), Age: \(ageGroup.rawValue)")
        print("🔍 Found \(filteredItems.count) meals.")

        return filteredItems
    }

   
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
    func addUserMeal(name: String, description: String, image: String, category: BiteType, region: RegionType, ageGroup: AgeGroup) {
        let newItem = FeedingMeal(name: name, description: description, image: image, category: category, region: region, ageGroup: ageGroup)
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
extension BiteSampleData {
    func getDailyPlanMeals() -> [FeedingMeal] {
        var dailyMeals: [FeedingMeal] = []
        
        for category in BiteType.predefinedCases {
            if let meals = categories[category], !meals.isEmpty {
                dailyMeals.append(contentsOf: meals)
            }
        }

        return dailyMeals
    }
    
    // Get all meals from a specific country
    func getMealsByCountry(_ country: CountryType) -> [FeedingMeal] {
        var countryMeals: [FeedingMeal] = []
        
        for category in BiteType.predefinedCases {
            if let meals = categories[category] {
                let filteredMeals = meals.filter { $0.region.country == country }
                countryMeals.append(contentsOf: filteredMeals)
            }
        }
        
        // Also include user-added meals from this country
        let userMealsForCountry = userAddedMeals.filter { $0.region.country == country }
        countryMeals.append(contentsOf: userMealsForCountry)
        
        return countryMeals
    }
    
    // New method to get meals by continent
    func getMealsByContinent(_ continent: ContinentType) -> [FeedingMeal] {
        var continentMeals: [FeedingMeal] = []
        
        for category in BiteType.predefinedCases {
            if let meals = categories[category] {
                let filteredMeals = meals.filter { $0.region.continent == continent }
                continentMeals.append(contentsOf: filteredMeals)
            }
        }
        
        // Also include user-added meals from this continent
        let userMealsForContinent = userAddedMeals.filter { $0.region.continent == continent }
        continentMeals.append(contentsOf: userMealsForContinent)
        
        return continentMeals
    }
    
    // Get meals with three-level filtering (continent, country, region)
    func getItems(for category: BiteType, in continent: ContinentType, in country: CountryType, in region: RegionType, for ageGroup: AgeGroup) -> [FeedingMeal] {
        let allItems = categories[category] ?? []

        let filteredItems = allItems.filter { meal in
            return meal.region.continent == continent &&
                   meal.region.country == country &&
                   meal.region == region &&
                   meal.ageGroup == ageGroup
        }

        print("\n📌 Fetching Meals for \(category.rawValue), Continent: \(continent.rawValue), Country: \(country.rawValue), Region: \(region.rawValue), Age: \(ageGroup.rawValue)")
        print("🔍 Found \(filteredItems.count) meals.")

        return filteredItems
    }
    
    // Organize all meals by continent, country, and region
    func organizeMealsByHierarchy() -> [ContinentType: [CountryType: [RegionType: [FeedingMeal]]]] {
        var organizedMeals: [ContinentType: [CountryType: [RegionType: [FeedingMeal]]]] = [:]
        
        // Combine all meals from predefined categories and user-added meals
        var allMeals: [FeedingMeal] = []
        for category in BiteType.predefinedCases {
            if let meals = categories[category] {
                allMeals.append(contentsOf: meals)
            }
        }
        allMeals.append(contentsOf: userAddedMeals)
        
        // Organize by continent, country, and region
        for continent in ContinentType.allCases {
            var countriesInContinent: [CountryType: [RegionType: [FeedingMeal]]] = [:]
            
            for country in CountryType.allCases where country.continent == continent {
                var regionsInCountry: [RegionType: [FeedingMeal]] = [:]
                
                for region in RegionType.allCases where region.country == country {
                    let mealsInRegion = allMeals.filter { $0.region == region }
                    if !mealsInRegion.isEmpty {
                        regionsInCountry[region] = mealsInRegion
                    }
                }
                
                if !regionsInCountry.isEmpty {
                    countriesInContinent[country] = regionsInCountry
                }
            }
            
            if !countriesInContinent.isEmpty {
                organizedMeals[continent] = countriesInContinent
            }
        }
        
        return organizedMeals
    }
}

