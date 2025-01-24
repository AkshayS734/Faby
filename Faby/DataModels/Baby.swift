import Foundation
import UIKit

class Baby {
    var name: String
    var dateOfBirth: String
    var gender: Gender
    var parent: Parent
    var region: String?
    var milestonesAchieved: [GrowthMilestone : Date] = [:]
    var milestoneLeft: [GrowthMilestone] = GrowthMilestonesDataModel().milestones
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
    
    func updateMilestonesAchieved(_ milestone: GrowthMilestone, date: Date, image: UIImage? = nil) {
        if let index = milestoneLeft.firstIndex(where: { $0.id == milestone.id }) {
            milestoneLeft.remove(at: index)
        }
        if let image = image {
            saveMilestoneUserImage(for: milestone, image: image)
        }
        milestonesAchieved[milestone] = date
        NotificationCenter.default.post(name: .milestonesAchievedUpdated, object: nil)
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, filename: String) -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: fileURL)
                return fileURL.path
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }
    
    func saveMilestoneUserImage(for milestone: GrowthMilestone, image: UIImage) {
        let filename = "\(milestone.id.uuidString)_userImage.jpg"
        if let userImagePath = saveImageToDocumentsDirectory(image: image, filename: filename) {
            milestone.userImagePath = userImagePath
        }
    }
    
    func loadPredefinedImage(for milestone: GrowthMilestone) -> UIImage? {
        return UIImage(named: milestone.image)
    }
    
    func loadUserImage(for milestone: GrowthMilestone) -> UIImage? {
        guard let filePath = milestone.userImagePath else {
            return UIImage(named : milestone.image)
        }
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return UIImage(named : milestone.image)
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
extension Notification.Name {
    static let milestonesAchievedUpdated = Notification.Name("milestonesAchievedUpdated")
}
