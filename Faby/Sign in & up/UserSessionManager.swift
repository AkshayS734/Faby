import Foundation
import Supabase
import UIKit

enum SignupStage: String, Codable {
    case none
    case emailVerified
    case parentInfoAdded
    case babyInfoAdded
    case completed
}

class UserSessionManager {
    static let shared = UserSessionManager()
    
    private let userDefaults = UserDefaults.standard
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://tmnltannywgqrrxavoge.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbmx0YW5ueXdncXJyeGF2b2dlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NjQ0MjQsImV4cCI6MjA2MjU0MDQyNH0.pkaPTx--vk4GPULyJ6o3ttI3vCsMUKGU0TWEMDpE1fY"
    )
    
    // Keys for UserDefaults
    private let signupStageKey = "signupStage"
    private let userEmailKey = "userEmail"
    private let userPasswordKey = "userPassword" // Consider more secure storage for production
    private let userInfoKey = "userInfo"
    private let sessionKey = "supabaseSession"
    
    private init() {}
    
    // MARK: - Session Management
    
    var currentSignupStage: SignupStage {
        get {
            guard let stageString = userDefaults.string(forKey: signupStageKey),
                  let stage = SignupStage(rawValue: stageString) else {
                return .none
            }
            return stage
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: signupStageKey)
        }
    }
    
    var userEmail: String? {
        get { userDefaults.string(forKey: userEmailKey) }
        set { userDefaults.set(newValue, forKey: userEmailKey) }
    }
    
    var userPassword: String? {
        get { userDefaults.string(forKey: userPasswordKey) }
        set { userDefaults.set(newValue, forKey: userPasswordKey) }
    }
    
    var userInfo: [String: String]? {
        get {
            guard let data = userDefaults.data(forKey: userInfoKey) else { return nil }
            return try? JSONDecoder().decode([String: String].self, from: data)
        }
        set {
            if let newValue = newValue, let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: userInfoKey)
            } else {
                userDefaults.removeObject(forKey: userInfoKey)
            }
        }
    }
    
    var supabaseSession: String? {
        get { userDefaults.string(forKey: sessionKey) }
        set { userDefaults.set(newValue, forKey: sessionKey) }
    }
    
    // Save session after OTP verification
    func saveEmailVerifiedSession(email: String, password: String, userInfo: [String: String], session: String) {
        self.userEmail = email
        self.userPassword = password
        self.userInfo = userInfo
        self.supabaseSession = session
        self.currentSignupStage = .emailVerified
    }
    
    // Update session after parent info is added
    func updateToParentInfoAdded() {
        self.currentSignupStage = .parentInfoAdded
    }
    
    // Update session after baby info is added
    func updateToBabyInfoAdded() {
        self.currentSignupStage = .babyInfoAdded
    }
    
    // Complete signup
    func completeSignup() {
        self.currentSignupStage = .completed
    }
    
    // Check if user is authenticated
    func isAuthenticated() -> Bool {
        return supabaseSession != nil
    }
    
    // Restore session with Supabase
    func restoreSession() async -> Bool {
        guard let sessionString = supabaseSession,
              let userEmail = userEmail else {
            return false
        }
        
        do {
            // Check if user is already authenticated
            do {
                let session = try await supabase.auth.session
                return session != nil
            } catch {
                print("Failed to get current session: \(error)")
            }
            
            
            return false
        } catch {
            print("Failed to restore session: \(error)")
            clearSession()
            return false
        }
    }
    
    // Clear session data
    func clearSession() {
        userDefaults.removeObject(forKey: signupStageKey)
        userDefaults.removeObject(forKey: userEmailKey)
        userDefaults.removeObject(forKey: userPasswordKey)
        userDefaults.removeObject(forKey: userInfoKey)
        userDefaults.removeObject(forKey: sessionKey)
    }
    
    // Get the appropriate view controller based on signup stage
    func getAppropriateViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch currentSignupStage {
        case .none:
            // Show the initial auth screen
            return AuthViewController()
            
        case .emailVerified:
            // Show the baby signup screen
            let signupContainer = SignupContainerViewController()
            // Configure to skip to baby signup
            signupContainer.skipToOTPVerified = true
            return signupContainer
            
        case .parentInfoAdded, .babyInfoAdded, .completed:
            // Show the main app
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                return tabBarController
            } else {
                return AuthViewController()
            }
        }
    }
}
