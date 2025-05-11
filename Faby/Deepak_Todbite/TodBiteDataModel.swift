import UIKit
import Supabase
//import Postgrest


enum BiteType: Hashable, Codable {
    case EarlyBite
    case NourishBite
    case MidDayBite
    case SnackBite
    case NightBite
    case custom(String)

    var rawValue: String {
        switch self {
        case .EarlyBite: return "EarlyBite"
        case .NourishBite: return "NourishBite"
        case .MidDayBite: return "MidDayBite"
        case .SnackBite: return "SnackBite"
        case .NightBite: return "NightBite"
        case .custom(let name): return name          }
    }

    static let predefinedCases: [BiteType] = [.EarlyBite, .NourishBite, .MidDayBite, .SnackBite, .NightBite]
    
    // For Codable conformance
    private enum CodingKeys: String, CodingKey {
        case type, customName
    }
    
    private enum BiteTypeValue: String, Codable {
        case earlyBite = "EarlyBite"
        case nourishBite = "NourishBite"
        case midDayBite = "MidDayBite"
        case snackBite = "SnackBite"
        case nightBite = "NightBite"
        case custom = "custom"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "EarlyBite": self = .EarlyBite
        case "NourishBite": self = .NourishBite
        case "MidDayBite": self = .MidDayBite
        case "SnackBite": self = .SnackBite
        case "NightBite": self = .NightBite
        default: self = .custom(value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// MARK: - Geographical Hierarchy

enum ContinentType: String, CaseIterable, Codable {
    case asia = "Asia"
    case africa = "Africa"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case australia = "Australia"
    case antarctica = "Antarctica"
}

enum CountryType: String, CaseIterable, Codable {
    case india = "India"
    // Future countries can be added here
    // case china = "China"
    // case japan = "Japan"
    // case usa = "USA"
    // etc.
    
    var continent: ContinentType {
        switch self {
        case .india:
            return .asia
        // Future cases can be added here
        // case .china, .japan:
        //    return .asia
        // case .usa:
        //    return .northAmerica
        }
    }
}

enum RegionType: String, CaseIterable, Codable {
    case east = "East"
    case west = "West"
    case north = "North"
    case south = "South"
    
    // For future extension with specific regions from different countries
    // case usEast = "US East"
    // case usWest = "US West"
    // etc.
    
    // This computed property allows mapping regions to countries
    var country: CountryType {
        switch self {
        case .east, .west, .north, .south:
            return .india
        // Future cases can be added here
        // case .usEast, .usWest:
        //    return .usa
        }
    }
    
    // Helper property to get continent directly
    var continent: ContinentType {
        return country.continent
    }
}

enum AgeGroup: String, CaseIterable, Codable {
    case months12to15 = "12-15 months"
    case months15to18 = "15-18 months"
    case months18to21 = "18-21 months"
    case months21to24 = "21-24 months"
    case months24to30 = "24-30 months"
    case months30to36 = "30-36 months"
}

struct FeedingMeal: Codable {
    let id: Int?
    let name: String
    let description: String
    let image_url: String
    let category: BiteType
    let region: RegionType
    let ageGroup: AgeGroup
    let createdAt: String?
    let updatedAt: String?
    
    // Helper computed properties for the geographical hierarchy
    var country: CountryType {
        return region.country
    }
    
    var continent: ContinentType {
        return country.continent
    }
    
    // Coding keys to map between JSON field names and Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case image = "image_url"
        case biteTypeId = "bite_type_id"
        case regionId = "region_id"
        case ageGroupId = "age_group_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom initializer for Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        image_url = try container.decode(String.self, forKey: .image)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Decode bite type ID and map to BiteType
        let biteTypeId = try container.decode(Int.self, forKey: .biteTypeId)
        switch biteTypeId {
        case 1: category = .EarlyBite
        case 2: category = .NourishBite
        case 3: category = .MidDayBite
        case 4: category = .SnackBite
        case 5: category = .NightBite
        default: category = .custom("Custom \(biteTypeId)")
        }
        
        // Decode region ID and map to RegionType
        let regionId = try container.decode(Int.self, forKey: .regionId)
        switch regionId {
        case 1: region = .east
        case 2: region = .west
        case 3: region = .north
        case 4: region = .south
        default: 
            throw DecodingError.dataCorruptedError(
                forKey: .regionId,
                in: container,
                debugDescription: "Invalid region ID: \(regionId)"
            )
        }
        
        // Decode age group ID and map to AgeGroup
        let ageGroupId = try container.decode(Int.self, forKey: .ageGroupId)
        switch ageGroupId {
        case 1: ageGroup = .months12to15
        case 2: ageGroup = .months15to18
        case 3: ageGroup = .months18to21
        case 4: ageGroup = .months21to24
        case 5: ageGroup = .months24to30
        case 6: ageGroup = .months30to36
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .ageGroupId,
                in: container,
                debugDescription: "Invalid age group ID: \(ageGroupId)"
            )
        }
    }
    
    // Encoder function for Encodable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(image_url, forKey: .image)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        
        // Encode bite type as an integer ID
        let biteTypeId: Int
        switch category {
        case .EarlyBite: biteTypeId = 1
        case .NourishBite: biteTypeId = 2
        case .MidDayBite: biteTypeId = 3
        case .SnackBite: biteTypeId = 4
        case .NightBite: biteTypeId = 5
        case .custom: biteTypeId = 99 // Use a default value for custom types
        }
        try container.encode(biteTypeId, forKey: .biteTypeId)
        
        // Encode region as an integer ID
        let regionId: Int
        switch region {
        case .east: regionId = 1
        case .west: regionId = 2
        case .north: regionId = 3
        case .south: regionId = 4
        }
        try container.encode(regionId, forKey: .regionId)
        
        // Encode age group as an integer ID
        let ageGroupId: Int
        switch ageGroup {
        case .months12to15: ageGroupId = 1
        case .months15to18: ageGroupId = 2
        case .months18to21: ageGroupId = 3
        case .months21to24: ageGroupId = 4
        case .months24to30: ageGroupId = 5
        case .months30to36: ageGroupId = 6
        }
        try container.encode(ageGroupId, forKey: .ageGroupId)
    }
    
    // Regular initializer (without DB fields)
    init(name: String, description: String, image: String, category: BiteType, region: RegionType, ageGroup: AgeGroup) {
        self.id = nil
        self.name = name
        self.description = description
        self.image_url = image
        self.category = category
        self.region = region
        self.ageGroup = ageGroup
        self.createdAt = nil
        self.updatedAt = nil
    }
    
    // Initializer to create a copy with a new category
    init(from meal: FeedingMeal, withNewCategory newCategory: BiteType) {
        self.id = meal.id
        self.name = meal.name
        self.description = meal.description
        self.image_url = meal.image_url
        self.category = newCategory
        self.region = meal.region
        self.ageGroup = meal.ageGroup
        self.createdAt = meal.createdAt
        self.updatedAt = meal.updatedAt
    }
}

struct MealRecommendation {
    let ageGroup: AgeGroup
    let region: RegionType
    let meals: [BiteType: [FeedingMeal]]
}

struct MyBowl {
    let childId: String
    var selectedMeals: [BiteType: FeedingMeal]
}

struct FeedingPlan {
    let childId: String
    let schedule: [BiteType: FeedingMeal]
}

struct TodayBite {
    let title: String
    let time: String
    let imageName: String
}

struct MyBowlItem {
    let id: Int
    let bowlId: Int
    let feedingMealId: Int
    let biteTypeId: Int
    let createdAt: Date
}

// Define the Supabase table model for my_Bowl
struct MyBowlEntry: Codable {
    let id: Int?
    let user_id: String?
    let meal_id: Int
    let added_at: String?
    
    init(from meal: FeedingMeal, userId: String?) {
        self.id = nil
        self.meal_id = meal.id ?? 0
        self.user_id = userId
        
        // Set current timestamp in ISO 8601 format
        let formatter = ISO8601DateFormatter()
        self.added_at = formatter.string(from: Date())
    }
}

// Helper struct for parsing my_Bowl table responses
struct MyBowlResponseEntry: Codable {
    let meal_id: Int
}

// Enum for PlanType to match the USER-DEFINED type in Supabase
enum FeedingPlanType: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
}

// Struct for feeding_plan table entries
struct FeedingPlanEntry: Codable {
    let id: Int?
    let user_id: String?
    let feeding_meal_id: Int
    let plan_type: FeedingPlanType
    let start_date: String
    let end_date: String
    let created_at: String?
    
    init(mealId: Int, userId: String, planType: FeedingPlanType, startDate: Date, endDate: Date) {
        self.id = nil
        self.user_id = userId
        self.feeding_meal_id = mealId
        self.plan_type = planType
        
        // Format dates as ISO8601 strings
        let dateFormatter = ISO8601DateFormatter()
        self.start_date = dateFormatter.string(from: startDate)
        self.end_date = dateFormatter.string(from: endDate)
        self.created_at = dateFormatter.string(from: Date())
    }
}

// Utility class for Supabase database operations
class SupabaseManager {
    static func saveToMyBowlDatabase(_ meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot save meal to My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Saving meal to My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Create entry with the user ID
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // Insert with the user ID
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully saved meal to My Bowl database")
        } catch let error {
            print("❌ Error saving to My Bowl database: \(error)")
            
            // Extract error details from the description
            let errorDescription = error.localizedDescription
            print("🔍 Error details: \(errorDescription)")
        }
    }
    
    // Delete a meal from My Bowl in Supabase
    static func deleteFromMyBowlDatabase(mealId: Int, using client: SupabaseClient) async {
        do {
            print("🔄 Deleting meal from My Bowl database, mealId: \(mealId)")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Delete the entry matching both user_id and meal_id
            let response = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            print("✅ Successfully deleted meal from My Bowl database")
        } catch let error {
            print("❌ Error deleting from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Update bite type for a meal in My Bowl
    // Note: In Supabase, we don't directly store the bite_type in my_Bowl table
    // Instead, we'll delete the existing entry and create a new one with the same meal_id
    static func updateBiteTypeInMyBowlDatabase(meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot update meal in My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Updating meal in My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // 1. Delete existing entry
            _ = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            // 2. Create a new entry (with the updated meal which has a new bite type)
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // 3. Insert the new entry
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully updated meal in My Bowl database")
        } catch let error {
            print("❌ Error updating meal in My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Load all My Bowl meals for the current user from database
    static func loadMyBowlMealsFromDatabase(using client: SupabaseClient) async -> [FeedingMeal] {
        var meals: [FeedingMeal] = []
        
        do {
            print("🔄 Loading My Bowl meals from database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Query my_Bowl table to get all meals for this user
            let response = try await client.database
                .from("my_Bowl")
                .select("meal_id")
                .eq("user_id", value: userId)
                .execute()
            
            // Extract meal IDs from response
            if response.data.isEmpty {
                print("❌ No data found in my_Bowl table")
                return []
            }
            
            // Parse the response to get meal IDs
            let decoder = JSONDecoder()
            let bowlEntries = try decoder.decode([MyBowlResponseEntry].self, from: response.data)
            
            // Get all the meal IDs
            let mealIds = bowlEntries.map { $0.meal_id }
            
            if mealIds.isEmpty {
                print("⚠️ No meals found in my_Bowl table")
                return []
            }
            
            print("🔍 Found \(mealIds.count) meals in my_Bowl")
            
            // For each meal ID, fetch the full meal details from the feeding_meals table
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    // Check if mealResponse.data has content
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        let decodedMeals = try decoder.decode([FeedingMeal].self, from: mealResponse.data)
                        
                        if let meal = decodedMeals.first {
                            meals.append(meal)
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            print("✅ Successfully loaded \(meals.count) meals from My Bowl database")
            return meals
            
        } catch let error {
            print("❌ Error loading from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Save feeding plan to the database
    static func saveFeedingPlan(meals: [FeedingMeal], planType: FeedingPlanType, startDate: Date, endDate: Date, using client: SupabaseClient) async -> Bool {
        do {
            print("🔄 Saving feeding plan to database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // For each meal, create a feeding plan entry and save it
            for meal in meals {
                guard let mealId = meal.id else {
                    print("⚠️ Skipping meal without ID: \(meal.name)")
                    continue
                }
                
                let planEntry = FeedingPlanEntry(
                    mealId: mealId,
                    userId: userId,
                    planType: planType,
                    startDate: startDate,
                    endDate: endDate
                )
                
                // Insert into feeding_plan table
                let response = try await client.database
                    .from("feeding_plan")
                    .insert(planEntry)
                    .execute()
                
                print("✅ Added meal to feeding plan: \(meal.name)")
            }
            
            print("✅ Successfully saved feeding plan with \(meals.count) meals")
            return true
            
        } catch let error {
            print("❌ Error saving feeding plan: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return false
        }
    }
    
    // Load feeding plans for a specific date range
    static func loadFeedingPlans(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [FeedingPlanEntry] {
        var planEntries: [FeedingPlanEntry] = []
        
        do {
            print("🔄 Loading feeding plans for date range")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Format dates for query
            let dateFormatter = ISO8601DateFormatter()
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            // Query feeding_plan table for entries in the date range
            let response = try await client.database
                .from("feeding_plan")
                .select("*")
                .eq("user_id", value: userId)
                .gte("start_date", value: startDateString)
                .lte("end_date", value: endDateString)
                .execute()
            
            // Extract plan entries from response
            if !response.data.isEmpty {
                let decoder = JSONDecoder()
                planEntries = try decoder.decode([FeedingPlanEntry].self, from: response.data)
            }
            
            print("✅ Loaded \(planEntries.count) feeding plan entries")
            return planEntries
            
        } catch let error {
            print("❌ Error loading feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Extended method to load feeding plans with meal details
    static func loadFeedingPlansWithMeals(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [String: [BiteType: [FeedingMeal]]] {
        var result: [String: [BiteType: [FeedingMeal]]] = [:]
        
        do {
            print("🔄 Loading feeding plans with meal details")
            
            // First, load all plan entries
            let planEntries = await loadFeedingPlans(startDate: startDate, endDate: endDate, using: client)
            
            if planEntries.isEmpty {
                return result
            }
            
            // Get all unique meal IDs
            let mealIds = Array(Set(planEntries.map { $0.feeding_meal_id }))
            
            // Get date formatter for result keys
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E d MMM" // Same format as getFormattedDate in FeedingPlanViewController
            
            // Fetch meals for all IDs
            var mealDetails: [Int: FeedingMeal] = [:]
            
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        if let meals = try? decoder.decode([FeedingMeal].self, from: mealResponse.data),
                           let meal = meals.first {
                            mealDetails[mealId] = meal
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            // Process each plan entry
            for entry in planEntries {
                guard let meal = mealDetails[entry.feeding_meal_id] else {
                    continue
                }
                
                // Parse the date
                if let entryDate = parseDate(from: entry.start_date) {
                    // Format date as key
                    let dateKey = dateFormatter.string(from: entryDate)
                    
                    // Initialize dictionary for this date if needed
                    if result[dateKey] == nil {
                        result[dateKey] = [:]
                    }
                    
                    // Initialize array for this category if needed
                    if result[dateKey]?[meal.category] == nil {
                        result[dateKey]?[meal.category] = []
                    }
                    
                    // Add meal to the appropriate category
                    result[dateKey]?[meal.category]?.append(meal)
                }
            }
            
            print("✅ Processed feeding plans into \(result.count) days")
            return result
            
        } catch let error {
            print("❌ Error processing feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return [:]
        }
    }
    
    // Helper method to parse ISO date string to Date
    private static func parseDate(from iso8601String: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: iso8601String)
    }
}

// MARK: - Bluetooth Functionality
var dataBuf: Data? = nil // Using optional Data instead of implicitly unwrapped optional

// Function to rebuild packet data from partial data
func rebuiltPacket(data: Data) -> Data? {
    var fullPacket: Data? = nil
    
    if dataBuf == nil {
        dataBuf = data
    } else if let existingData = dataBuf, (existingData.count + data.count) == 20 {
        fullPacket = existingData + data
        dataBuf = nil
    }
    
    return fullPacket
}

// Function to parse complete packet data
func parsePacket(data: Data) {
    guard data.count >= 1 else { return }
    
    let myFirstByte = data[0]
    print("\(myFirstByte)")
}



