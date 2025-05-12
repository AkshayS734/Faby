import Foundation
import Supabase

class AuthManager {
    static let shared = AuthManager()
    
//    let client = SupabaseClient(
//        supabaseURL: URL(string: "https://hlkmrimpxzsnxzrgofes.supabase.co")!,
//        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsa21yaW1weHpzbnh6cmdvZmVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAwNzI1MjgsImV4cCI6MjA1NTY0ODUyOH0.6mvladJjLsy4Q7DTs7x6jnQrLaKrlsnwDUlN-x_ZcFY"
//    )
    let client = SupabaseClient(supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY")
    
    var currentUserID: String? {
        guard let user = client.auth.currentUser else {
            return nil
        }
        return user.id.uuidString
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getClient() -> SupabaseClient {
        return client
    }
}
