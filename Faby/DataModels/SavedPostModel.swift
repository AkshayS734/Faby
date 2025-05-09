import Foundation

// Model representing a saved post in Supabase
struct SavedPost: Codable {
    let id: Int
    let created_at: String
    let user_id: String
    let post_id: String
    
    // Helper method to create a mock SavedPost for testing
    static func createMock(id: Int = 1, username: String = "Adarsh") -> SavedPost {
        return SavedPost(
            id: id,
            created_at: ISO8601DateFormatter().string(from: Date()),
            user_id: username, // Using username as user_id for now
            post_id: UUID().uuidString
        )
    }
}

// Model for the combined data of a saved post with post details
struct SavedPostWithDetails {
    let savedPost: SavedPost
    let post: Post
}
