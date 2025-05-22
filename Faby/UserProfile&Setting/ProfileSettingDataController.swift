import Foundation
import UIKit

class ProfileSettingDataController {
    // Singleton instance
    static let shared = ProfileSettingDataController()
    
    // Cache for saved posts
    private var savedPosts: [Post] = []
    
    // Private init for singleton
    private init() {}
    
    // MARK: - Parent Data Methods
    
    /// Load parent data for the current user
    /// - Parameter completion: Callback with success flag
    func loadParentData(completion: @escaping (Bool) -> Void) {
        Task {
            if let userId = await AuthManager.shared.getCurrentUserID() {
                print("📱 ProfileSettingDataController: Loading parent data for user ID: \(userId)")
                ParentDataModel.shared.updateCurrentParent(userId: userId) { success in
                    if success {
                        print("✅ ProfileSettingDataController: Successfully loaded parent data")
                    } else {
                        print("❌ ProfileSettingDataController: Failed to load parent data")
                    }
                    completion(success)
                }
            } else {
                print("⚠️ ProfileSettingDataController: No user ID available, user might not be logged in")
                completion(false)
            }
        }
    }
    
    /// Get parent profile image
    /// - Parameter completion: Callback with optional UIImage
    func getParentProfileImage(completion: @escaping (UIImage?) -> Void) {
        guard let parent = ParentDataModel.shared.currentParent,
              let imageUrlString = parent.parentimage_url else {
            completion(UIImage(systemName: "person.circle.fill"))
            return
        }
        
        // Extract the path from the URL
        guard let url = URL(string: imageUrlString),
              let path = url.pathComponents.dropFirst().joined(separator: "/").removingPercentEncoding else {
            completion(UIImage(systemName: "person.circle.fill"))
            return
        }
        
        // Load image from Supabase storage
        SupabaseManager.shared.loadImageFromPublicBucket(path: path, bucket: "parent-images") { image in
            completion(image ?? UIImage(systemName: "person.circle.fill"))
        }
    }
    
    /// Update parent profile in the settings view controller
    /// - Parameter viewController: The settings view controller to update
    func updateParentProfileInSettings(viewController: SettingsViewController) {
        if let parent = ParentDataModel.shared.currentParent {
            // Update the profile cell with parent data
            viewController.updateParentInfo(name: parent.name, email: parent.email)
            
            // Load and update the profile image
            getParentProfileImage { image in
                DispatchQueue.main.async {
                    viewController.updateParentProfileImage(image: image)
                }
            }
        }
    }
    
    // MARK: - Saved Posts Methods
    
    /// Loads saved posts from the Supabase database
    /// - Parameter completion: Callback with success flag
    func loadSavedPosts(completion: @escaping (Bool) -> Void) {
        PostsSupabaseManager.shared.fetchSavedPosts { [weak self] posts, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error loading saved posts: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let posts = posts {
                self.savedPosts = posts
                print("✅ Loaded \(posts.count) saved posts into ProfileSettingDataController")
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Get all saved posts
    /// - Returns: Array of saved posts
    func getAllSavedPosts() -> [Post] {
        return savedPosts
    }
    
    /// Remove a post from saved posts
    /// - Parameters:
    ///   - postId: ID of the post to remove
    ///   - completion: Callback with success flag
    func removeFromSavedPosts(postId: String, completion: @escaping (Bool) -> Void) {
        PostsSupabaseManager.shared.unsavePost(postId: postId) { [weak self] success, error in
            guard let self = self else { return }
            
            if success {
                // Update local cache
                self.savedPosts.removeAll { $0.postId == postId }
                print("✅ Post removed from saved posts: \(postId)")
                completion(true)
            } else {
                if let error = error {
                    print("❌ Error removing post from saved: \(error.localizedDescription)")
                }
                completion(false)
            }
        }
    }
    
    /// Checks if a post is saved by the current user
    /// - Parameters:
    ///   - postId: The ID of the post to check
    ///   - completion: Callback with result
    func isPostSaved(postId: String, completion: @escaping (Bool) -> Void) {
        PostsSupabaseManager.shared.isPostSaved(postId: postId) { isSaved, _ in
            completion(isSaved)
        }
    }
}
