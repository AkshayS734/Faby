import Foundation
class Baby {
    var name: String
    var dateOfBirth: Date
    var gender: Gender
    var parent: Parent
    
    var milestonesAchieved: [GrowthMilestone : Date] = [:]
    var height: [Double: Date] = [:]
    var weight: [Double: Date] = [:]
    var headCircumference: [Double: Date] = [:]
    
    init(name: String, dateOfBirth: Date, gender: Gender, parent: Parent) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.parent = parent
    }
    
    func updateMilestonesAchieved(_ milestone: GrowthMilestone, date: Date) {
        milestonesAchieved[milestone] = date
    }
    
    func updateHeight(_ height: Double, date: Date) {
        self.height[height] = date
    }
    func updateWeight(_ weight: Double, date: Date) {
        self.weight[weight] = date
    }
    func updateHeadCircumference(_ headCircumference: Double, date: Date) {
        self.headCircumference[headCircumference] = date
    }
}

enum Gender {
    case male
    case female
}
