import Foundation
enum GrowthCategory: String, Codable {
    case cognitive
    case language
    case physical
    case social
}
enum MilestoneMonth: Int, Codable {
    case month12 = 12
    case month15 = 15
    case month18 = 18
    case month24 = 24
    case month30 = 30
    case month36 = 36
}
