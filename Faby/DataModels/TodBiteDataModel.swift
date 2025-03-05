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
enum RegionType: String, CaseIterable {
    case east = "East"
    case west = "West"
    case north = "North"
    case south = "South"
}
enum AgeGroup: String, CaseIterable {
    case months12to18 = "12-18 months"
    case months18to24 = "18-24 months"
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



