import Foundation
import UIKit

class Baby : Encodable{
    var babyID: UUID
    var name: String
    var dateOfBirth: String
    var gender: Gender
    var region: String?
    var imageURL: String?
//    var milestonesAchieved: [GrowthMilestone: Date] = [:]
//    var achievedMilestonesByCategory: [String: [GrowthMilestone]] = [
//        "cognitive": [],
//        "language": [],
//        "physical": [],
//        "social": []
//    ]
//    var milestones: [GrowthMilestone] = GrowthMilestonesDataModel.shared.milestones
    var measurements: [BabyMeasurement] = []
    var measurementUpdated: (() -> Void)?

    init(babyId : UUID,name: String, dateOfBirth: String, gender: Gender) {
        self.babyID = babyId
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
    }
    
    enum CodingKeys: String, CodingKey {
        case babyID = "uid"
        case name
        case dateOfBirth = "dob"
        case gender
        case region
    }
    
    var heightMeasurements: [BabyMeasurement] {
        measurements.filter { $0.measurement_type.lowercased() == "height" }
    }

    var weightMeasurements: [BabyMeasurement] {
        measurements.filter { $0.measurement_type.lowercased() == "weight" }
    }

    var headCircumferenceMeasurements: [BabyMeasurement] {
        measurements.filter { $0.measurement_type.lowercased() == "head circumference" }
    }
}

struct AchievedMilestone: Codable {
    let baby_uid: String
    let milestone_id: String
    let achieved_date: String
    let image_url: String?
    let video_url: String?
    let caption: String?
}
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

class GrowthMilestone: Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var query: String
    var image: String
    var userImagePath: String?
    var userVideoPath: String?
    var caption : String?
    var milestoneMonth: MilestoneMonth
    var achievedDate: Date? = nil
    var description: String
    var category: GrowthCategory
    var isAchieved = false
    
    init(title: String,subtitle: String,query: String, image: String, milestoneMonth: MilestoneMonth, description: String, category: GrowthCategory) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.query = query
        self.image = image
        self.milestoneMonth = milestoneMonth
        self.description = description
        self.category = category
    }
    
    static func == (lhs: GrowthMilestone, rhs: GrowthMilestone) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(query)
        hasher.combine(image)
        hasher.combine(milestoneMonth)
        hasher.combine(description)
        hasher.combine(category)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case query
        case image
        case milestoneMonth = "milestone_month"
        case description
        case category
    }
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decode(String.self, forKey: .subtitle)
            query = try container.decode(String.self, forKey: .query)
            image = try container.decode(String.self, forKey: .image)
            milestoneMonth = try container.decode(MilestoneMonth.self, forKey: .milestoneMonth)
            description = try container.decode(String.self, forKey: .description)
            category = try container.decode(GrowthCategory.self, forKey: .category)
        }
    
}
struct BabyMeasurement: Codable {
    let id: UUID
    let baby_uid: UUID
    let measurement_type: String
    let value: Double
    let date: Date
}

//struct NewBabyMeasurement: Encodable {
//    let baby_uid: UUID
//    let measurement_type: String
//    let value: Double
//    let date: Date
//}
