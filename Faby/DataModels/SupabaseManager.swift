import Supabase
import UIKit
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()
    let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")
    private let milestoneDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func getCurrentUserID() async -> String? {
        do {
            let session = try await client.auth.session
            print("User id Successfully Fetched: \(session.user.id.uuidString)")
            return session.user.id.uuidString
        } catch {
            print("Error fetching user ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchBabyData(for userID: String?, completion: @escaping (Baby?) -> Void) {
        print("Fetch baby data called ....")
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
    func fetchBabyDataAsync(for userID: String?) async -> Baby? {
        await withCheckedContinuation { continuation in
            fetchBabyData(for: userID) { baby in
                continuation.resume(returning: baby)
            }
        }
    }
    
    func loadImageFromPublicBucket(path: String, bucket: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: path) {
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
                completion(nil)
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

    func fetchAchievedMilestoneMap(for babyUID: String) async throws -> [String: [String: Any]] {
        let response = try await client
            .from("achieved_milestones")
            .select("milestone_id, image_url, video_url, caption, achieved_date")
            .eq("baby_uid", value: babyUID)
            .execute()

        let data = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] ?? []

        return Dictionary(
            uniqueKeysWithValues: data.compactMap {
                guard let id = $0["milestone_id"] as? String else { return nil }
                return (id.lowercased(), $0)
            }
        )
    }

    func fetchMilestonesWithAchievedStatus(for babyUID: String) async throws -> [GrowthMilestone] {
            let milestonesResponse = try await client
                .from("growth_milestones")
                .select()
                .execute()

            var allMilestones = try JSONDecoder().decode([GrowthMilestone].self, from: milestonesResponse.data)
            let achievedMap = try await fetchAchievedMilestoneMap(for: babyUID)

            allMilestones = allMilestones.map { milestone in
                var updated = milestone
                if let data = achievedMap[milestone.id.uuidString.lowercased()] {
                    updated.isAchieved = true
                    updated.userImagePath = data["image_url"] as? String
                    updated.userVideoPath = data["video_url"] as? String
                    updated.caption = data["caption"] as? String

                    if let dateString = data["achieved_date"] as? String {
                        updated.achievedDate = milestoneDateFormatter.date(from: dateString)
                    }
                }
                return updated
            }

            return allMilestones
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
//        print("SupaBase: Deleting measurement")
        _ = try await client.database
            .from("baby_measurements")
            .delete()
            .eq("id", value: id)
            .execute()
//        print("SupaBase: Measurement deleted")
    }
    
    func fetchMediaFromMilestoneBucket(path: String, isImage: Bool, completion: @escaping (Any?) -> Void) {
        if isImage {
            if let cachedImage = ImageCache.shared.getImage(forKey: path) {
                completion(cachedImage)
                return
            }
        } else {
            if let cachedVideoURL = VideoCache.shared.getVideoURL(forKey: path) {
                completion(cachedVideoURL)
                return
            }
        }

        Task {
            do {
                let signedURL = try await client.storage
                    .from("milestone-user-media")
                    .createSignedURL(path: path, expiresIn: 60)
//                print("🪵 Generating signed URL for path: \(path)")
                
                if isImage {
                    URLSession.shared.dataTask(with: signedURL) { data, response, error in
                        if let error = error {
                            print("❌ Error loading image: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }

                        guard let data = data, let image = UIImage(data: data) else {
                            print("❌ Failed to decode image from data")
                            completion(nil)
                            return
                        }

                        // Cache image
                        ImageCache.shared.setImage(image, forKey: path)
                        completion(image)
                    }.resume()
                } else {
                    // Cache video URL for later use
                    VideoCache.shared.setVideoURL(signedURL, forKey: path)
                    completion(signedURL)
                }

            } catch {
                print("🧪 Trying to sign file with path: '\(path)'")
                print("❌ Failed to create signed URL: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
