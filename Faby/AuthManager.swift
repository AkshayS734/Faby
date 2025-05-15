import Foundation
import Supabase

class AuthManager {
    static let shared = AuthManager()
        let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")
    
    var currentUserID: String? {
        guard let user = client.auth.currentUser else {
            return nil
        }
        return user.id.uuidString
    }
    
    var isUserLoggedIn: Bool {
        return client.auth.currentUser != nil
    }

    func signIn(email: String, password: String) async throws {
        // Validate inputs before attempting to sign in
        guard !email.isEmpty else {
            throw NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email cannot be empty"])
        }
        
        guard !password.isEmpty else {
            throw NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Password cannot be empty"])
        }
        
        print("🔐 AuthManager: Signing in with email: \(email)")
        try await client.auth.signIn(email: email, password: password)
        print("✅ AuthManager: Successfully signed in with email: \(email)")
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getClient() -> SupabaseClient {
        return client
    }
    
    func getCurrentUserID() async -> String? {
        do {
            let session = try await client.auth.session
            return session.user.id.uuidString
        } catch {
            print("Error fetching user ID: \(error.localizedDescription)")
            return nil
        }
    }
}
