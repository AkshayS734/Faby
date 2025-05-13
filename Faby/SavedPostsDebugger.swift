import UIKit

class SavedPostsDebugger {
    
    static func checkSupabasePermissions(completion: @escaping (Bool) -> Void) {
        print("\n----- CHECKING SUPABASE PERMISSIONS -----")
        
        // Check if user is authenticated
        guard let userId = PostsSupabaseManager.shared.userID else {
            print("❌ ERROR: No user ID found - user not authenticated")
            completion(false)
            return
        }
        
        print("✅ User is authenticated with ID: \(userId)")
        
        Task {
            do {
                // Check access to SavedPosts table with SELECT
                let selectResponse = try await PostsSupabaseManager.shared.client.database
                    .from("SavedPosts")
                    .select("*")
                    .limit(1)
                    .execute()
                
                print("📄 SELECT permission test response: \(String(data: selectResponse.data, encoding: .utf8) ?? "No data")")
                print("✅ SELECT permission test successful (Status: \(selectResponse.status))")
                
                // Check Posts table to make sure it exists
                let postsResponse = try await PostsSupabaseManager.shared.client.database
                    .from("posts")
                    .select("postId")
                    .limit(1)
                    .execute()
                
                print("📄 Posts table test response: \(String(data: postsResponse.data, encoding: .utf8) ?? "No data")")
                print("✅ Posts table access successful (Status: \(postsResponse.status))")
                
                // All checks passed
                print("✅ All permission checks PASSED")
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("❌ ERROR during permission checks: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    static func runTests() {
        print("\n========= SAVED POSTS DEBUGGER =========")
        
        // First check Supabase permissions
        checkSupabasePermissions { success in
            if !success {
                print("❌ CRITICAL ERROR: Supabase permission checks failed")
                print("========= DEBUGGER ABORTED =========")
                return
            }
            
            // Step 1: Check all SavedPosts records in the table
            print("\n----- STEP 1: Fetch all saved posts -----")
            PostsSupabaseManager.shared.debugFetchAllSavedPostsRecords { success in
                if success {
                    print("✅ Successfully fetched all saved posts records")
                } else {
                    print("❌ Failed to fetch saved posts records")
                }
                
                // Step 2: Check a specific post that might be saved
                print("\n----- STEP 2: Check if a specific post is saved -----")
                
                // You can replace this with any post ID you want to test
                let testPostId = "9b2f116f-8681-4f2b-aa39-0985fa9fddaa"
                
                PostsSupabaseManager.shared.debugIsPostSaved(postId: testPostId) { isSaved in
                    print("✅ Is post saved check completed. Result: \(isSaved ? "SAVED" : "NOT SAVED")")
                    
                    // Step 3: Try to save a post
                    print("\n----- STEP 3: Try to save a post -----")
                    PostsSupabaseManager.shared.savePost(postId: testPostId) { success, error in
                        if success {
                            print("✅ Post saved successfully")
                        } else if let error = error {
                            print("❌ Error saving post: \(error.localizedDescription)")
                        } else {
                            print("❌ Failed to save post for unknown reason")
                        }
                        
                        // Step 4: Check again if the post is saved
                        print("\n----- STEP 4: Check again if the post is saved -----")
                        PostsSupabaseManager.shared.debugIsPostSaved(postId: testPostId) { isSaved in
                            print("✅ Is post saved check completed. Result: \(isSaved ? "SAVED" : "NOT SAVED")")
                            
                            // Step 5: Check all SavedPosts records again
                            print("\n----- STEP 5: Fetch all saved posts again -----")
                            PostsSupabaseManager.shared.debugFetchAllSavedPostsRecords { success in
                                if success {
                                    print("✅ Successfully fetched all saved posts records")
                                } else {
                                    print("❌ Failed to fetch saved posts records")
                                }
                                
                                print("\n========= DEBUGGER COMPLETED =========")
                            }
                        }
                    }
                }
            }
        }
    }
} 
