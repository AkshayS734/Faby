import Foundation
class GrowthMilestone {
    var title: String
    var query: String
    var image: String
    var dueMonth: Int
    var description: String
    var reached: Bool = false
    var reachedDate: Date?
    var category: GrowthCategory
    
    init(title: String,query: String, image: String, dueMonth: Int, description: String, category: GrowthCategory) {
        self.title = title
        self.query = query
        self.image = image
        self.dueMonth = dueMonth
        self.description = description
        self.category = category
    }
    
    func markReached(for date: Date) {
        reached = true
        reachedDate = date
    }
}

