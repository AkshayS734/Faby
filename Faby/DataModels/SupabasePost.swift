import Foundation

/// Model representing a post in the Supabase posts table
struct SupabasePost: Codable {
    let postId: String
    let postTitle: String
    let postContent: String
    let topicId: String
    let createdAt: String
    let userId: String
    let image_url: String?
    
    // Convert to the app's Post model
    func toPost() -> Post {
        return Post(
            username: "User ID: \(userId.prefix(8))...",
            title: postTitle,
            text: postContent,
            likes: 0, // No likes field in the actual data
            replies: []
        )
    }
}
