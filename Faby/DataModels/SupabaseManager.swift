import Supabase
import UIKit
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()
    let client = SupabaseClient(supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY")
    
    func getCurrentUserID() async -> String? {
        do {
            let session = try await client.auth.session
            return session.user.id.uuidString
        } catch {
            print("Error fetching user ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchBabyData(for userID: String?, completion: @escaping (Baby?) -> Void) {
        guard let userID = userID, !userID.isEmpty else {
            print("No valid user ID. User might not be signed in.")
            completion(nil)
            return
        }
        
        Task {
            do {
                let parentResponse = try await client
                    .from("parents")
                    .select("uid")
                    .eq("uid", value: userID)
                    .single()
                    .execute()
                
                guard let parentData = try? JSONSerialization.jsonObject(with: parentResponse.data, options: []) as? [String: Any],
                      let parentUID = parentData["uid"] as? String else {
                    print("Parent not found")
                    completion(nil)
                    return
                }
                
                let babyResponse = try await client
                    .from("baby")
                    .select("*")
                    .eq("user_id", value: parentUID)
                    .single()
                    .execute()
                
                guard let babyData = try? JSONSerialization.jsonObject(with: babyResponse.data, options: []) as? [String: Any] else {
                    print("Failed to decode baby data")
                    completion(nil)
                    return
                }
                
                let baby = Baby(
                    babyId: UUID(uuidString: babyData["uid"] as? String ?? "") ?? UUID(),
                    name: babyData["name"] as? String ?? "",
                    dateOfBirth: babyData["dateOfBirth"] as? String ?? "",
                    gender: Gender(rawValue: (babyData["gender"] as? String ?? "").lowercased()) ?? .other
                )
                
                completion(baby)
            } catch {
                print("Error fetching baby data: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func fetchMilestones(completion: @escaping ([GrowthMilestone]) -> Void) {
        Task {
            do {
                let response = try await client
                    .from("growth_milestones")
                    .select()
                    .execute()
                
                let milestones = try JSONDecoder().decode([GrowthMilestone].self, from: response.data)
                
                DispatchQueue.main.async {
                    completion(milestones)
                }
            } catch {
                print("Error fetching milestones: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func loadImageFromPublicBucket(path: String, bucket: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: path) {
//            print("📦 Loaded image from cache: \(path)")
            completion(cachedImage)
            return
        }
        
        // Else fetch from Supabase
        Task {
            do {
                let signedURL = try await client.storage
                    .from(bucket)
                    .createSignedURL(path: path, expiresIn: 60)
                
                let imageURL = signedURL
                
                URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    if error != nil {
//                        print("❌ Error loading image: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    guard let data = data, let image = UIImage(data: data) else {
//                        print("❌ Failed to decode image data")
                        completion(nil)
                        return
                    }

                    // Cache image
                    ImageCache.shared.setImage(image, forKey: path)
                    
                    completion(image)
                }.resume()
                
            } catch {
//                print("❌ Error generating signed URL: \(error)")
                completion(nil)
            }
        }
    }
    func checkBabyExists(babyId: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let response = try await client.database
                    .from("baby")
                    .select()
                    .eq("uid", value: babyId)
                    .execute()

                if response.data.first != nil {
                    completion(true) // Baby exists
                } else {
                    completion(false) // Baby does not exist
                }
            } catch {
                print("❌ Error checking baby existence: \(error)")
                completion(false)
            }
        }
    }
    
    func addAchievedMilestone(babyUID: String, milestoneID: String, image: UIImage?, videoURL: URL?, caption: String?) async {
        var imageUrl: String? = nil
        var videoUrl: String? = nil
        let achievedDate = ISO8601DateFormatter().string(from: Date())
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let fileName = "milestone_images/\(UUID().uuidString).jpg"
            do {
                let _ = try await client.storage.from("milestone-user-media").upload(fileName, data: imageData)
                imageUrl = "https://faby.supabase.co/storage/v1/object/public/milestone-user-media/\(fileName)"
            } catch {
                print("Image upload failed: \(error.localizedDescription)")
            }
        }
        
        if let videoURL = videoURL {
            let fileName = "milestone_videos/\(UUID().uuidString).mp4"
            do {
                let videoData = try Data(contentsOf: videoURL)
                let _ = try await client.storage.from("milestone-user-media").upload(fileName, data: videoData)
                videoUrl = "https://faby.supabase.co/storage/v1/object/public/milestone-user-media/\(fileName)"
            } catch {
                print("Video upload failed: \(error.localizedDescription)")
            }
        }
        
        let milestone = AchievedMilestone(
            baby_uid: babyUID,
            milestone_id: milestoneID,
            achieved_date: achievedDate,
            image_url: imageUrl,
            video_url: videoUrl,
            caption: caption
        )
        do {
            try await client.from("achieved_milestones").insert(milestone).execute()
            print("Milestone added successfully")
        } catch {
            print("Error adding milestone: \(error.localizedDescription)")
        }
    }
    
    private func uploadMedia(
        from localPath: String,
        to folder: String,
        contentType: String
    ) async throws -> String {
        let fileName = URL(fileURLWithPath: localPath).lastPathComponent
        let fileData = try Data(contentsOf: URL(fileURLWithPath: localPath))
        
        try await client.storage
            .from("milestone-user-media")
            .upload(
                "\(folder)/\(fileName)",
                data: fileData,
                options: FileOptions(contentType: contentType)
            )
        
        return "\(folder)/\(fileName)"
    }
    func insertAchievedMilestoneFromLocal(
        babyId: String,
        milestoneId: String,
        achievedDate: Date,
        imagePath: String?,
        videoPath: String?,
        caption: String?
    ) {
        Task {
            var imageURLString: String?
            var videoURLString: String?

            do {
                if let imagePath = imagePath {
                    imageURLString = try await uploadMedia(
                        from: imagePath,
                        to: "achieved-images",
                        contentType: "image/jpeg"
                    )
                    print("✅ Image uploaded: \(imageURLString!)")
                }

                if let videoPath = videoPath {
                    videoURLString = try await uploadMedia(
                        from: videoPath,
                        to: "achieved-videos",
                        contentType: "video/mp4"
                    )
                    print("✅ Video uploaded: \(videoURLString!)")
                }

                let achievedMilestone = AchievedMilestone(
                    baby_uid: babyId,
                    milestone_id: milestoneId,
                    achieved_date: achievedDate.iso8601String(),
                    image_url: imageURLString,
                    video_url: videoURLString,
                    caption: caption
                )

                try await client.database
                    .from("achieved_milestones")
                    .insert([achievedMilestone])
                    .execute()

                print("✅ Successfully inserted milestone in Supabase")

            } catch {
                print("❌ Failed to upload or insert milestone: \(error)")
            }
        }
    }
    func fetchAchievedMilestoneIDs(for babyUID: String, completion: @escaping ([String]) -> Void) {
        Task {
            do {
                let response = try await client
                    .from("achieved_milestones")
                    .select("milestone_id")
                    .eq("baby_uid", value: babyUID)
                    .execute()
                
                let decoded = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]]
                let milestoneIDs = decoded?.compactMap { $0["milestone_id"] as? String } ?? []
                completion(milestoneIDs)
            } catch {
                print("Error fetching achieved milestones: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    func fetchMilestonesWithAchievedStatus(for babyUID: String) async throws -> [GrowthMilestone] {
        let milestonesResponse = try await client
            .from("growth_milestones")
            .select()
            .execute()
        let allMilestones = try JSONDecoder().decode([GrowthMilestone].self, from: milestonesResponse.data)

        let achievedResponse = try await client
            .from("achieved_milestones")
            .select("milestone_id")
            .eq("baby_uid", value: babyUID)
            .execute()

        let achievedData = try JSONSerialization.jsonObject(with: achievedResponse.data, options: []) as? [[String: Any]] ?? []
        let achievedIDs = Set(achievedData.compactMap { ($0["milestone_id"] as? String)?.lowercased() })

        return allMilestones.map { milestone in
            let updated = milestone
            updated.isAchieved = achievedIDs.contains(milestone.id.uuidString.lowercased())
            return updated
        }
    }
    func addMeasurement(for babyId: UUID, type: String, value: Double, date: Date) async throws {
        // Format the date using ISO8601
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)

        // Create an instance of BabyMeasurement struct
        let measurement = BabyMeasurement(
            id : UUID(),
            baby_uid: babyId,
            measurement_type: type,
            value: value,
            date: date
        )
        _ = try await client.database
            .from("baby_measurements")
            .insert([measurement])
            .execute()
    }

    func fetchMeasurements(for babyUID: UUID) async throws -> [BabyMeasurement] {
        let response = try await client
            .from("baby_measurements")
            .select()
            .eq("baby_uid", value: babyUID)
            .order("date", ascending: false)
            .execute()

        let data = response.data
        if data.isEmpty {
            throw NSError(domain: "Supabase", code: 404, userInfo: [NSLocalizedDescriptionKey: "No measurements found for the baby"])
        }

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)

        let measurements = try decoder.decode([BabyMeasurement].self, from: data)
//        print(measurements)
        return measurements
    }
    
    func deleteMeasurement(id: UUID) async throws {
        print("SupaBase: Deleting measurement")
        _ = try await client.database
            .from("baby_measurements")
            .delete()
            .eq("id", value: id)
            .execute()
        print("SupaBase: Measurement deleted")
    }
}
extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
