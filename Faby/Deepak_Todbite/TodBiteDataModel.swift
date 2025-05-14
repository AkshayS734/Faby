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
    let category: String?
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

