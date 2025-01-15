import Foundation
class GrowthMilestone: Hashable {
    
    var title: String
    var query: String
    var image: String
    var milestoneMonth: Int
    var description: String
//    var reached: Bool = false
//    var reachedDate: Date?
    var category: GrowthCategory
    
    init(title: String,query: String, image: String, milestoneMonth: Int, description: String, category: GrowthCategory) {
        self.title = title
        self.query = query
        self.image = image
        self.milestoneMonth = milestoneMonth
        self.description = description
        self.category = category
    }
    
//    func markReached(for date: Date) {
//        reached = true
//        reachedDate = date
//    }
    
    static func == (lhs: GrowthMilestone, rhs: GrowthMilestone) -> Bool {
        return lhs.title == rhs.title &&
                lhs.query == rhs.query &&
                lhs.image == rhs.image &&
                lhs.milestoneMonth == rhs.milestoneMonth &&
                lhs.description == rhs.description &&
                lhs.category == rhs.category
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(query)
        hasher.combine(image)
        hasher.combine(milestoneMonth)
        hasher.combine(description)
        hasher.combine(category)
    }
    
}

