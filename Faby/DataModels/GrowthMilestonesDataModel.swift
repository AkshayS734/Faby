import Foundation
class GrowthMilestonesDataModel {
    static let shared = GrowthMilestonesDataModel()
    var growthMilestones: [GrowthMilestone]
    
    private init() {
        growthMilestones = []
    }
    
}
