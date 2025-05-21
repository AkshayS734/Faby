import Foundation
import UIKit

class SavedPostsDataController {
    // Singleton instance
    static let shared = SavedPostsDataController()
    
    // Cache for saved posts
    private var savedPosts: [Post] = []
    
    // Private init for singleton
    private init() {}
    
    // MARK: - Public API
    
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
                print("✅ Loaded \(posts.count) saved posts into SavedPostsDataController")
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
