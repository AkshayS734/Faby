import Foundation
import Supabase

class AuthManager {
    static let shared = AuthManager()
    let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")
    
    // Flag to track if we've tried to restore the session
    private var hasAttemptedSessionRestore = false
    
    // Store for user login state (additional backup to Supabase's own persistence)
    private let userDefaultsLoggedInKey = "user_logged_in"
    
    init() {
        // Configure Supabase session persistence
        configureSessionPersistence()
    }
    
    var currentUserID: String? {
        guard let user = client.auth.currentUser else {
            return nil
        }
        return user.id.uuidString
    }
    
    var isUserLoggedIn: Bool {
        // First check Supabase's current user
        if client.auth.currentUser != nil {
            return true
        }
        
        // If we haven't tried to restore the session yet, attempt to do so
        if !hasAttemptedSessionRestore {
            Task {
                await restoreSession()
            }
        }
        
        // Fall back to UserDefaults as a secondary check
        return UserDefaults.standard.bool(forKey: userDefaultsLoggedInKey)
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
        
        // Mark user as logged in for backup persistence
        UserDefaults.standard.set(true, forKey: userDefaultsLoggedInKey)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        
        // Clear logged in status in UserDefaults
        UserDefaults.standard.set(false, forKey: userDefaultsLoggedInKey)
        print("✅ AuthManager: User signed out successfully")
    }
    
    func getClient() -> SupabaseClient {
        return client
    }
    
    func getCurrentUserID() async -> String? {
        do {
            // Try to get current session
            let session = try await client.auth.session
            return session.user.id.uuidString
        } catch {
            print("Error fetching user ID: \(error.localizedDescription)")
            // Try to restore session if this fails
            await restoreSession()
            return client.auth.currentUser?.id.uuidString
        }
    }
    
    // MARK: - Session Management
    
    private func configureSessionPersistence() {
        // Supabase Swift client has built-in session persistence
        // This method is a placeholder for any additional configuration
        print("📱 AuthManager: Configured session persistence")
    }
    
    /// Attempts to restore the user session from persistent storage
    func restoreSession() async {
        hasAttemptedSessionRestore = true
        
        do {
            print("🔄 AuthManager: Attempting to restore user session...")
            let session = try await client.auth.session
            print("✅ AuthManager: Session restored successfully for user ID: \(session.user.id.uuidString)")
            
            // Ensure our UserDefaults is in sync with the actual session state
            UserDefaults.standard.set(true, forKey: userDefaultsLoggedInKey)
        } catch {
            print("❌ AuthManager: Failed to restore session - \(error.localizedDescription)")
            // Clear the login state since we couldn't restore
            UserDefaults.standard.set(false, forKey: userDefaultsLoggedInKey)
        }
    }
}
