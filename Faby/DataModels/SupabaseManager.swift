import Supabase
import UIKit
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()
    // Use the shared client from AuthManager to maintain a single authentication session
    var client: SupabaseClient {
        return AuthManager.shared.getClient()
    }
    private let milestoneDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func getCurrentUserID() async -> String? {
        // Use the AuthManager's getCurrentUserID method to ensure consistency
        return await AuthManager.shared.getCurrentUserID()
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
    
    //TodBite
    static func saveToMyBowlDatabase(_ meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot save meal to My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Saving meal to My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Create entry with the user ID
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // Insert with the user ID
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully saved meal to My Bowl database")
        } catch let error {
            print("❌ Error saving to My Bowl database: \(error)")
            
            // Extract error details from the description
            let errorDescription = error.localizedDescription
            print("🔍 Error details: \(errorDescription)")
        }
    }
    
    // Delete a meal from My Bowl in Supabase
    static func deleteFromMyBowlDatabase(mealId: Int, using client: SupabaseClient) async {
        do {
            print("🔄 Deleting meal from My Bowl database, mealId: \(mealId)")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Delete the entry matching both user_id and meal_id
            let response = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            print("✅ Successfully deleted meal from My Bowl database")
        } catch let error {
            print("❌ Error deleting from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Update bite type for a meal in My Bowl
    // Note: In Supabase, we don't directly store the bite_type in my_Bowl table
    // Instead, we'll delete the existing entry and create a new one with the same meal_id
    static func updateBiteTypeInMyBowlDatabase(meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot update meal in My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Updating meal in My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // 1. Delete existing entry
            _ = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            // 2. Create a new entry (with the updated meal which has a new bite type)
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // 3. Insert the new entry
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully updated meal in My Bowl database")
        } catch let error {
            print("❌ Error updating meal in My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Load all My Bowl meals for the current user from database
    static func loadMyBowlMealsFromDatabase(using client: SupabaseClient) async -> [FeedingMeal] {
        var meals: [FeedingMeal] = []
        
        do {
            print("🔄 Loading My Bowl meals from database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Query my_Bowl table to get all meals for this user
            let response = try await client.database
                .from("my_Bowl")
                .select("meal_id")
                .eq("user_id", value: userId)
                .execute()
            
            // Extract meal IDs from response
            if response.data.isEmpty {
                print("❌ No data found in my_Bowl table")
                return []
            }
            
            // Parse the response to get meal IDs
            let decoder = JSONDecoder()
            let bowlEntries = try decoder.decode([MyBowlResponseEntry].self, from: response.data)
            
            // Get all the meal IDs
            let mealIds = bowlEntries.map { $0.meal_id }
            
            if mealIds.isEmpty {
                print("⚠️ No meals found in my_Bowl table")
                return []
            }
            
            print("🔍 Found \(mealIds.count) meals in my_Bowl")
            
            // For each meal ID, fetch the full meal details from the feeding_meals table
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    // Check if mealResponse.data has content
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        let decodedMeals = try decoder.decode([FeedingMeal].self, from: mealResponse.data)
                        
                        if let meal = decodedMeals.first {
                            meals.append(meal)
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            print("✅ Successfully loaded \(meals.count) meals from My Bowl database")
            return meals
            
        } catch let error {
            print("❌ Error loading from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Save feeding plan to the database
    static func saveFeedingPlan(meals: [FeedingMeal], planType: FeedingPlanType, startDate: Date, endDate: Date, using client: SupabaseClient) async -> Bool {
        do {
            print("🔄 Saving feeding plan to database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // For each meal, create a feeding plan entry and save it
            for meal in meals {
                guard let mealId = meal.id else {
                    print("⚠️ Skipping meal without ID: \(meal.name)")
                    continue
                }
                
                let planEntry = FeedingPlanEntry(
                    mealId: mealId,
                    userId: userId,
                    planType: planType,
                    startDate: startDate,
                    endDate: endDate
                )
                
                // Insert into feeding_plan table
                let response = try await client.database
                    .from("feeding_plan")
                    .insert(planEntry)
                    .execute()
                
                print("✅ Added meal to feeding plan: \(meal.name)")
            }
            
            print("✅ Successfully saved feeding plan with \(meals.count) meals")
            return true
            
        } catch let error {
            print("❌ Error saving feeding plan: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return false
        }
    }
    
    // Load feeding plans for a specific date range
    static func loadFeedingPlans(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [FeedingPlanEntry] {
        var planEntries: [FeedingPlanEntry] = []
        
        do {
            print("🔄 Loading feeding plans for date range")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Format dates for query
            let dateFormatter = ISO8601DateFormatter()
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            // Query feeding_plan table for entries in the date range
            let response = try await client.database
                .from("feeding_plan")
                .select("*")
                .eq("user_id", value: userId)
                .gte("start_date", value: startDateString)
                .lte("end_date", value: endDateString)
                .execute()
            
            // Extract plan entries from response
            if !response.data.isEmpty {
                let decoder = JSONDecoder()
                planEntries = try decoder.decode([FeedingPlanEntry].self, from: response.data)
            }
            
            print("✅ Loaded \(planEntries.count) feeding plan entries")
            return planEntries
            
        } catch let error {
            print("❌ Error loading feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Extended method to load feeding plans with meal details
    static func loadFeedingPlansWithMeals(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [String: [BiteType: [FeedingMeal]]] {
        var result: [String: [BiteType: [FeedingMeal]]] = [:]
        
        do {
            print("🔄 Loading feeding plans with meal details")
            
            // First, load all plan entries
            let planEntries = await loadFeedingPlans(startDate: startDate, endDate: endDate, using: client)
            
            if planEntries.isEmpty {
                return result
            }
            
            // Get all unique meal IDs
            let mealIds = Array(Set(planEntries.map { $0.feeding_meal_id }))
            
            // Get date formatter for result keys
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E d MMM" // Same format as getFormattedDate in FeedingPlanViewController
            
            // Fetch meals for all IDs
            var mealDetails: [Int: FeedingMeal] = [:]
            
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        if let meals = try? decoder.decode([FeedingMeal].self, from: mealResponse.data),
                           let meal = meals.first {
                            mealDetails[mealId] = meal
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            // Process each plan entry
            for entry in planEntries {
                guard let meal = mealDetails[entry.feeding_meal_id] else {
                    continue
                }
                
                // Parse the date
                if let entryDate = parseDate(from: entry.start_date) {
                    // Format date as key
                    let dateKey = dateFormatter.string(from: entryDate)
                    
                    // Initialize dictionary for this date if needed
                    if result[dateKey] == nil {
                        result[dateKey] = [:]
                    }
                    
                    // Initialize array for this category if needed
                    if result[dateKey]?[meal.category] == nil {
                        result[dateKey]?[meal.category] = []
                    }
                    
                    // Add meal to the appropriate category
                    result[dateKey]?[meal.category]?.append(meal)
                }
            }
            
            print("✅ Processed feeding plans into \(result.count) days")
            return result
            
        } catch let error {
            print("❌ Error processing feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return [:]
        }
    }
    
    // Helper method to parse ISO date string to Date
    private static func parseDate(from iso8601String: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: iso8601String)
    }
}
extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
