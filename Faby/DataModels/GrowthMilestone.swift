import Foundation
class GrowthMilestone: Hashable {
    let id: UUID
    var title: String
    var subtitle: String
    var query: String
    var image: String
    var userImagePath: String? 
    var milestoneMonth: MilestoneMonth
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
    
}

