import Foundation
import UIKit

class DataController {
    static private(set) var shared: DataController!
    
    let supabaseManager: SupabaseManager
    
    private init(supabaseManager: SupabaseManager) {
        self.supabaseManager = supabaseManager
    }
    
    static func initialize(supabaseManager: SupabaseManager) {
        guard shared == nil else {
            print("DataController already initialized.")
            return
        }
        shared = DataController(supabaseManager: supabaseManager)
    }
    
    var milestones: [GrowthMilestone] = []
    var measurements: [BabyMeasurement] = []
    
    var baby: Baby?
    
    func loadBabyData() async {
        print("Load baby data Called")
        if let userID = await supabaseManager.getCurrentUserID() {
            print(userID)

            if let fetchedBaby = await supabaseManager.fetchBabyDataAsync(for: userID) {
                self.baby = fetchedBaby
                print(fetchedBaby.babyID.uuidString)
                NotificationCenter.default.post(name: .milestonesAchievedUpdated, object: nil)

                await withCheckedContinuation { continuation in
                    self.loadMilestones(for: fetchedBaby.babyID.uuidString) {
                        continuation.resume()
                    }
                }

                await withCheckedContinuation { continuation in
                    self.loadMeasurements(for: fetchedBaby.babyID) {
                        continuation.resume()
                    }
                }
            } else {
                print("Failed to fetch baby data.")
            }
        } else {
            print("No authenticated user found.")
        }
    }
    
    func updateMilestonesAchieved(_ milestone: inout GrowthMilestone, for baby: Baby, date: Date, image: UIImage?, video: URL?, caption: String?) {
        milestone.isAchieved = true
        milestone.achievedDate = date
        var localImagePath: String? = nil
        var localVideoPath: String? = nil
        
        if let image = image {
            saveMilestoneUserImage(for: milestone, image: image, caption: caption)
            localImagePath = milestone.userImagePath
        }
        
        if let video = video {
            saveMilestoneUserVideo(for: milestone, videoURL: video, caption: caption)
            localVideoPath = milestone.userVideoPath
        }
        
        NotificationCenter.default.post(name: .milestonesAchievedUpdated, object: nil)
        
        supabaseManager.insertAchievedMilestoneFromLocal(
            babyId: baby.babyID.uuidString,
            milestoneId: milestone.id.uuidString,
            achievedDate: date,
            imagePath: localImagePath,
            videoPath: localVideoPath,
            caption: caption
        )
    }
    
    func addHeight(_ height: Double, date: Date) async throws {
        guard let babyUID = baby?.babyID else { return }
        try await supabaseManager.addMeasurement(for: babyUID, type: "height", value: height, date: date)
        baby?.measurementUpdated?()
    }
    
    func addWeight(_ weight: Double, date: Date) async throws {
        guard let babyUID = baby?.babyID else { return }
        try await supabaseManager.addMeasurement(for: babyUID, type: "weight", value: weight, date: date)
        baby?.measurementUpdated?()
    }
    
    func addHeadCircumference(_ headCircumference: Double, date: Date) async throws {
        guard let babyUID = baby?.babyID else { return }
        try await supabaseManager.addMeasurement(for: babyUID, type: "head_circumference", value: headCircumference, date: date)
        baby?.measurementUpdated?()
    }
    func deleteMeasurement(id: UUID) async throws {
//        print("DeleteMeasurement called")
        try await supabaseManager.deleteMeasurement(id: id)
//        print("Measurement ended")
        baby?.measurementUpdated?()
    }
    func saveMilestoneUserImage(for milestone: GrowthMilestone, image: UIImage, caption: String?) {
        let filename = "\(milestone.id.uuidString)_userImage.jpg"
        
        if let userImagePath = saveImageToDocumentsDirectory(image: image, filename: filename) {
            milestone.userImagePath = userImagePath
            milestone.caption = caption
        }
    }
    
    func saveMilestoneUserVideo(for milestone: GrowthMilestone, videoURL: URL, caption: String?) {
        let filename = "\(milestone.id.uuidString)_userVideo.mp4"
        
        if let userVideoPath = saveVideoToDocumentsDirectory(videoURL: videoURL, filename: filename) {
            milestone.userVideoPath = userVideoPath
            milestone.caption = caption
        }
    }
    func saveMedia(for milestone: GrowthMilestone, image: UIImage?, videoURL: URL?, caption: String?) {
        if let image = image {
            saveMilestoneUserImage(for: milestone, image: image, caption: caption)
        }
        if let videoURL = videoURL {
            saveMilestoneUserVideo(for: milestone, videoURL: videoURL, caption: caption)
        }
    }
    
    private func saveImageToDocumentsDirectory(image: UIImage, filename: String) -> String? {
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
    
    private func saveVideoToDocumentsDirectory(videoURL: URL, filename: String) -> String? {
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
    func loadPredefinedMilestoneImage(for milestone: GrowthMilestone) -> UIImage? {
        return UIImage(named: milestone.image)
    }
    
    func loadMilestoneUserImage(for milestone: GrowthMilestone) -> UIImage? {
        guard let filePath = milestone.userImagePath else {
            return UIImage(named: milestone.image)
        }
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return UIImage(named: milestone.image)
    }
    func loadMilestones(for babyUID: String, completion: @escaping () -> Void) {
        Task {
            do {
                let fetched = try await SupabaseManager.shared.fetchMilestonesWithAchievedStatus(for: babyUID)
                DispatchQueue.main.async {
                    self.milestones = fetched
                    completion()
                }
            } catch {
                print("Error loading milestones: \(error.localizedDescription)")
                completion()
            }
        }
    }
    func loadMeasurements(for babyUID: UUID, completion: @escaping () -> Void) {
        Task {
            do {
                let measurements = try await supabaseManager.fetchMeasurements(for: babyUID)
                DispatchQueue.main.async {
                    self.measurements = measurements
                    self.baby?.measurements = measurements
                    completion()
                }
            } catch {
                print("Failed to load measurements: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

extension Notification.Name {
    static let milestonesAchievedUpdated = Notification.Name("milestonesAchievedUpdated")
}

