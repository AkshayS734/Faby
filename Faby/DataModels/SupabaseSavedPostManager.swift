import Foundation
import UIKit
import Supabase

class SupabaseSavedPostManager {
    static let shared = SupabaseSavedPostManager()
    
    // Direct initialization of Supabase client
    private let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Saved Posts Management
    
    /// Fetch all saved posts for a specific user
    func fetchSavedPosts(forUserId userId: String) async throws -> [SavedPost] {
        
        do {
            let response = try await client
                .from("SavedPosts") // Using lowercase table name as per Supabase convention
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            print("Supabase response data: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            
            return try JSONDecoder().decode([SavedPost].self, from: response.data)
        } catch {
            print("Supabase error: \(error)")
            throw error
        }
    }
    
    /// Save a post for a user
    func savePost(userId: String, postId: String) async throws {
        
        // Create a new saved post record
        let savedPost = [
            "user_id": userId,
            "post_id": postId
        ]
        
        try await client
            .from("SavedPosts")
            .insert(savedPost)
            .execute()
        
        // Notify listeners about the new saved post
        await MainActor.run {
            NotificationCenter.default.post(name: .postSaved, object: nil)
        }
    }
    
    /// Remove a saved post
    func removeSavedPost(savedPostId: Int) async throws {
        
        try await client
            .from("SavedPosts")
            .delete()
            .eq("id", value: savedPostId)
            .execute()
        
        // Notify listeners about the removed saved post
        await MainActor.run {
            NotificationCenter.default.post(name: .postRemoved, object: nil)
        }
    }
    
    /// Check if a post is saved by a user
    func isPostSaved(userId: String, postId: String) async throws -> Bool {
        
        let response = try await client
            .from("SavedPosts")
            .select()
            .eq("user_id", value: userId)
            .eq("post_id", value: postId)
            .execute()
        
        let savedPosts = try JSONDecoder().decode([SavedPost].self, from: response.data)
        return !savedPosts.isEmpty
    }
    
    /// Fetch posts by their IDs from the Posts table
    func fetchPosts(byIds postIds: [String]) async throws -> [SupabasePost] {
        guard !postIds.isEmpty else { return [] }
        
        do {
            // Use the in filter to get posts with IDs in the provided array
            let response = try await client
                .from("posts")
                .select()
                .in("postId", values: postIds)
                .execute()
            
            print("Posts response data: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            
            return try JSONDecoder().decode([SupabasePost].self, from: response.data)
        } catch {
            print("Error fetching posts by IDs: \(error)")
            throw error
        }
    }
    
    /// Fetch a single post by its ID
    func fetchPost(byId postId: String) async throws -> SupabasePost? {
        do {
            let response = try await client
                .from("posts")
                .select()
                .eq("postId", value: postId)
                .single()
                .execute()
            
            return try JSONDecoder().decode(SupabasePost.self, from: response.data)
        } catch {
            print("Error fetching post by ID: \(error)")
            throw error
        }
    }
    
    /// Test function to verify Supabase connection and table existence
    func testConnection() async -> (success: Bool, message: String) {
        do {
            // First, check if we can connect to Supabase at all
            let response = try await client
                .from("SavedPosts")
                .select()
                .limit(1)
                .execute()
            
            print("Supabase connection test response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            
            // If we get here, the connection is working
            return (true, "Successfully connected to Supabase and verified 'SavedPosts' table exists")
            
        } catch {
            print("Supabase connection test error: \(error)")
            
            // Check if the error is because the table doesn't exist
            let errorString = error.localizedDescription.lowercased()
            if errorString.contains("relation \"savedposts\" does not exist") {
                return (false, "The 'SavedPosts' table does not exist in your Supabase database. Please create it with the required columns.")
            } else {
                return (false, "Failed to connect to Supabase: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let postSaved = Notification.Name("postSaved")
    static let postRemoved = Notification.Name("postRemoved")
}
