import Foundation
import UIKit
import Supabase

class ToddlerTalkDataController {
    // Singleton pattern
    static let shared = ToddlerTalkDataController()
    
    // Use PostsSupabaseManager for Supabase operations
    private let supabaseManager = PostsSupabaseManager.shared
    
    // Image cache
    private let imageCache = NSCache<NSString, UIImage>()
    
    // Private initializer for singleton
    private init() {}
    
    // MARK: - Topics Methods
    
    /// Fetches all topics from Supabase
    /// - Parameter completion: Callback with topics array or error
    func fetchTopics(completion: @escaping ([Topics]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching topics")
        supabaseManager.fetchTopics { topics, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error fetching topics: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let topics = topics {
                print("✅ ToddlerTalkDataController: Successfully fetched \(topics.count) topics")
                // Cache topics in UserDefaults
                self.cacheTopics(topics)
                completion(topics, nil)
            } else {
                completion(nil, NSError(domain: "ToddlerTalkDataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "No topics found"]))
            }
        }
    }
    
    /// Loads topics from local cache
    /// - Returns: Array of cached topics or nil if cache is empty
    func loadCachedTopics() -> [Topics]? {
        let topicsCacheKey = "cachedTopics"
        if let cachedData = UserDefaults.standard.data(forKey: topicsCacheKey),
           let topics = try? JSONDecoder().decode([Topics].self, from: cachedData) {
            print("✅ ToddlerTalkDataController: Loaded \(topics.count) topics from cache")
            return topics
        } else {
            print("⚠️ ToddlerTalkDataController: No cached topics found")
            return nil
        }
    }
    
    /// Caches topics in UserDefaults
    /// - Parameter topics: Array of topics to cache
    private func cacheTopics(_ topics: [Topics]) {
        let topicsCacheKey = "cachedTopics"
        if let encodedData = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encodedData, forKey: topicsCacheKey)
            print("✅ ToddlerTalkDataController: Cached \(topics.count) topics")
        }
    }
    
    // MARK: - Image Loading Methods
    
    /// Loads an image from a URL with caching
    /// - Parameters:
    ///   - urlString: URL string of the image
    ///   - completion: Callback with the loaded image or nil if failed
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ ToddlerTalkDataController: Invalid image URL: \(urlString)")
            completion(nil)
            return
        }
        
        // Check memory cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            print("✅ ToddlerTalkDataController: Image loaded from memory cache")
            completion(cachedImage)
            return
        }
        
        // Check disk cache
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            imageCache.setObject(image, forKey: urlString as NSString)
            print("✅ ToddlerTalkDataController: Image loaded from disk cache")
            completion(image)
            return
        }
        
        // Load from network
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                print("❌ ToddlerTalkDataController: Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the response
            if let response = response {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            }
            
            // Cache the image in memory
            self.imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                print("✅ ToddlerTalkDataController: Image loaded from network")
                completion(image)
            }
        }
        task.resume()
    }
    
    // MARK: - Posts Methods
    
    /// Fetches posts for a specific topic
    /// - Parameters:
    ///   - topicId: UUID of the topic
    ///   - completion: Callback with posts array or error
    func fetchPosts(for topicId: UUID, completion: @escaping ([Post]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching posts for topic: \(topicId)")
        supabaseManager.fetchPosts(for: topicId) { posts, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error fetching posts: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let posts = posts {
                print("✅ ToddlerTalkDataController: Successfully fetched \(posts.count) posts")
                completion(posts, nil)
            } else {
                completion(nil, NSError(domain: "ToddlerTalkDataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "No posts found"]))
            }
        }
    }
    
    /// Fetches posts for the current user
    /// - Parameter completion: Callback with posts array or error
    func fetchUserPosts(completion: @escaping ([Post]?, Error?) -> Void) {
        guard let userIdString = AuthManager.shared.currentUserID,
              let userId = UUID(uuidString: userIdString) else {
            print("❌ ToddlerTalkDataController: User not logged in or invalid user ID")
            completion(nil, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Fetching posts for user: \(userId)")
        supabaseManager.fetchUserPosts(for: userId) { posts, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error fetching user posts: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let posts = posts {
                print("✅ ToddlerTalkDataController: Successfully fetched \(posts.count) user posts")
                completion(posts, nil)
            } else {
                completion(nil, NSError(domain: "ToddlerTalkDataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "No user posts found"]))
            }
        }
    }
    
    /// Adds a new post
    /// - Parameters:
    ///   - title: Title of the post
    ///   - content: Content of the post
    ///   - topicID: UUID of the topic
    ///   - imageData: Optional image data
    ///   - completion: Callback with success boolean and optional error
    func addPost(title: String, content: String, topicID: UUID, imageData: Data?, completion: @escaping (Bool, Error?) -> Void) {
        guard let userIdString = AuthManager.shared.currentUserID,
              let userId = UUID(uuidString: userIdString) else {
            print("❌ ToddlerTalkDataController: User not logged in or invalid user ID")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Adding post with title: \(title)")
        supabaseManager.addPost(title: title, content: content, topicID: topicID, userID: userId, imageData: imageData) { success, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error adding post: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if success {
                print("✅ ToddlerTalkDataController: Successfully added post")
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "ToddlerTalkDataController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add post"]))
            }
        }
    }
    
    // MARK: - Comments Methods
    
    /// Fetches comments for a specific post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with comments array or error
    func fetchComments(for postId: String, completion: @escaping ([Comment]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching comments for post: \(postId)")
        supabaseManager.fetchComments(for: postId) { comments, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error fetching comments: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let comments = comments {
                print("✅ ToddlerTalkDataController: Successfully fetched \(comments.count) comments")
                completion(comments, nil)
            } else {
                completion(nil, NSError(domain: "ToddlerTalkDataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "No comments found"]))
            }
        }
    }
    
    /// Adds a comment to a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - content: Content of the comment
    ///   - completion: Callback with success boolean and optional error
    func addComment(postId: String, content: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Adding comment to post: \(postId)")
        supabaseManager.addComment(postId: postId, userId: userId, content: content) { success, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error adding comment: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if success {
                print("✅ ToddlerTalkDataController: Successfully added comment")
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "ToddlerTalkDataController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add comment"]))
            }
        }
    }
    
    // MARK: - Likes Methods
    
    /// Adds a like to a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with success boolean and optional error
    func addLike(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Adding like to post: \(postId)")
        supabaseManager.addLike(postId: postId, userId: userId) { success, error in
            if let error = error {
                print("❌ ToddlerTalkDataController: Error adding like: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if success {
                print("✅ ToddlerTalkDataController: Successfully added like")
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "ToddlerTalkDataController", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to add like"]))
            }
        }
    }
    
    /// Fetches all post IDs that the current user has liked
    /// - Parameter completion: Callback with a set of post IDs and optional error
    func fetchLikedPostIds(completion: @escaping (Set<String>, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching liked post IDs")
        supabaseManager.fetchLikedPostIds(completion: completion)
    }
    
    /// Checks if the current user has liked a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with boolean result and optional error
    func checkIfUserLiked(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Checking if user liked post: \(postId)")
        supabaseManager.checkIfUserLiked(postId: postId, userId: userId, completion: completion)
    }
    
    /// Fetches the like count for a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with like count and optional error
    func fetchPostLikeCount(postId: String, completion: @escaping (Int, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching like count for post: \(postId)")
        supabaseManager.fetchPostLikeCount(postId: postId, completion: completion)
    }
    
    // MARK: - Saved Posts Methods
    
    /// Saves a post for the current user
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with success boolean and optional error
    func savePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Saving post: \(postId)")
        supabaseManager.savePost(postId: postId, completion: completion)
    }
    
    /// Unsaves a post for the current user
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with success boolean and optional error
    func unsavePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Unsaving post: \(postId)")
        supabaseManager.unsavePost(postId: postId, completion: completion)
    }
    
    /// Checks if a post is saved by the current user
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with boolean result and optional error
    func isPostSaved(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Checking if post is saved: \(postId)")
        supabaseManager.isPostSaved(postId: postId, completion: completion)
    }
    
    /// Fetches all saved posts for the current user
    /// - Parameter completion: Callback with posts array or error
    func fetchSavedPosts(completion: @escaping ([Post]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching saved posts")
        supabaseManager.fetchSavedPosts(completion: completion)
    }
    
    // MARK: - Comment Replies Methods
    
    /// Adds a reply to a comment
    /// - Parameters:
    ///   - commentId: Int ID of the comment being replied to
    ///   - postId: String ID of the post
    ///   - content: Content of the reply
    ///   - completion: Callback with success boolean and optional error
    func addCommentReply(commentId: Int, postId: String, content: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Adding reply to comment: \(commentId)")
        supabaseManager.addCommentReply(commentId: commentId, postId: postId, userId: userId, content: content, completion: completion)
    }
    
    /// Fetches replies for a specific comment
    /// - Parameters:
    ///   - commentId: Int ID of the comment
    ///   - completion: Callback with comment replies array or error
    func fetchRepliesForComment(commentId: Int, completion: @escaping ([CommentReply]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching replies for comment: \(commentId)")
        supabaseManager.fetchRepliesForComment(commentId: commentId, completion: completion)
    }
    
    /// Fetches all replies for a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with comment replies array or error
    func fetchAllRepliesForPost(postId: String, completion: @escaping ([CommentReply]?, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Fetching all replies for post: \(postId)")
        supabaseManager.fetchAllRepliesForPost(postId: postId, completion: completion)
    }
    
    // MARK: - Comment Likes Methods
    
    /// Adds a like to a comment
    /// - Parameters:
    ///   - commentId: String ID of the comment
    ///   - completion: Callback with success boolean and optional error
    func addCommentLike(commentId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Adding like to comment: \(commentId)")
        supabaseManager.addCommentLike(commentId: commentId, userId: userId, completion: completion)
    }
    
    /// Removes a like from a comment
    /// - Parameters:
    ///   - commentId: String ID of the comment
    ///   - completion: Callback with success boolean and optional error
    func removeCommentLike(commentId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Removing like from comment: \(commentId)")
        supabaseManager.removeCommentLike(commentId: commentId, userId: userId, completion: completion)
    }
    
    /// Checks if the current user has liked a comment
    /// - Parameters:
    ///   - commentId: String ID of the comment
    ///   - completion: Callback with boolean result and optional error
    func checkIfUserLikedComment(commentId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = AuthManager.shared.currentUserID else {
            print("❌ ToddlerTalkDataController: User not logged in")
            completion(false, NSError(domain: "ToddlerTalkDataController", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔄 ToddlerTalkDataController: Checking if user liked comment: \(commentId)")
        supabaseManager.checkIfUserLikedComment(commentId: commentId, userId: userId, completion: completion)
    }
    
    // MARK: - Post Management Methods
    
    /// Deletes a post
    /// - Parameters:
    ///   - postId: String ID of the post
    ///   - completion: Callback with success boolean and optional error
    func deletePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("🔄 ToddlerTalkDataController: Deleting post: \(postId)")
        supabaseManager.deletePost(postId: postId, completion: completion)
    }
    
    /// Generates a deep link for a post
    /// - Parameter post: Post object
    /// - Returns: URL for deep linking or nil if failed
    func generatePostDeepLink(for post: Post) -> URL? {
        return supabaseManager.generatePostDeepLink(for: post)
    }
    
    /// Generates a web link for a post
    /// - Parameter post: Post object
    /// - Returns: URL for web sharing or nil if failed
    func generatePostWebLink(for post: Post) -> URL? {
        return supabaseManager.generatePostWebLink(for: post)
    }
}
