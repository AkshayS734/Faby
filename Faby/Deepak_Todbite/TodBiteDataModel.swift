import UIKit


enum BiteType: Hashable {
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
}

// MARK: - Geographical Hierarchy

enum ContinentType: String, CaseIterable {
    case asia = "Asia"
    case africa = "Africa"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case australia = "Australia"
    case antarctica = "Antarctica"
}

enum CountryType: String, CaseIterable {
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

enum RegionType: String, CaseIterable {
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

enum AgeGroup: String, CaseIterable {
    case months12to15 = "12-15 months"
    case months15to18 = "15-18 months"
    case months18to21 = "18-21 months"
    case months21to24 = "21-24 months"
    case months24to30 = "24-30 months"
    case months30to36 = "30-36 months"
}

struct FeedingMeal {
    let name: String
    let description: String
    let image: String
    let category: BiteType
    let region: RegionType
    let ageGroup: AgeGroup
    
    // Optional country-specific properties
    var countrySpecificNotes: String? = nil
    var localName: String? = nil
    var culturalSignificance: String? = nil
    var dietaryRestrictions: [String]? = nil
    
    // Convenience initializer that includes the original parameters
    init(name: String, description: String, image: String, category: BiteType, region: RegionType, ageGroup: AgeGroup) {
        self.name = name
        self.description = description
        self.image = image
        self.category = category
        self.region = region
        self.ageGroup = ageGroup
    }
    
    // Extended initializer with country-specific fields
    init(name: String, description: String, image: String, category: BiteType, region: RegionType, ageGroup: AgeGroup, 
         countrySpecificNotes: String? = nil, localName: String? = nil, culturalSignificance: String? = nil, dietaryRestrictions: [String]? = nil) {
        self.name = name
        self.description = description
        self.image = image
        self.category = category
        self.region = region
        self.ageGroup = ageGroup
        self.countrySpecificNotes = countrySpecificNotes
        self.localName = localName
        self.culturalSignificance = culturalSignificance
        self.dietaryRestrictions = dietaryRestrictions
    }
    
    // Helper computed properties for the geographical hierarchy
    var country: CountryType {
        return region.country
    }
    
    var continent: ContinentType {
        return country.continent
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



