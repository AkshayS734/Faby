import Foundation
import UIKit

class Baby {
    var babyID: UUID
    var name: String
    var dateOfBirth: String
    var gender: Gender
    var region: String?
    var milestonesAchieved: [GrowthMilestone: Date] = [:]
    var achievedMilestonesByCategory: [String: [GrowthMilestone]] = [
        "cognitive": [],
        "language": [],
        "physical": [],
        "social": []
    ]
    var milestones: [GrowthMilestone] = GrowthMilestonesDataModel().milestones
    var height: [Double: Date] = [:]
    var weight: [Double: Date] = [:]
    var headCircumference: [Double: Date] = [:]
    var measurementUpdated: (() -> Void)?

    init(babyId : UUID,name: String, dateOfBirth: String, gender: Gender) {
           self.babyID = babyId
           self.name = name
           self.dateOfBirth = dateOfBirth
           self.gender = gender
       }


    func updateMilestonesAchieved(_ milestone: GrowthMilestone, date: Date, image: UIImage? = nil, videoURL: URL? = nil, caption: String? = nil) {
        milestone.isAchieved = true
        let categoryKey = milestone.category.rawValue

        if achievedMilestonesByCategory[categoryKey] == nil {
            achievedMilestonesByCategory[categoryKey] = []
        }
        achievedMilestonesByCategory[categoryKey]?.append(milestone)

        if let image = image {
            saveMilestoneUserImage(for: milestone, image: image, caption: caption)
        }
        
        if let videoURL = videoURL {
            saveMilestoneUserVideo(for: milestone, videoURL: videoURL, caption: caption)
        }

        milestonesAchieved[milestone] = date
        NotificationCenter.default.post(name: .milestonesAchievedUpdated, object: nil)
    }

    func saveMilestoneUserImage(for milestone: GrowthMilestone, image: UIImage, caption: String?) {
        let filename = "\(milestone.id.uuidString)_userImage.jpg"
        print("Saving image: \(filename)")

        if let userImagePath = saveImageToDocumentsDirectory(image: image, filename: filename) {
            milestone.userImagePath = userImagePath
            milestone.caption = caption
            print("Image saved at: \(userImagePath), Caption: \(caption ?? "No caption provided")")
        }
    }

    func saveMilestoneUserVideo(for milestone: GrowthMilestone, videoURL: URL, caption: String?) {
        let filename = "\(milestone.id.uuidString)_userVideo.mp4"
        print("Saving video: \(filename)")

        if let userVideoPath = saveVideoToDocumentsDirectory(videoURL: videoURL, filename: filename) {
            milestone.userVideoPath = userVideoPath
            milestone.caption = caption
            print("Video saved at: \(userVideoPath), Caption: \(caption ?? "No caption provided")")
        }
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

    func saveVideoToDocumentsDirectory(videoURL: URL, filename: String) -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        do {
            try fileManager.copyItem(at: videoURL, to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving video: \(error)")
        }
        return nil
    }

    func loadPredefinedImage(for milestone: GrowthMilestone) -> UIImage? {
        return UIImage(named: milestone.image)
    }

    func loadUserImage(for milestone: GrowthMilestone) -> UIImage? {
        guard let filePath = milestone.userImagePath else {
            return UIImage(named: milestone.image)
        }

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return UIImage(named: milestone.image)
    }

    func updateHeight(_ height: Double, date: Date) {
        self.height[height] = date
        measurementUpdated?()
    }

    func updateWeight(_ weight: Double, date: Date) {
        self.weight[weight] = date
        measurementUpdated?()
    }

    func updateHeadCircumference(_ headCircumference: Double, date: Date) {
        self.headCircumference[headCircumference] = date
        measurementUpdated?()
    }

    func removeHeight(_ height: Double) {
        self.height.removeValue(forKey: height)
        measurementUpdated?()
    }

    func removeWeight(_ weight: Double) {
        self.weight.removeValue(forKey: weight)
        measurementUpdated?()
    }

    func removeHeadCircumference(_ headCircumference: Double) {
        self.headCircumference.removeValue(forKey: headCircumference)
        measurementUpdated?()
    }
}

extension Notification.Name {
    static let milestonesAchievedUpdated = Notification.Name("milestonesAchievedUpdated")
}
