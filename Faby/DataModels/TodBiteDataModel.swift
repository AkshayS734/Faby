import UIKit

// MARK: - Enum Definitions

/// Represents different meal categories for a toddler's daily nutrition.
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
        case .custom(let name): return name  // ✅ Custom names allowed
        }
    }

    // ✅ Static allCases for predefined values (no dynamic cases here)
    static let predefinedCases: [BiteType] = [.EarlyBite, .NourishBite, .MidDayBite, .SnackBite, .NightBite]
}




/// Represents geographical regions, potentially useful for localized meal plans.
enum RegionType: String, CaseIterable {
    case east = "East"
    case west = "West"
    case north = "North"
    case south = "South"
}


/// Represents age groups in months for appropriate meal planning.
enum AgeGroup: String, CaseIterable {
    case months12to18 = "12-18 months"
    case months18to24 = "18-24 months"
    case months24to30 = "24-30 months"
    case months30to36 = "30-36 months"
}


// MARK: - FeedingItem Model

struct FeedingMeal {
    let name: String
    let description: String
    let image: String
    let category: BiteType
    let region: RegionType // ✅ Added region filter
    let ageGroup: AgeGroup // ✅ Added age filter
}











// MARK: - MealRecommendation Model

/// Stores meal recommendations categorized by age group and region.
struct MealRecommendation {
    let ageGroup: AgeGroup
    let region: RegionType
    let meals: [BiteType: [FeedingMeal]] // Dictionary mapping BiteCategory to FeedingItems
}

// MARK: - MyBowl Model

/// Stores parent-selected meals before finalizing the Feeding Plan.
struct MyBowl {
    let childId: String
    var selectedMeals: [BiteType: FeedingMeal] // Selected meals for each BiteCategory
}

// MARK: - FeedingPlan Model

/// Represents the final feeding plan for a child, structured by BiteCategory.
struct FeedingPlan {
    let childId: String
    let schedule: [BiteType: FeedingMeal] // Parent's finalized meal selection per BiteCategory
}

struct TodayBite {
    let title: String
    let time: String
    let imageName: String
}



