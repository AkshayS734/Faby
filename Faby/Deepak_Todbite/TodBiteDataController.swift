import Foundation

class BiteSampleData {
    static let shared = BiteSampleData()
    private init() {}

    // MARK: - Predefined Categories
    var categories: [BiteType: [FeedingMeal]] = [
        .EarlyBite: [
                FeedingMeal(name: "Luchi with Aloo Curry", description: "Soft luchi with mildly spiced potato curry, rich in carbohydrates.", image: "Luchi with Aloo Curry", category: .EarlyBite, region: .east, ageGroup: .months12to15),
                FeedingMeal(name: "Chuda Ghasa", description: "Flattened rice with jaggery and banana, packed with energy.", image: "Chuda Ghasa", category: .EarlyBite, region: .east, ageGroup: .months12to15),
                FeedingMeal(name: "Ragi Pancakes", description: "Iron-rich ragi pancakes, soft and nutritious.", image: "Ragi Pancakes", category: .EarlyBite, region: .east, ageGroup: .months12to15),
                FeedingMeal(name: "Idli with Coconut Chutney", description: "Soft idlis served with calcium-rich coconut chutney.", image: "Idli with Coconut Chutney", category: .EarlyBite, region: .east, ageGroup: .months12to15),
                
                
                
//                West
                
                
                FeedingMeal(name: "Thepla with Curd", description: "Soft whole wheat thepla served with cooling curd.", image: "Thepla with Curd", category: .EarlyBite, region: .west, ageGroup: .months12to15),
                FeedingMeal(name: "Poha with Vegetables", description: "Light and iron-rich flattened rice cooked with mild veggies.", image: "Poha with Vegetables", category: .EarlyBite, region: .west, ageGroup: .months12to15),
                FeedingMeal(name: "Sabudana Khichdi", description: "Soft tapioca pearls cooked with mild spices and peanuts.", image: "Sabudana Khichdi", category: .EarlyBite, region: .west, ageGroup: .months12to15),
//                FeedingMeal(name: "Dhokla", description: "Fermented chickpea flour steamed cake, light and easy to digest.", image: "Dhokla", category: .EarlyBite, region: .west, ageGroup: .months12to15),
               
                
                
//                norh
                
                FeedingMeal(name: "Aloo Paratha with Ghee", description: "Soft whole wheat flatbread stuffed with mashed potatoes.", image: "Boiled Sweet Corn", category: .EarlyBite, region: .north, ageGroup: .months12to15),
                       FeedingMeal(name: "Besan Cheela", description: "Soft gram flour pancake, rich in protein.", image: "Dal Chawal with Ghee", category: .EarlyBite, region: .north, ageGroup: .months12to15),
                       FeedingMeal(name: "Suji Halwa", description: "Semolina cooked with ghee and jaggery for energy.", image: "Dalia", category: .EarlyBite, region: .north, ageGroup: .months12to15),
                       FeedingMeal(name: "Roti with Jaggery Butter", description: "Soft whole wheat roti served with natural jaggery butter.", image: "Dhokla", category: .EarlyBite, region: .north, ageGroup: .months12to15),
                       
                
                
                
                
                
                FeedingMeal(name: "Idli with Coconut Chutney", description: "Soft steamed rice cakes served with calcium-rich coconut chutney.", image: "Boiled Sweet Corn", category: .EarlyBite, region: .south, ageGroup: .months12to15),
                        FeedingMeal(name: "Ragi Porridge", description: "Iron and calcium-rich ragi porridge for bone development.", image: "Dal Chawal with Ghee", category: .EarlyBite, region: .south, ageGroup: .months12to15),
                        FeedingMeal(name: "Vegetable Upma", description: "Soft semolina upma cooked with mild spices and veggies.", image: "Dalia", category: .EarlyBite, region: .south, ageGroup: .months12to15),
                        FeedingMeal(name: "Rice Pongal", description: "Soft rice and lentil dish with mild spices and ghee.", image: "Dhokla", category: .EarlyBite, region: .south, ageGroup: .months12to15)
                        
                    
                   
                
            ],
            
            .NourishBite: [
                    FeedingMeal(name: "Dalma with Rice", description: "Traditional Odia lentil stew with soft-cooked vegetables and rice.", image: "Dalma with Rice", category: .NourishBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Spinach Dal with Rice", description: "Iron-rich spinach cooked with lentils and rice.", image: "Spinach Dal with Rice", category: .NourishBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Paneer Bhurji with Roti", description: "Scrambled soft cottage cheese with mild spices.", image: "Paneer Bhurji & Roti", category: .NourishBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Tomato Dal", description: "Mild and tangy tomato-based lentil soup.", image: "Tomato Dal", category: .NourishBite, region: .east, ageGroup: .months12to15),
                    
                    
                    
                    
//                     west
                    
                    
                    FeedingMeal(name: "Dal Dhokli", description: "Gujarati-style whole wheat dumplings in lentil soup.", image: "Dal Dhokli", category: .NourishBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Mashed Spinach with Potato", description: "Iron-rich spinach mashed with soft-boiled potato.", image: "Mashed Spinach with Potato", category: .NourishBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Paneer Bhurji with Roti", description: "Soft crumbled cottage cheese cooked mildly.", image: "Paneer Bhurji with Roti", category: .NourishBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Ghee Rice with Moong Dal", description: "Soft-cooked rice and lentils with a touch of ghee.", image: "Ghee Rice with Moong Dal", category: .NourishBite, region: .west, ageGroup: .months12to15),
                    
                    
                    
                    
                    FeedingMeal(name: "Dal Tadka with Rice", description: "Mildly spiced yellow lentil curry with soft rice.", image: "Mashed Banana with Milk", category: .NourishBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Palak Paneer", description: "Soft cottage cheese in mild spinach gravy.", image: "Mashed Lentils with Ghee Rice", category: .NourishBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Masoor Dal with Roti", description: "Iron-rich lentil soup paired with soft roti.", image: "Mashed Seasonal Fruits", category: .NourishBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Vegetable Khichdi", description: "One-pot meal of lentils, rice, and veggies.", image: "Milk with Dry Fruits", category: .NourishBite, region: .north, ageGroup: .months12to15),
                           
                    
                    
                    
                    
                    
                    FeedingMeal(name: "Sambar with Soft Rice", description: "Mildly spiced lentil stew with soft-cooked rice.", image: "Mashed Banana with Milk", category: .NourishBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Vegetable Stew", description: "Coconut milk-based mild vegetable stew.", image: "Mashed Lentils with Ghee Rice", category: .NourishBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Tomato Rasam", description: "Light tomato-based soup, easy to digest.", image: "Mashed Seasonal Fruits", category: .NourishBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Masoor Dal with Rice", description: "Iron-rich lentil soup served with soft rice.", image: "Milk with Dry Fruits", category: .NourishBite, region: .south, ageGroup: .months12to15)
                           
                       
                    
                    
                    
                    
                    
                ],
                
                .MidDayBite: [
                    FeedingMeal(name: "Aloo Posto with Rice", description: "Potato curry with poppy seeds, mild and nutritious.", image: "Aloo Posto with Rice", category: .MidDayBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Tomato Dal", description: "Tangy tomato-based lentil curry, easy to digest.", image: "Tomato Dal", category: .MidDayBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Mixed Vegetable Pulao", description: "Lightly spiced rice cooked with mixed vegetables.", image: "Mixed Vegetable Pulao", category: .MidDayBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Lemon Rice", description: "Zesty lemon-flavored rice, rich in vitamin C.", image: "Lemon Rice", category: .MidDayBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Curd Rice", description: "Cooling curd mixed with soft rice.", image: "Curd Rice", category: .MidDayBite, region: .east, ageGroup: .months12to15),
                    
                    
                    
                    
                    
                    
                    
                    
                    FeedingMeal(name: "Aloo Paratha with Curd", description: "Soft whole wheat paratha stuffed with mild mashed potatoes.", image: "Aloo Paratha with Curd", category: .MidDayBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Dal Chawal with Ghee", description: "Soft rice with mild lentil curry and ghee.", image: "Dal Chawal with Ghee", category: .MidDayBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Gatte ki Sabzi with Rice", description: "Rajasthani-style chickpea dumplings in mild curry.", image: "Gatte ki Sabzi with Rice", category: .MidDayBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Matar Paneer", description: "Soft cottage cheese cubes with mildly spiced green peas curry.", image: "Matar Paneer", category: .MidDayBite, region: .west, ageGroup: .months12to15),
                           
                    
                    
                    
                    
                    
                    
                    
                    FeedingMeal(name: "Matar Pulao", description: "Mildly spiced rice cooked with green peas.", image: "Palak Paneer with Rice", category: .MidDayBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Aloo Gobhi with Roti", description: "Soft potato and cauliflower curry, mild in spice.", image: "Poha with Vegetables", category: .MidDayBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Rajma with Rice", description: "Protein-packed kidney bean curry with soft rice.", image: "Puffed Rice with Jaggery", category: .MidDayBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Tomato Rasam with Rice", description: "South Indian-style mild tomato and tamarind soup.", image: "Soft Aloo Paratha with Ghee", category: .MidDayBite, region: .north, ageGroup: .months12to15),
                           
                    
                    
                    
                    FeedingMeal(name: "Lemon Rice", description: "Zesty lemon-flavored rice, rich in vitamin C.", image: "Palak Paneer with Rice", category: .MidDayBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Vegetable Khichdi", description: "Lentil and rice porridge with mild veggies.", image: "Poha with Vegetables", category: .MidDayBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Curd Rice", description: "Cooling curd mixed with soft rice, perfect for digestion.", image: "Puffed Rice with Jaggery", category: .MidDayBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Mild Fish Curry with Rice (if non-allergic)", description: "Soft-cooked fish in coconut-based mild curry.", image: "Soft Aloo Paratha with Ghee", category: .MidDayBite, region: .south, ageGroup: .months12to15)
                           
                        
                        
                ],
                
                .SnackBite: [
                    FeedingMeal(name: "Ghugni (Chickpeas Snack)", description: "Yellow peas curry, soft and easy to chew.", image: "Ghugni (Chickpeas Snack)", category: .SnackBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Boiled Sweet Corn", description: "Rich in fiber, vitamins, and energy.", image: "Boiled Sweet Corn", category: .SnackBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Sesame Ladoo", description: "Iron and calcium-rich jaggery-sesame balls.", image: "Sesame Ladoo", category: .SnackBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Mashed Papaya", description: "Soft, naturally sweet fruit mash.", image: "Mashed Papaya", category: .SnackBite, region: .east, ageGroup: .months12to15),
                   
                    
//                     west
                    
                    FeedingMeal(name: "Boiled Corn with Butter", description: "Soft boiled corn kernels with a touch of butter.", image: "Boiled Corn with Butter", category: .SnackBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Roasted Sweet Potato Fries", description: "Soft roasted sweet potatoes, naturally sweet.", image: "Roasted Sweet Potato Fries", category: .SnackBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Peanut Chikki", description: "Protein and iron-rich jaggery-peanut snack.", image: "Peanut Chikki", category: .SnackBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Curd with Fruits", description: "Fresh seasonal fruits mixed with homemade curd.", image: "Curd with Fruits", category: .SnackBite, region: .west, ageGroup: .months12to15),
                          
                    
                    
                    
                    
                    FeedingMeal(name: "Boiled Chana with Lemon", description: "Soft black chickpeas tossed with lemon juice.", image: "Vegetable Pulao", category: .SnackBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Steamed Apple with Cinnamon", description: "Soft apple slices cooked with a hint of cinnamon.", image: "Boiled Sweet Corn", category: .SnackBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Peanut Butter on Soft Roti", description: "Protein-rich peanut butter spread on soft roti.", image: "Dal Chawal with Ghee", category: .SnackBite, region: .north, ageGroup: .months12to15),
                           FeedingMeal(name: "Homemade Jaggery Cookies", description: "Soft jaggery-sweetened wheat cookies.", image: "Dalia", category: .SnackBite, region: .north, ageGroup: .months12to15),
                           
                    
                    FeedingMeal(name: "Steamed Banana", description: "Soft banana pieces steamed for natural sweetness.", image: "Vegetable Pulao", category: .SnackBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Murukku (if non-allergic)", description: "Crispy lentil snack, lightly spiced.", image: "Boiled Sweet Corn", category: .SnackBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Boiled Chana with Coconut", description: "Soft boiled chickpeas tossed with grated coconut.", image: "Dal Chawal with Ghee", category: .SnackBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Sesame Ladoo", description: "Calcium-rich sesame and jaggery sweet ball.", image: "Dalia", category: .SnackBite, region: .south, ageGroup: .months12to15)
                            
                       
                        
                ],
                
                .NightBite: [
                    FeedingMeal(name: "Curd Rice", description: "Cooling curd mixed with soft rice.", image: "Curd Rice", category: .NightBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Tomato Soup", description: "Mild and creamy tomato soup.", image: "Tomato Soup", category: .NightBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Vegetable Khichdi", description: "A wholesome mix of lentils, rice, and vegetables.", image: "Vegetable Khichdi", category: .NightBite, region: .east, ageGroup: .months12to15),
                    FeedingMeal(name: "Soft Roti with Mashed Dal", description: "Gentle dal puree paired with soft roti.", image: "Soft Roti with Mashed Dal", category: .NightBite, region: .east, ageGroup: .months12to15),
                  
//                     west
                    
                    
                    
                    FeedingMeal(name: "Mashed Dal and Rice", description: "Soft-cooked lentils and rice for easy digestion.", image: "Mashed Dal and Rice", category: .NightBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Lemon Rice", description: "Mild lemon-flavored rice, easy to digest.", image: "Lemon Rice", category: .NightBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Palak Dal with Rice", description: "Spinach-infused lentil soup served with rice.", image: "Palak Dal with Rice", category: .NightBite, region: .west, ageGroup: .months12to15),
                            FeedingMeal(name: "Tomato Rasam", description: "Light South Indian-style tomato soup.", image: "Tomato Rasam", category: .NightBite, region: .west, ageGroup: .months12to15),
                            
                    
                    
                    
                    
                    
                    FeedingMeal(name: "Soft Roti with Mashed Dal", description: "Gentle dal puree paired with soft roti.", image: "Gobhi Aloo With Roti", category: .NightBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Sweet Potato Mash", description: "Naturally sweet and easy-to-digest mash.", image: "Mashed Banana with Milk", category: .NightBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Tomato Soup", description: "Mild and creamy tomato soup, rich in vitamin C.", image: "Mashed Lentils with Ghee Rice", category: .NightBite, region: .north, ageGroup: .months12to15),
                            FeedingMeal(name: "Palak Dal with Rice", description: "Spinach-infused lentil soup served with rice.", image: "Mashed Seasonal Fruits", category: .NightBite, region: .north, ageGroup: .months12to15),
                            
                    
                    
                    
                    FeedingMeal(name: "Soft Idiyappam with Coconut Milk", description: "Rice noodles served with mildly sweet coconut milk.", image: "Gobhi Aloo With Roti", category: .NightBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Tomato Soup", description: "Mild and creamy tomato soup, rich in vitamin C.", image: "Mashed Banana with Milk", category: .NightBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Palak Soup", description: "Iron-rich spinach soup with mild seasoning.", image: "Mashed Lentils with Ghee Rice", category: .NightBite, region: .south, ageGroup: .months12to15),
                            FeedingMeal(name: "Rice with Dal and Ghee", description: "Soft-cooked rice served with mild lentil curry and ghee.", image: "Mashed Seasonal Fruits", category: .NightBite, region: .south, ageGroup: .months12to15)
                            
                        
                        
                


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

