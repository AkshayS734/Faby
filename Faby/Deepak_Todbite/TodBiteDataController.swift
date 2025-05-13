import Foundation
import Supabase

class BiteSampleData {
    static let shared = BiteSampleData()
    private init() {}

    // MARK: - Predefined Categories
    var categories: [BiteType: [FeedingMeal]] = [:]

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

let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")

func fetchMeals() async -> [FeedingMeal] {
    do {
        print("🔄 Starting to fetch meals from Supabase...")
        
        let response = try await client.database
            .from("feeding_meals")
            .select()
            .execute()
        
        print("✅ Received response from Supabase")
        
        // Print raw response for debugging
        if let dataString = String(data: response.data, encoding: .utf8) {
            print("📊 Raw response data: \(dataString)")
        } else {
            print("⚠️ Could not decode response data as string")
        }
        
        do {
            let meals = try JSONDecoder().decode([FeedingMeal].self, from: response.data)
            print("🍽️ Successfully decoded \(meals.count) meals")
            
            // Print first meal for debugging if available
            if let firstMeal = meals.first {
                print("📝 First meal: \(firstMeal.name), Category: \(firstMeal.category.rawValue), Region: \(firstMeal.region.rawValue)")
            }
            
            return meals
        } catch let decodingError {
            print("❌ JSON Decoding error: \(decodingError)")
            
            // Print more details about the decoding error
            if let decodingError = decodingError as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: Expected \(type), at path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), at path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key), at path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            
            // Try to decode as a different structure to see what's coming back
            if let json = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                print("🔍 JSON structure received:")
                
                if let firstObject = json.first {
                    for (key, value) in firstObject {
                        let valueType = type(of: value)
                        print("   Key: \(key), Value: \(value), Type: \(valueType)")
                    }
                }
            }
            
            return []
        }
    } catch let networkError {
        print("❌ Network error while fetching meals: \(networkError)")
        return []
    }
}

// Helper function to load sample data if Supabase fails
func loadSampleMeals() -> [FeedingMeal] {
    // Create some sample meals for testing
    let sampleMeals = [
        FeedingMeal(
            name: "Rice Pudding",
            description: "Sweet rice pudding with milk and sugar",
            image: "Asia/India/East/12-15months/EarlyBite/rice_pudding.jpg",
            category: .EarlyBite,
            region: .east,
            ageGroup: .months12to15
        ),
        FeedingMeal(
            name: "Vegetable Khichdi",
            description: "Rice and lentil dish with vegetables",
            image: "Asia/India/North/12-15months/NourishBite/khichdi.jpg",
            category: .NourishBite,
            region: .north,
            ageGroup: .months12to15
        )
    ]
    
    return sampleMeals
}

func getImageURL(for meal: FeedingMeal) -> URL? {
    let baseURL = "https://tmnltannywgqrrxavoge.supabase.co/storage/v1/object/public/meal-images"
    
    // The image path is already complete from the database
    if meal.image_url.lowercased().starts(with: "http") {
        // If it's already a full URL, use it directly
        return URL(string: meal.image_url)
    } else {
        // Otherwise, construct URL from base and path
        return URL(string: "\(baseURL)/\(meal.image_url)")
    }
}

// Function to populate the data model with meals from Supabase
func populateMealData() async {
    print("📲 Starting to populate meal data...")
    
    // Fetch meals from Supabase
    var meals = await fetchMeals()
    
    // If no meals returned from Supabase, use sample data
    if meals.isEmpty {
        print("⚠️ No meals returned from Supabase, using sample data instead")
        meals = loadSampleMeals()
        
        // Show alert or log for debugging in production
        DispatchQueue.main.async {
            // You can show an alert here in the UI if needed
            print("⚠️ ALERT: Could not load meals from Supabase. Using sample data instead.")
        }
    }
    
    print("🍴 Populating data model with \(meals.count) meals")
    
    // Group meals by category
    var categorizedMeals: [BiteType: [FeedingMeal]] = [:]
    
    for meal in meals {
        if categorizedMeals[meal.category] == nil {
            categorizedMeals[meal.category] = []
        }
        categorizedMeals[meal.category]?.append(meal)
    }
    
    // Update the shared data model
    BiteSampleData.shared.categories = categorizedMeals
    
    print("✅ Data model populated successfully")
    
    // Print summary of what was loaded
    for (category, meals) in categorizedMeals {
        print("📊 Category: \(category.rawValue) - \(meals.count) meals")
        
        // Print a few examples from each category
        let exampleCount = min(2, meals.count)
        for i in 0..<exampleCount {
            let meal = meals[i]
            print("   - \(meal.name) (Region: \(meal.region.rawValue), Age: \(meal.ageGroup.rawValue))")
        }
    }
}

// PreloadedDataManager to ensure data is available
class PreloadedDataManager {
    static let shared = PreloadedDataManager()
    private init() {
        // Start loading data immediately
        Task {
            await ensureDataLoaded()
        }
    }
    
    private var isDataPreloaded = false
    private var isLoading = false
    private var loadingTask: Task<Void, Never>?
    
    // Public method to force wait for data to load
    func ensureDataLoaded() async {
        // If data is already loaded, return immediately
        if isDataPreloaded {
            print("✅ Data already preloaded, returning immediately")
            return
        }
        
        // If already loading, wait for that task to complete
        if isLoading, let existingTask = loadingTask {
            print("⏳ Already loading data, waiting for existing task...")
            await existingTask.value
            return
        }
        
        // Start loading
        isLoading = true
        print("🚀 Starting preloaded data loading process")
        
        loadingTask = Task {
            // Load data using the existing function
            await populateMealData()
            
            // Double check that data was actually loaded
            if BiteSampleData.shared.categories.isEmpty {
                print("⚠️ First attempt to load data failed, trying again with sample data")
                // Force use sample data
                BiteSampleData.shared.categories = createSampleCategories()
            }
            
            self.isDataPreloaded = true
            self.isLoading = false
            print("✅ Preloaded data is now ready")
        }
        
        // Wait for the loading task to complete
        await loadingTask?.value
    }
    
    // Create sample data as a fallback
    private func createSampleCategories() -> [BiteType: [FeedingMeal]] {
        var categories: [BiteType: [FeedingMeal]] = [:]
        
        // Add sample meals for each category
        for category in BiteType.predefinedCases {
            let sampleMeals = [
                FeedingMeal(
                    name: "\(category.rawValue) Sample 1",
                    description: "Sample meal for \(category.rawValue)",
                    image: "sample_image.jpg",
                    category: category,
                    region: .north,
                    ageGroup: .months12to15
                ),
                FeedingMeal(
                    name: "\(category.rawValue) Sample 2",
                    description: "Another sample for \(category.rawValue)",
                    image: "sample_image.jpg",
                    category: category,
                    region: .north,
                    ageGroup: .months12to15
                )
            ]
            categories[category] = sampleMeals
        }
        
        return categories
    }
    
    // Provide direct access to data 
    func getFilteredMeals(for category: BiteType, in continent: ContinentType, in country: CountryType, in region: RegionType, for ageGroup: AgeGroup) -> [FeedingMeal] {
        // Access the BiteSampleData directly but ensure data is loaded first
        if !isDataPreloaded {
            print("⚠️ Warning: Accessing filtered meals before data is loaded")
        }
        
        return BiteSampleData.shared.getItems(for: category, in: continent, in: country, in: region, for: ageGroup)
    }
}

