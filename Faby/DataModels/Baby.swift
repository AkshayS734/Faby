import Foundation
class Baby {
    var name: String
    var dateOfBirth: String
    var gender: Gender
    var parent: Parent
    var region: String?
    var milestonesAchieved: [GrowthMilestone : Date] = [:]
    var milestoneLeft : [GrowthMilestone] = GrowthMilestonesDataModel().milestones
    var height: [Double: Date] = [:]
    var weight: [Double: Date] = [:]
    var headCircumference: [Double: Date] = [:]
    
    init(name: String, dateOfBirth: String, gender: Gender, parent: Parent) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.parent = parent
    }
    
    func updateMilestonesAchieved(_ milestone: GrowthMilestone, date: Date) {
        if let index = milestoneLeft.firstIndex(where: { $0.id == milestone.id }) {
            milestoneLeft.remove(at: index)
        }
//        print("\(milestone.query) achieved")
        // Add milestone to milestonesAchieved
        milestonesAchieved[milestone] = date
    }
    
    func updateHeight(_ height: Double, date: Date) {
        self.height[height] = date
        print("Updated Height: \(height) on \(date)")
    }
    func updateWeight(_ weight: Double, date: Date) {
        self.weight[weight] = date
        print("Updated Weight: \(weight) on \(date)")
    }
    func updateHeadCircumference(_ headCircumference: Double, date: Date) {
        self.headCircumference[headCircumference] = date
        print("Updated Head Circumference: \(headCircumference) on \(date)")
    }
    
}

enum Gender {
    case male
    case female
}
