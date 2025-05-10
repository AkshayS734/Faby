import Foundation
import Supabase
import UIKit

class SupabaseManager {
    static let shared = SupabaseManager() // Singleton instance
    
    let client: SupabaseClient
    var userID: String? // Add userID property 
    
    private init() {
        let supabaseURL = URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // ✅ Login Function
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                // Use the provided email and password instead of hardcoded values
                let session = try await client.auth.signIn(email: "test2@gmail.com", password: "123456")
                let userID = session.user.id.uuidString // ✅ convert UUID to String
                self.userID = userID // Set the userID property
                print("✅ Successfully logged in as: \(userID)")
                
                // Fetch parent data after successful login
                ParentDataModel.shared.updateCurrentParent(userId: userID) { success in
                    if success {
                        print("✅ Successfully fetched parent data")
                        completion(.success(userID))
                    } else {
                        print("⚠️ Failed to fetch parent data, but login was successful")
                        // Still return success since login worked
                        completion(.success(userID))
                    }
                }
            } catch {
                print("❌ Login failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // ✅ Fetch All Topics
    func fetchTopics(completion: @escaping ([Topics]?, Error?) -> Void) {
        print("📢 fetchTopics() called")
        
        Task {
            do {
                if let session = try? await client.auth.session {
                    print("✅ Authenticated User: \(session.user.id)")
                } else {
                    completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
                    return
                }
                
                let response = try await client
                    .database
                    .from("topics")
                    .select()
                    .execute()
                
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("📜 Raw JSON: \(jsonString)")
                }
                
                let decodedTopics = try JSONDecoder().decode([Topics].self, from: response.data)
                completion(decodedTopics, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    // Fetch Posts for a Specific Topic
    func fetchPosts(for topicId: UUID, completion: @escaping ([Post]?, Error?) -> Void) {
        print("📢 fetchPosts(for:) called with topicId: \(topicId)")
        
        Task {
            do {
                let response = try await client.database
                    .from("posts")
                    .select("""
                        postId, 
                        postTitle, 
                        postContent, 
                        topicId, 
                        userId, 
                        createdAt, 
                        image_url,
                        parents(name)
                    """)
                    .eq("topicId", value: topicId.uuidString)
                    .order("createdAt", ascending: false)  // Sort by creation date, newest first
                    .execute()
                
                if let rawData = String(data: response.data, encoding: .utf8) {
                    print("🔍 Filtered Supabase Data: \(rawData)")
                }
                
                let decodedPosts = try JSONDecoder().decode([Post].self, from: response.data)
                DispatchQueue.main.async {
                    completion(decodedPosts, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Error fetching filtered posts: \(error.localizedDescription)")
                    completion(nil, error)
                }
            }
        }
    }
    
    // Fetch Posts for a Specific User
    func fetchUserPosts(for userId: UUID, completion: @escaping ([Post]?, Error?) -> Void) {
        print("📢 fetchUserPosts() called with userId: \(userId)")
        
        Task {
            do {
                print("🔍 Constructing query for userId: \(userId.uuidString)")
                let response = try await client.database
                    .from("posts")
                    .select("""
                        postId, 
                        postTitle, 
                        postContent, 
                        topicId, 
                        userId, 
                        createdAt, 
                        image_url,
                        parents(name)
                    """)
                    .eq("userId", value: userId.uuidString)
                    .order("createdAt", ascending: false)
                    .execute()
                
                print("✅ Received response from Supabase")
                
                if let rawData = String(data: response.data, encoding: .utf8) {
                    print("🔍 User Posts Raw Data: \(rawData)")
                } else {
                    print("⚠️ No raw data received from Supabase")
                }
                
                print("🔍 Attempting to decode posts...")
                let decodedPosts = try JSONDecoder().decode([Post].self, from: response.data)
                print("✅ Successfully decoded \(decodedPosts.count) posts")
                
                if decodedPosts.isEmpty {
                    print("⚠️ No posts found for user \(userId.uuidString)")
                } else {
                    for post in decodedPosts {
                        print("📝 Post Details:")
                        print("   - Title: \(post.postTitle)")
                        print("   - Created At: \(post.createdAt ?? "no date")")
                        print("   - User ID: \(post.userId ?? "no user id")")
                        print("   - Topic ID: \(post.topicId)")
                    }
                }
                
                DispatchQueue.main.async {
                    print("✅ Sending \(decodedPosts.count) posts to completion handler")
                    completion(decodedPosts, nil)
                }
            } catch {
                print("❌ Error in fetchUserPosts:")
                print("   - Description: \(error.localizedDescription)")
                print("   - Error Type: \(type(of: error))")
                print("   - Error Details: \(error)")
                completion(nil, error)
            }
        }
    }
    
    // Helper function to compress image data
    private func compressImageData(_ imageData: Data) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        // Start with 0.8 compression quality
        var compression: CGFloat = 0.8
        var maxBytes = 500 * 1024 // 500KB target size
        var compressedData = image.jpegData(compressionQuality: compression)
        
        // Reduce image quality until it's under maxBytes
        while (compressedData?.count ?? 0) > maxBytes && compression > 0.1 {
            compression -= 0.1
            compressedData = image.jpegData(compressionQuality: compression)
        }
        
        return compressedData
    }
    
    // ✅ Upload image to Supabase Storage
    func uploadImage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        print("📢 uploadImage() called")
        print("📢 Original image size: \(Double(imageData.count) / 1024.0)KB")
        
        // Compress image
        guard let compressedData = compressImageData(imageData) else {
            print("❌ Failed to compress image")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])))
            return
        }
        
        print("📢 Compressed image size: \(Double(compressedData.count) / 1024.0)KB")
        
        let fileName = "\(UUID().uuidString).jpg"
        print("📢 Generated filename: \(fileName)")
        
        Task {
            do {
                // Upload to storage
                print("📢 Uploading to postimages bucket...")
                _ = try await client.storage
                    .from("postimages")
                    .upload(
                        path: fileName,
                        file: compressedData
                    )
                print("✅ File uploaded successfully")
                
                // Generate public URL
                let publicUrl = "https://hlkmrimpxzsnxzrgofes.supabase.co/storage/v1/object/public/postimages/\(fileName)"
                print("✅ Generated public URL: \(publicUrl)")
                
                completion(.success(publicUrl))
            } catch {
                print("❌ Error in uploadImage: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // Add New Post with Image
    func addPost(title: String, content: String, topicID: UUID, userID: UUID, imageData: Data?, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 addPost() called")
        print("📢 Parameters received - Title: \(title), TopicID: \(topicID), UserID: \(userID)")
        
        Task {
            do {
                var imageUrl: String? = nil
                
                // Step 1: Upload image if provided
                if let imageData = imageData {
                    print("📢 Step 1: Image data found, starting upload...")
                    let uploadResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                        uploadImage(imageData: imageData) { result in
                            switch result {
                            case .success(let url):
                                continuation.resume(returning: url)
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                    imageUrl = uploadResult
                    print("✅ Step 1: Image uploaded, URL received: \(imageUrl ?? "nil")")
                }
                
                // Step 2: Create post object
                print("📢 Step 2: Creating post object...")
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFullDate, .withFullTime, .withTimeZone]
                let createdAt = isoFormatter.string(from: Date())
                print("📅 Created timestamp: \(createdAt)")
                
                let newPost = Post(
                    postId: UUID().uuidString,
                    postTitle: title,
                    postContent: content,
                    topicId: topicID.uuidString,
                    userId: userID.uuidString,
                    createdAt: createdAt,
                    parents: nil,
                    image_url: imageUrl
                )
                print("✅ Step 2: Post object created")
                
                // Step 3: Insert post into database
                print("📢 Step 3: Inserting post into database...")
                try await client.database
                    .from("posts")
                    .insert(newPost)
                    .execute()
                print("✅ Step 3: Post inserted successfully")
                
                // Step 4: Verify post creation
                print("📢 Step 4: Verifying post creation...")
                let response: [Post] = try await client.database
                    .from("posts")
                    .select()
                    .eq("postId", value: newPost.postId)
                    .execute()
                    .value
                
                if let post = response.first {
                    print("✅ Step 4: Post verified in database")
                    print("✅ Created post details:")
                    print("   - Post ID: \(post.postId)")
                    print("   - Title: \(post.postTitle)")
                    print("   - Created At: \(post.createdAt ?? "No date")")
                    print("   - Image URL: \(post.image_url ?? "No image")")
                    completion(true, nil)
                } else {
                    throw NSError(domain: "PostVerification", code: -1, userInfo: [NSLocalizedDescriptionKey: "Post not found after creation"])
                }
            } catch {
                print("❌ Error in addPost: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }
    
    // Fetch Post Like Count
    func fetchPostLikeCount(postId: String, completion: @escaping (Int, Error?) -> Void) {
        print("📢 fetchPostLikeCount() called for post: \(postId)")
        
        Task {
            do {
                // Query Likes table to get likes count for the specific postId
                let response = try await client.database
                    .from("Likes")
                    .select("user_id")
                    .eq("post_id", value: postId)
                    .execute()
                
                // Parse the JSON array to count likes
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    let likeCount = jsonArray.count
                    print("✅ Post \(postId) has \(likeCount) likes")
                    
                    DispatchQueue.main.async {
                        completion(likeCount, nil)
                    }
                } else {
                    print("⚠️ Failed to parse post likes response, returning 0")
                    DispatchQueue.main.async {
                        completion(0, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ Error fetching post like count: \(error.localizedDescription)")
                    completion(0, error)
                }
            }
        }
    }
    
    // Fetch Posts Liked by Users (Filtered by Likes)
    // This function is being kept for backward compatibility
    func fetchPostsLikedByUsers(postId: String, completion: @escaping ([Likes]?, Error?) -> Void) {
        print("📢 fetchPostsLikedByUsers() called for post: \(postId)")
        
        // For performance, we'll use the streamlined fetchPostLikeCount function
        // and return empty likes array with the count
        fetchPostLikeCount(postId: postId) { count, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Create dummy likes objects - most callers only use the count
            var likes: [Likes] = []
            for _ in 0..<count {
                likes.append(Likes(Like_id: nil, user_id: "", post_id: postId, created_at: nil))
            }
            
            completion(likes, nil)
        }
    }
    
    // MARK: - Like Management
    
    func addLike(postId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 addLike() called for post: \(postId) by user: \(userId)")
        
        Task {
            do {
                // Step 1: Create a new Like object
                let newLike = [
                    "user_id": userId,
                    "post_id": postId,
                    "created_at": ISO8601DateFormatter().string(from: Date())
                ]
                
                print("📤 Inserting like with data: \(newLike)")
                
                // Step 2: Insert new Like into Supabase
                let insertResponse = try await client.database
                    .from("Likes")
                    .insert(newLike)
                    .select()  // Get the inserted row back
                    .execute()
                
                if let rawString = String(data: insertResponse.data, encoding: .utf8) {
                    print("📦 Insert response: \(rawString)")
                }
                
                // Step 3: Verify the like was added
                let verifyResponse = try await client.database
                    .from("Likes")
                    .select("post_id")
                    .eq("post_id", value: postId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: verifyResponse.data, encoding: .utf8) {
                    print("📦 Verification response: \(rawString)")
                }
                
                if !verifyResponse.data.isEmpty {
                    print("✅ Like verified in database")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("❌ Failed to verify like in database")
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "LikesError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to verify like was added"]))
                    }
                }
            } catch {
                print("❌ Error adding like: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                print("❌ Error type: \(type(of: error))")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func removeLike(postId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 removeLike() called for post: \(postId) by user: \(userId)")
        
        Task {
            do {
                // Delete the like
                let deleteResponse = try await client.database
                    .from("Likes")
                    .delete()
                    .eq("post_id", value: postId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: deleteResponse.data, encoding: .utf8) {
                    print("📦 Delete response: \(rawString)")
                }
                
                // If we got a response with data, it means the delete was successful
                // and returned the deleted row(s)
                if !deleteResponse.data.isEmpty {
                    print("✅ Like successfully removed")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("⚠️ No like found to remove")
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "LikesError", code: 101, userInfo: [NSLocalizedDescriptionKey: "No like found to remove"]))
                    }
                }
            } catch {
                print("❌ Error removing like: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func checkIfUserLiked(postId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 checkIfUserLiked() called for post: \(postId) by user: \(userId)")
        
        Task {
            do {
                let response = try await client.database
                    .from("Likes")
                    .select("Like_id")
                    .eq("post_id", value: postId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Check response: \(rawString)")
                }
                
                let isLiked = !response.data.isEmpty
                print(isLiked ? "✅ User has liked the post" : "⚠️ User has not liked the post")
                
                DispatchQueue.main.async {
                    completion(isLiked, nil)
                }
            } catch {
                print("❌ Error checking like status: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func fetchLikedPostIds(completion: @escaping (Set<String>, Error?) -> Void) {
        print("📢 fetchLikedPostIds() called")
        
        guard let userId = self.userID else {
            print("❌ User not logged in")
            completion(Set<String>(), NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("🔍 Fetching liked posts for user ID: \(userId)")
        
        Task {
            do {
                // Fetch likes for the specific user
                print("🔍 Fetching likes for user...")
                let response = try await client.database
                    .from("Likes")
                    .select("post_id")
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 User likes response: \(rawString)")
                }
                
                // Parse the response
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    print("📦 Parsed JSON array: \(jsonArray)")
                    
                    let postIds = jsonArray.compactMap { dict -> String? in
                        if let postId = dict["post_id"] as? String {
                            print("✅ Found post_id: \(postId)")
                            return postId
                        } else {
                            print("⚠️ Could not extract post_id from: \(dict)")
                            return nil
                        }
                    }
                    
                    print("✅ Successfully extracted \(postIds.count) post IDs")
                    print("📝 Post IDs: \(postIds)")
                    
                    DispatchQueue.main.async {
                        completion(Set(postIds), nil)
                    }
                } else {
                    print("⚠️ Failed to parse response as JSON array")
                    print("📦 Raw response data: \(String(data: response.data, encoding: .utf8) ?? "Unable to convert to string")")
                    DispatchQueue.main.async {
                        completion(Set<String>(), nil)
                    }
                }
            } catch {
                print("❌ Error fetching liked posts: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                print("❌ Error type: \(type(of: error))")
                DispatchQueue.main.async {
                    completion(Set<String>(), error)
                }
            }
        }
    }
    
    // MARK: - Comments
    func addComment(postId: String, userId: String, content: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 addComment() called for post: \(postId) by user: \(userId)")
        
        Task {
            do {
                let newComment = [
                    "post_id": postId,
                    "user_id": userId,
                    "Comment_content": content,
                    "created_at": ISO8601DateFormatter().string(from: Date())
                ]
                
                print("📤 Inserting comment into database with data: \(newComment)")
                
                // First, verify the table exists and we can query it
                print("🔍 Verifying Comments table...")
                let tableCheck = try await client.database
                    .from("Comments")
                    .select("*")
                    .limit(1)
                    .execute()
                
                print("📊 Table check response: \(String(data: tableCheck.data, encoding: .utf8) ?? "no data")")
                
                // Insert the comment
                print("📤 Attempting to insert comment...")
                let response = try await client.database
                    .from("Comments")
                    .insert(newComment)
                    .select()  // Get the inserted row back
                    .execute()
                
                // Print raw response for debugging
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Insert response: \(rawString)")
                }
                
                // Verify the comment was inserted
                print("🔍 Verifying comment insertion...")
                let verifyResponse = try await client.database
                    .from("Comments")
                    .select("*")
                    .eq("post_id", value: postId)
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                
                if let verifyString = String(data: verifyResponse.data, encoding: .utf8) {
                    print("📦 Verification response: \(verifyString)")
                }
                
                if !verifyResponse.data.isEmpty {
                    print("✅ Comment verified in database")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("⚠️ Comment not found in verification check")
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "CommentError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to verify comment was added"]))
                    }
                }
                
            } catch {
                print("❌ Error adding comment: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func fetchComments(for postId: String, completion: @escaping ([Comment]?, Error?) -> Void) {
        print("📢 fetchComments() called for post: \(postId)")
        
        Task {
            do {
                // First verify we're authenticated
                if let session = try? await client.auth.session {
                    print("✅ Authenticated as user: \(session.user.id)")
                } else {
                    print("⚠️ No authenticated session")
                }
                
                print("🔍 Fetching comments from database...")
                print("🔍 Using post_id: \(postId)")
                
                // Only select columns that exist in the database
                let response = try await client.database
                    .from("Comments")
                    .select("""
                        Comment_id,
                        post_id, 
                        user_id, 
                        Comment_content, 
                        created_at,
                        parents(name)
                    """)
                    .eq("post_id", value: postId)
                    .order("created_at", ascending: false)
                    .execute()
                
                // Print raw response for debugging
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Raw response for post \(postId): \(rawString)")
                }
                
                let decoder = JSONDecoder()
                var comments = try decoder.decode([Comment].self, from: response.data)
                print("✅ Successfully decoded \(comments.count) comments")
                
                // Now for each comment, get the reply count
                if !comments.isEmpty {
                    // Create a group to manage multiple async calls
                    let group = DispatchGroup()
                    
                    for i in 0..<comments.count {
                        if let commentId = comments[i].commentId {
                            group.enter()
                            
                            // Get reply count for this comment
                            self.getReplyCount(for: commentId) { count in
                                // Update the comment with reply count
                                comments[i].repliesCount = count
                                group.leave()
                            }
                        }
                    }
                    
                    // Wait for all reply counts to be fetched
                    group.notify(queue: .main) {
                        print("✅ Successfully updated all comments with reply counts")
                        completion(comments, nil)
                    }
                } else {
                    // No comments to process
                    DispatchQueue.main.async {
                        completion(comments, nil)
                    }
                }
            } catch {
                print("❌ Error fetching comments: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // Helper function to get reply count for a comment
    private func getReplyCount(for commentId: Int, completion: @escaping (Int) -> Void) {
        Task {
            do {
                // Query to count replies for this comment
                let response = try await client.database
                    .from("CommentReplies")
                    .select("reply_id")
                    .eq("comment_id", value: commentId)
                    .execute()
                
                // Parse the JSON array to count replies
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    let replyCount = jsonArray.count
                    print("✅ Comment \(commentId) has \(replyCount) replies")
                    
                    DispatchQueue.main.async {
                        completion(replyCount)
                    }
                } else {
                    print("⚠️ Failed to parse comment replies response, returning 0")
                    DispatchQueue.main.async {
                        completion(0)
                    }
                }
            } catch {
                print("❌ Error counting replies: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(0)
                }
            }
        }
    }
    
    func addCommentLike(commentId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 addCommentLike() called for comment: \(commentId) by user: \(userId)")
        
        // Convert string commentId to Int
        guard let commentNumericId = Int(commentId) else {
            print("❌ Invalid comment ID format: \(commentId)")
            completion(false, NSError(domain: "CommentLikeError", code: 104, userInfo: [NSLocalizedDescriptionKey: "Invalid comment ID format"]))
            return
        }
        
        Task {
            do {
                // Create a new CommentLike object with numeric ID
                let newCommentLike = CommentLikeRequest(
                    user_id: userId,
                    comment_id: commentNumericId,
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                
                print("📤 Inserting comment like with data: \(newCommentLike)")
                
                // Insert into CommentLikes table
                let insertResponse = try await client.database
                    .from("CommentLikes")
                    .insert(newCommentLike)
                    .select()
                    .execute()
                
                if let rawString = String(data: insertResponse.data, encoding: .utf8) {
                    print("📦 Insert response: \(rawString)")
                }
                
                // Verify the like was added
                let verifyResponse = try await client.database
                    .from("CommentLikes")
                    .select("id")
                    .eq("comment_id", value: commentNumericId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: verifyResponse.data, encoding: .utf8) {
                    print("📦 Verify response: \(rawString)")
                }
                
                if !verifyResponse.data.isEmpty {
                    print("✅ Comment like verified in database")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    print("❌ Failed to verify comment like in database")
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "CommentLikeError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to verify comment like was added"]))
                    }
                }
            } catch {
                print("❌ Error adding comment like: \(error.localizedDescription)")
                print("❌ Error details: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func removeCommentLike(commentId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 removeCommentLike() called for comment: \(commentId) by user: \(userId)")
        
        // Convert string commentId to Int
        guard let commentNumericId = Int(commentId) else {
            print("❌ Invalid comment ID format: \(commentId)")
            completion(false, NSError(domain: "CommentLikeError", code: 104, userInfo: [NSLocalizedDescriptionKey: "Invalid comment ID format"]))
            return
        }
        
        Task {
            do {
                // Add extra check to see if like exists before attempting to delete
                let checkResponse = try await client.database
                    .from("CommentLikes")
                    .select("id")
                    .eq("comment_id", value: commentNumericId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: checkResponse.data, encoding: .utf8) {
                    print("📦 Check existing like response: \(rawString)")
                }
                
                let likesExist = !checkResponse.data.isEmpty
                print(likesExist ? "✅ Found existing like to delete" : "⚠️ No existing like found")
                
                // Delete the comment like
                let deleteResponse = try await client.database
                    .from("CommentLikes")
                    .delete()
                    .eq("comment_id", value: commentNumericId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: deleteResponse.data, encoding: .utf8) {
                    print("📦 Delete response: \(rawString)")
                }
                
                // Parse the response to determine success
                if let jsonArray = try? JSONSerialization.jsonObject(with: deleteResponse.data, options: []) as? [[String: Any]], !jsonArray.isEmpty {
                    print("✅ Comment like successfully removed")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    // If we didn't find any likes to begin with, still return success
                    if !likesExist {
                        print("⚠️ No comment like found to remove, but that's ok")
                        DispatchQueue.main.async {
                            completion(true, nil)
                        }
                    } else {
                        print("❌ Failed to remove comment like")
                        DispatchQueue.main.async {
                            completion(false, NSError(domain: "CommentLikeError", code: 101, userInfo: [NSLocalizedDescriptionKey: "Failed to remove existing like"]))
                        }
                    }
                }
            } catch {
                print("❌ Error removing comment like: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func checkIfUserLikedComment(commentId: String, userId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 checkIfUserLikedComment() called for comment: \(commentId) by user: \(userId)")
        
        // Convert string commentId to Int
        guard let commentNumericId = Int(commentId) else {
            print("❌ Invalid comment ID format: \(commentId)")
            completion(false, NSError(domain: "CommentLikeError", code: 104, userInfo: [NSLocalizedDescriptionKey: "Invalid comment ID format"]))
            return
        }
        
        Task {
            do {
                let response = try await client.database
                    .from("CommentLikes")
                    .select("id")
                    .eq("comment_id", value: commentNumericId)
                    .eq("user_id", value: userId)
                    .execute()
                
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Check response: \(rawString)")
                }
                
                // Parse JSON to determine if liked
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    let isLiked = !jsonArray.isEmpty
                    print(isLiked ? "✅ User has liked comment \(commentId)" : "⚠️ User has not liked comment \(commentId)")
                    
                    DispatchQueue.main.async {
                        completion(isLiked, nil)
                    }
                } else {
                    print("⚠️ Failed to parse like check response, assuming not liked")
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
            } catch {
                print("❌ Error checking comment like status: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func fetchCommentLikes(commentId: String, completion: @escaping (Int, Error?) -> Void) {
        print("📢 fetchCommentLikes() called for comment: \(commentId)")
        
        // Convert string commentId to Int
        guard let commentNumericId = Int(commentId) else {
            print("❌ Invalid comment ID format: \(commentId)")
            completion(0, NSError(domain: "CommentLikeError", code: 104, userInfo: [NSLocalizedDescriptionKey: "Invalid comment ID format"]))
            return
        }
        
        Task {
            do {
                // Get all likes for this specific comment ID
                let response = try await client.database
                    .from("CommentLikes")
                    .select("id")
                    .eq("comment_id", value: commentNumericId)
                    .execute()
                
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Likes count response for comment \(commentNumericId): \(rawString)")
                }
                
                // Parse the JSON array to count likes
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    let likeCount = jsonArray.count
                    print("✅ Comment \(commentNumericId) has \(likeCount) likes")
                    
                    DispatchQueue.main.async {
                        completion(likeCount, nil)
                    }
                } else {
                    print("⚠️ Failed to parse comment likes response, returning 0")
                    DispatchQueue.main.async {
                        completion(0, nil)
                    }
                }
            } catch {
                print("❌ Error fetching comment likes: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(0, error)
                }
            }
        }
    }
    
    // MARK: - Comment Replies
    func addCommentReply(commentId: Int, postId: String, userId: String, content: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 addCommentReply() called for comment: \(commentId), post: \(postId), by user: \(userId)")
        
        Task {
            do {
                // Create a CommentReply object using our updated struct
                let reply = CommentReply(
                    commentId: commentId,
                    postId: postId,
                    userId: userId,
                    replyContent: content,
                    createdAt: ISO8601DateFormatter().string(from: Date())
                )
                
                print("📤 Inserting reply with data: \(reply)")
                
                // Insert using the CommentReply struct which conforms to Encodable
                let response = try await client.database
                    .from("CommentReplies")
                    .insert(reply)
                    .execute()
                
                print("✅ Insert response status: \(response.status)")
                if response.status >= 200 && response.status < 300 {
                    print("✅ Reply added successfully!")
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    let errorMessage = String(data: response.data, encoding: .utf8) ?? "Unknown error"
                    print("❌ Insert failed with status: \(response.status), message: \(errorMessage)")
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "ReplyError", code: response.status, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                    }
                }
            } catch {
                print("❌ Error adding reply: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    func fetchRepliesForComment(commentId: Int, completion: @escaping ([CommentReply]?, Error?) -> Void) {
        print("📢 fetchRepliesForComment() called for comment: \(commentId)")
        
        Task {
            do {
                print("🔍 Fetching replies from database...")
                
                // Fetch replies with parent name
                let response = try await client.database
                    .from("CommentReplies")
                    .select("""
                        reply_id,
                        comment_id,
                        post_id, 
                        user_id, 
                        reply_content, 
                        created_at,
                        parents(name)
                    """)
                    .eq("comment_id", value: commentId)
                    .order("created_at", ascending: true) // Show oldest replies first
                    .execute()
                
                // Print raw response for debugging
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Raw response for comment \(commentId): \(rawString)")
                }
                
                let decoder = JSONDecoder()
                let replies = try decoder.decode([CommentReply].self, from: response.data)
                print("✅ Successfully decoded \(replies.count) replies")
                
                DispatchQueue.main.async {
                    completion(replies, nil)
                }
                
            } catch {
                print("❌ Error fetching replies: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func fetchAllRepliesForPost(postId: String, completion: @escaping ([CommentReply]?, Error?) -> Void) {
        print("📢 fetchAllRepliesForPost() called for post: \(postId)")
        
        Task {
            do {
                print("🔍 Fetching all replies for post...")
                
                // Fetch all replies for a post
                let response = try await client.database
                    .from("CommentReplies")
                    .select("""
                        reply_id,
                        comment_id,
                        post_id, 
                        user_id, 
                        reply_content, 
                        created_at,
                        parents(name)
                    """)
                    .eq("post_id", value: postId)
                    .order("created_at", ascending: false)
                    .execute()
                
                // Print raw response for debugging
                if let rawString = String(data: response.data, encoding: .utf8) {
                    print("📦 Raw response for post \(postId) replies: \(rawString)")
                }
                
                let decoder = JSONDecoder()
                let replies = try decoder.decode([CommentReply].self, from: response.data)
                print("✅ Successfully decoded \(replies.count) replies for post")
                
                DispatchQueue.main.async {
                    completion(replies, nil)
                }
                
            } catch {
                print("❌ Error fetching post replies: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // MARK: - Saved Posts Management
    func savePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = self.userID else {
            print("❌ User not logged in")
            completion(false, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("📢 savePost() called for post: \(postId)")
        print("📢 Current user ID: \(userId)")
        
        // First check if the post is already saved to avoid duplicate entries
        self.isPostSaved(postId: postId) { isSaved, _ in
            if isSaved {
                print("⚠️ Post is already saved, no need to save again")
                completion(true, nil)
                return
            }
            
            // Post is not saved, proceed with saving
            Task {
                do {
                    // Since your database has post_id as UUID type but our Post.postId is String,
                    // we need to check if the postId can be converted to a UUID
                    if let uuid = UUID(uuidString: postId) {
                        // Valid UUID format, we can use it directly
                        let savedPost = [
                            "user_id": userId,
                            "post_id": uuid.uuidString,
                            "created_at": ISO8601DateFormatter().string(from: Date())
                        ]
                        
                        print("📢 Saving post with data: \(savedPost)")
                        print("📢 Checking if post exists in Posts table...")
                        
                        // First check if the post exists in the Posts table
                        let postCheckResponse = try await self.client.database
                            .from("posts")
                            .select("postId")
                            .eq("postId", value: postId)
                            .execute()
                        
                        if let postCheckJson = String(data: postCheckResponse.data, encoding: .utf8) {
                            print("📄 Post check response: \(postCheckJson)")
                            
                            if let postArray = try? JSONSerialization.jsonObject(with: postCheckResponse.data) as? [Any], postArray.isEmpty {
                                print("❌ Error: Post with ID \(postId) does not exist in Posts table")
                                DispatchQueue.main.async {
                                    completion(false, NSError(domain: "SavePostError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found"]))
                                }
                                return
                            }
                        }
                        
                        // Post exists, attempt to save it
                        let response = try await self.client.database
                            .from("SavedPosts")
                            .insert(savedPost)
                            .execute()
                        
                        print("✅ Save post response status: \(response.status)")
                        print("📄 Response data: \(String(data: response.data, encoding: .utf8) ?? "None")")
                        
                        DispatchQueue.main.async {
                            if response.status >= 200 && response.status < 300 {
                                completion(true, nil)
                            } else {
                                let errorMessage = String(data: response.data, encoding: .utf8) ?? "Unknown error"
                                print("❌ Error saving post: \(errorMessage)")
                                completion(false, NSError(domain: "SavePostError", code: response.status, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                            }
                        }
                    } else {
                        // Not a valid UUID format, this is likely why the save is failing
                        print("❌ Error: postId \(postId) is not in UUID format, cannot save to SavedPosts table with UUID column")
                        let errorDetail = "The post ID format is incompatible with the database schema. Post IDs must be in UUID format."
                        DispatchQueue.main.async {
                            completion(false, NSError(domain: "SavePostError", code: 400, userInfo: [NSLocalizedDescriptionKey: errorDetail]))
                        }
                    }
                } catch {
                    print("❌ Error saving post: \(error.localizedDescription)")
                    print("❌ Detailed error: \(error)")
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
    }
    
    func unsavePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = self.userID else {
            print("❌ User not logged in")
            completion(false, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("📢 unsavePost() called for post: \(postId)")
        
        Task {
            do {
                // Check if postId is in valid UUID format
                if let _ = UUID(uuidString: postId) {
                    let response = try await client.database
                        .from("SavedPosts")
                        .delete()
                        .eq("post_id", value: postId)
                        .eq("user_id", value: userId)
                        .execute()
                    
                    print("✅ Unsave post response status: \(response.status)")
                    print("📄 Response data: \(String(data: response.data, encoding: .utf8) ?? "None")")
                    
                    DispatchQueue.main.async {
                        if response.status >= 200 && response.status < 300 {
                            completion(true, nil)
                        } else {
                            let errorMessage = String(data: response.data, encoding: .utf8) ?? "Unknown error"
                            print("❌ Error unsaving post: \(errorMessage)")
                            completion(false, NSError(domain: "UnsavePostError", code: response.status, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                        }
                    }
                } else {
                    // Not a valid UUID format
                    print("❌ Error: postId \(postId) is not in UUID format, cannot unsave from SavedPosts table with UUID column")
                    let errorDetail = "The post ID format is incompatible with the database schema. Post IDs must be in UUID format."
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "UnsavePostError", code: 400, userInfo: [NSLocalizedDescriptionKey: errorDetail]))
                    }
                }
            } catch {
                print("❌ Error unsaving post: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    // Enhanced version of isPostSaved for debugging
    func debugIsPostSaved(postId: String, completion: @escaping (Bool) -> Void) {
        print("🔍 DEBUG: Checking if post \(postId) is saved for user \(self.userID ?? "nil")")
        
        Task {
            do {
                // Check if postId is in valid UUID format
                if let _ = UUID(uuidString: postId) {
                    print("✅ DEBUG: Valid UUID format: \(postId)")
                    
                    // Check database
                    print("🔍 DEBUG: Querying SavedPosts table...")
                    
                    let response = try await client.database
                        .from("SavedPosts")
                        .select("id, user_id, post_id")
                        .eq("post_id", value: postId)
                        .eq("user_id", value: self.userID)
                        .execute()
                    
                    print("📋 DEBUG: Raw response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
                    
                    let isSaved = !response.data.isEmpty
                    
                    if isSaved {
                        print("✅ DEBUG: Post IS saved (non-empty response)")
                    } else {
                        print("⚠️ DEBUG: Post is NOT saved (empty response)")
                    }
                    
                    // Try to parse the response
                    if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                        print("📊 DEBUG: Parsed \(jsonArray.count) records from response")
                        
                        for (index, record) in jsonArray.enumerated() {
                            print("📝 DEBUG: Record #\(index + 1):")
                            print("   - id: \(record["id"] ?? "nil")")
                            print("   - user_id: \(record["user_id"] ?? "nil")")
                            print("   - post_id: \(record["post_id"] ?? "nil")")
                        }
                    } else {
                        print("⚠️ DEBUG: Failed to parse response as JSON array")
                    }
                    
                    DispatchQueue.main.async {
                        completion(isSaved)
                    }
                } else {
                    // Not a valid UUID format
                    print("❌ DEBUG: Invalid UUID format: \(postId)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("❌ DEBUG: Error checking save status: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func fetchSavedPosts(completion: @escaping ([Post]?, Error?) -> Void) {
        guard let userId = self.userID else {
            print("❌ User not logged in")
            completion(nil, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("📢 fetchSavedPosts() called")
        
        Task {
            do {
                // First get all saved post IDs
                let savedPostsResponse = try await client.database
                    .from("SavedPosts")
                    .select("post_id")
                    .eq("user_id", value: userId)
                    .execute()
                
                // Print raw response for debugging
                print("📄 Saved posts raw response: \(String(data: savedPostsResponse.data, encoding: .utf8) ?? "None")")
                
                guard !savedPostsResponse.data.isEmpty else {
                    print("ℹ️ No saved posts found")
                    DispatchQueue.main.async {
                        completion([], nil)
                    }
                    return
                }
                
                // Parse the response to get post IDs
                guard let jsonArray = try? JSONSerialization.jsonObject(with: savedPostsResponse.data, options: []) as? [[String: Any]] else {
                    print("❌ Error parsing saved posts response")
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "SavedPostsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse saved posts"]))
                    }
                    return
                }
                
                // The post_id might be a UUID or a string in the database
                let postIds = jsonArray.compactMap { 
                    if let postIdString = $0["post_id"] as? String {
                        return postIdString
                    } 
                    // Add other type conversions if necessary
                    return nil
                }
                
                print("📊 Found \(postIds.count) saved post IDs: \(postIds)")
                
                if postIds.isEmpty {
                    DispatchQueue.main.async {
                        completion([], nil)
                    }
                    return
                }
                
                // Fetch all posts with these IDs
                var postsQuery = client.database.from("posts").select("""
                    postId, 
                    postTitle, 
                    postContent, 
                    topicId, 
                    userId, 
                    createdAt, 
                    image_url,
                    parents(name)
                """)
                
                // Use in() filter with the list of post IDs
                if let postIdsJson = try? JSONEncoder().encode(postIds),
                   let postIdsJsonString = String(data: postIdsJson, encoding: .utf8) {
                    postsQuery = postsQuery.filter("postId", operator: "in", value: postIdsJsonString)
                    let postsResponse = try await postsQuery.execute()
                    
                    print("📄 Posts response: \(String(data: postsResponse.data, encoding: .utf8) ?? "None")")
                    
                    let decodedPosts = try JSONDecoder().decode([Post].self, from: postsResponse.data)
                    print("✅ Fetched \(decodedPosts.count) saved posts")
                    
                    DispatchQueue.main.async {
                        completion(decodedPosts, nil)
                    }
                } else {
                    print("❌ Failed to encode post IDs to JSON")
                    DispatchQueue.main.async {
                        completion([], nil)
                    }
                }
            } catch {
                print("❌ Error fetching saved posts: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        print("📢 deletePost() called for post: \(postId)")
        
        Task {
            do {
                // 1. First delete all likes for this post to avoid foreign key constraints
                let likesResponse = try await client.database
                    .from("Likes")
                    .delete()
                    .eq("post_id", value: postId)
                    .execute()
                
                print("✅ Deleted likes for post: \(postId)")
                
                // 2. Delete all saved instances of this post
                let savedResponse = try await client.database
                    .from("SavedPosts")
                    .delete()
                    .eq("post_id", value: postId)
                    .execute()
                
                print("✅ Deleted saved instances of post: \(postId)")
                
                // 3. Delete all comments for this post
                // First, get all comment IDs to handle replies
                let commentsResponse = try await client.database
                    .from("Comments")
                    .select("Comment_id")
                    .eq("post_id", value: postId)
                    .execute()
                
                if let commentData = try? JSONSerialization.jsonObject(with: commentsResponse.data, options: []) as? [[String: Any]] {
                    let commentIds = commentData.compactMap { $0["Comment_id"] as? Int }
                    print("📊 Found \(commentIds.count) comments to delete for post: \(postId)")
                    
                    // 3a. Delete all comment replies
                    if !commentIds.isEmpty {
                        if let commentIdsJson = try? JSONEncoder().encode(commentIds),
                           let commentIdsJsonString = String(data: commentIdsJson, encoding: .utf8) {
                            let repliesResponse = try await client.database
                                .from("CommentReplies")
                                .delete()
                                .filter("comment_id", operator: "in", value: commentIdsJsonString)
                                .execute()
                            
                            print("✅ Deleted all comment replies")
                        } else {
                            print("⚠️ Failed to encode comment IDs for replies deletion")
                        }
                    }
                    
                    // 3b. Delete all comment likes
                    if !commentIds.isEmpty {
                        if let commentIdsJson = try? JSONEncoder().encode(commentIds),
                           let commentIdsJsonString = String(data: commentIdsJson, encoding: .utf8) {
                            let commentLikesResponse = try await client.database
                                .from("CommentLikes")
                                .delete()
                                .filter("comment_id", operator: "in", value: commentIdsJsonString)
                                .execute()
                            
                            print("✅ Deleted all comment likes")
                        } else {
                            print("⚠️ Failed to encode comment IDs for likes deletion")
                        }
                    }
                }
                
                // 3c. Now delete all comments
                let deleteCommentsResponse = try await client.database
                    .from("Comments")
                    .delete()
                    .eq("post_id", value: postId)
                    .execute()
                
                print("✅ Deleted all comments for post: \(postId)")
                
                // 4. Finally delete the post itself
                let postResponse = try await client.database
                    .from("posts")
                    .delete()
                    .eq("postId", value: postId)
                    .execute()
                
                print("✅ Deleted post: \(postId)")
                
                if postResponse.status >= 200 && postResponse.status < 300 {
                    // 5. If post has an image, attempt to delete it from storage
                    // Note: This is optional and may fail if image names don't match
                    if let fileIdMatch = postId.split(separator: "-").last {
                        let possibleImageName = "\(fileIdMatch).jpg"
                        do {
                            let _ = try await client.storage
                                .from("postimages")
                                .remove(paths: [possibleImageName])
                            
                            print("✅ Deleted image for post: \(postId)")
                        } catch {
                            print("⚠️ Could not delete image, but post deletion was successful")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } else {
                    let errorMessage = String(data: postResponse.data, encoding: .utf8) ?? "Unknown error"
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "DeletePostError", code: postResponse.status, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                    }
                }
            } catch {
                print("❌ Error deleting post: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    // MARK: - Post Deep Link Generation
    func generatePostDeepLink(for post: Post) -> URL? {
        // Create a deep link structure
        // Format: faby://post/{postId}
        
        let baseUrlString = "faby://post/"
        let postIdComponent = post.postId
        
        guard let url = URL(string: baseUrlString + postIdComponent) else {
            print("❌ Failed to create deep link URL")
            return nil
        }
        
        return url
    }
    
    // Generate a web link (for when deep links aren't available)
    func generatePostWebLink(for post: Post) -> URL? {
        // Use the Supabase URL as a base for web sharing
        // This is a placeholder for a real web link to your app
        
        let baseUrlString = "https://hlkmrimpxzsnxzrgofes.supabase.co/storage/v1/object/public/share"
        let postIdComponent = "/post/\(post.postId)"
        
        guard let url = URL(string: baseUrlString + postIdComponent) else {
            print("❌ Failed to create web link URL")
            return nil
        }
        
        return url
    }
    
    // MARK: - Debug Functions
    func debugFetchAllSavedPostsRecords(completion: @escaping (Bool) -> Void) {
        print("🔍 DEBUG: Fetching all records from SavedPosts table")
        
        Task {
            do {
                // Fetch all records from SavedPosts table
                let response = try await client.database
                    .from("SavedPosts")
                    .select("*")
                    .execute()
                
                print("📋 DEBUG: SavedPosts table raw response:")
                print(String(data: response.data, encoding: .utf8) ?? "No data")
                
                // Parse the response
                if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]] {
                    print("📊 DEBUG: SavedPosts table records count: \(jsonArray.count)")
                    
                    for (index, record) in jsonArray.enumerated() {
                        print("📝 DEBUG: Record #\(index + 1):")
                        print("   - id: \(record["id"] ?? "nil")")
                        print("   - user_id: \(record["user_id"] ?? "nil")")
                        print("   - post_id: \(record["post_id"] ?? "nil")")
                        print("   - created_at: \(record["created_at"] ?? "nil")")
                    }
                    
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("⚠️ DEBUG: Failed to parse SavedPosts records as JSON array")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("❌ DEBUG: Error fetching SavedPosts records: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func isPostSaved(postId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = self.userID else {
            print("❌ User not logged in")
            completion(false, NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        print("📢 isPostSaved() called for post: \(postId)")
        
        Task {
            do {
                // Check if postId is in valid UUID format
                if let _ = UUID(uuidString: postId) {
                    let response = try await client.database
                        .from("SavedPosts")
                        .select("id")
                        .eq("post_id", value: postId)
                        .eq("user_id", value: userId)
                        .execute()
                    
                    // Parse the response to check if any records were returned
                    if let jsonString = String(data: response.data, encoding: .utf8) {
                        // Try to parse the data
                        if let jsonArray = try? JSONSerialization.jsonObject(with: response.data) as? [Any] {
                            let isSaved = !jsonArray.isEmpty
                            print(isSaved ? "✅ Post is saved (found \(jsonArray.count) records)" : "ℹ️ Post is not saved (no records found)")
                            print("📄 Raw response data: \(jsonString)")
                            
                            DispatchQueue.main.async {
                                completion(isSaved, nil)
                            }
                            return
                        }
                    }
                    
                    // If we couldn't parse or the array was empty, the post is not saved
                    print("ℹ️ Post is not saved (no records or parsing failed)")
                    print("📄 Response data: \(String(data: response.data, encoding: .utf8) ?? "None")")
                    
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                } else {
                    // Not a valid UUID format
                    print("❌ Error: postId \(postId) is not in UUID format, cannot check in SavedPosts table with UUID column")
                    // Since it's just a check, we'll return false instead of an error
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
            } catch {
                print("❌ Error checking if post is saved: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    // Alternative formatter without milliseconds
    static let iso8601Simple: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func formatPostDate(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        
        // Try multiple date formats to handle different formats from the database
        var date: Date?
        
        // Try ISO8601 with full format first
        if date == nil {
            date = iso8601Full.date(from: dateString)
        }
        
        // Try with simple format (no milliseconds)
        if date == nil {
            date = iso8601Simple.date(from: dateString)
        }
        
        // Try with ISO8601DateFormatter as a fallback
        if date == nil {
            let isoFormatter = ISO8601DateFormatter()
            date = isoFormatter.date(from: dateString)
        }
        
        if let date = date {
            // Calculate time difference
            let now = Date()
            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: now)
            
            if let days = components.day, days > 0 {
                return "\(days) \(days == 1 ? "day" : "days") ago"
            } else if let hours = components.hour, hours > 0 {
                return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
            } else if let minutes = components.minute, minutes > 0 {
                return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
            } else {
                return "Just now"
            }
        } else {
            print("⚠️ Could not parse date from string: \(dateString)")
            return "Recently"  // Use a generic fallback instead of showing error
        }
    }
}
