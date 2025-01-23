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
    
    var measurementUpdated: (() -> Void)?
    
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
        measurementUpdated?()
        
    }
    func updateWeight(_ weight: Double, date: Date) {
        self.weight[weight] = date
        print("Updated Weight: \(weight) on \(date)")
        measurementUpdated?()
    }
    func updateHeadCircumference(_ headCircumference: Double, date: Date) {
        self.headCircumference[headCircumference] = date
        print("Updated Head Circumference: \(headCircumference) on \(date)")
        measurementUpdated?()
    }
    func removeHeight(_ height: Double) {
        self.height.removeValue(forKey: height)
        print("Removed Height: \(height)")
        measurementUpdated?()
    }
        
    func removeWeight(_ weight: Double) {
        self.weight.removeValue(forKey: weight)
        print("Removed Weight: \(weight)")
        measurementUpdated?()
    }
        
    func removeHeadCircumference(_ headCircumference: Double) {
        self.headCircumference.removeValue(forKey: headCircumference)
        print("Removed Head Circumference: \(headCircumference)")
        measurementUpdated?()
    }
}

enum Gender {
    case male
    case female
}
