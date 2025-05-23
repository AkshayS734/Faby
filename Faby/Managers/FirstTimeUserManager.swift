import Foundation
import Supabase
import UIKit

//// Import view controllers
//@_exported import class Faby.VacciAlertViewController
//@_exported import class Faby.VaccineInputViewController

class FirstTimeUserManager {
    static let shared = FirstTimeUserManager()
    
    private init() {}
    
    // Define an encodable struct for insert/update operations
    private struct FirstTimeUserRecord: Encodable {
        let baby_id: String
        let has_seen: Bool
    }
    
    /// Check if the baby has seen the vaccine input screen
    /// - Parameter babyId: UUID of the baby
    /// - Returns: Bool indicating if the baby has seen the screen
    func checkFirstTimeUser(babyId: UUID) async throws -> Bool {
        print("🔍 [FirstTimeUserManager] Checking first time user status for baby: \(babyId)")
        
        guard let client = (UIApplication.shared.delegate as? AppDelegate)?.supabase ??
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.supabase else {
            print("❌ [FirstTimeUserManager] Error: Supabase client not available")
            throw NSError(domain: "FirstTimeUserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        do {
            print("📡 [FirstTimeUserManager] Querying firstTimeUser table for baby_id: \(babyId.uuidString)")
            // Query the firstTimeUser table
            let response = try await client
                .from("firstTimeUser")
                .select()
                .eq("baby_id", value: babyId.uuidString)
                .single()
                .execute()
            
            print("✅ [FirstTimeUserManager] Got response from firstTimeUser table")
            print("📊 [FirstTimeUserManager] Response data: \(String(describing: response.data))")
            
            // Decode the response
            struct FirstTimeUser: Codable {
                let baby_id: String
                let has_seen: Bool
                let created_at: String
            }
            
            if let firstTimeUser = try? JSONDecoder().decode(FirstTimeUser.self, from: response.data) {
                print("📱 [FirstTimeUserManager] Found existing record - has_seen: \(firstTimeUser.has_seen)")
                return firstTimeUser.has_seen
            } else {
                print("🆕 [FirstTimeUserManager] No record found, creating new entry")
                // Create a new record using the FirstTimeUserRecord struct
                let insertData = FirstTimeUserRecord(
                    baby_id: babyId.uuidString,
                    has_seen: false
                )
                
                print("📝 [FirstTimeUserManager] Inserting new record for baby_id: \(insertData.baby_id)")
                try await client
                    .from("firstTimeUser")
                    .insert(insertData)
                    .execute()
                
                print("✅ [FirstTimeUserManager] Successfully inserted new record with has_seen = false")
                return false
            }
        } catch {
            print("❌ [FirstTimeUserManager] Error checking first time user: \(error)")
            print("❌ [FirstTimeUserManager] Detailed error: \(String(describing: error))")
            // If there's an error, assume it's a first-time user
            return false
        }
    }
    
    /// Update the has_seen status for a baby
    /// - Parameters:
    ///   - babyId: UUID of the baby
    ///   - hasSeen: New has_seen status
    func updateHasSeenStatus(babyId: UUID, hasSeen: Bool) async throws {
        print("🔄 [FirstTimeUserManager] Updating has_seen status for baby: \(babyId) to: \(hasSeen)")
        
        guard let client = (UIApplication.shared.delegate as? AppDelegate)?.supabase ??
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.supabase else {
            print("❌ [FirstTimeUserManager] Error: Supabase client not available")
            throw NSError(domain: "FirstTimeUserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        do {
            print("📡 [FirstTimeUserManager] Sending update request to firstTimeUser table...")
            // Create update data using the FirstTimeUserRecord struct
            let updateData = FirstTimeUserRecord(
                baby_id: babyId.uuidString,
                has_seen: hasSeen
            )
            
            let response = try await client
                .from("firstTimeUser")
                .update(updateData)
                .eq("baby_id", value: babyId.uuidString)
                .execute()
            
            print("✅ [FirstTimeUserManager] Successfully updated has_seen status")
            print("📊 [FirstTimeUserManager] Response data: \(String(describing: response))")
            
            // Verify the update
            let verifyResponse = try await client
                .from("firstTimeUser")
                .select()
                .eq("baby_id", value: babyId.uuidString)
                .single()
                .execute()
            
            print("🔍 [FirstTimeUserManager] Verifying update - Response: \(String(describing: verifyResponse.data))")
        } catch {
            print("❌ [FirstTimeUserManager] Error updating has_seen status: \(error)")
            print("❌ [FirstTimeUserManager] Detailed error: \(String(describing: error))")
            throw error
        }
    }
}

// MARK: - Navigation Extension
extension UIViewController {
    func navigateToVaccineAlertViewController() {
        print("🔄 [Navigation] Attempting to navigate to VacciAlertViewController")
        let vacciAlertVC = VacciAlertViewController()
        
        // Clear navigation stack to prevent going back to first-time screens
        if let navigationController = self.navigationController {
            print("📱 [Navigation] Setting VacciAlertViewController as root")
            navigationController.setViewControllers([vacciAlertVC], animated: true)
        } else {
            // If not in a navigation controller, present modally
            print("📱 [Navigation] Presenting VacciAlertViewController modally")
            vacciAlertVC.modalPresentationStyle = .fullScreen
            present(vacciAlertVC, animated: true)
        }
    }
    
    func navigateToVaccineInput() {
        print("🔄 [Navigation] Attempting to navigate to VaccineInputViewController")
        let vaccineInputVC = VaccineInputViewController()
        
        // If we're in a navigation controller, push the view controller
        if let navigationController = self.navigationController {
            print("📱 [Navigation] Pushing VaccineInputViewController to navigation stack")
            navigationController.pushViewController(vaccineInputVC, animated: true)
        } else {
            // If not in a navigation controller, present modally
            print("📱 [Navigation] Presenting VaccineInputViewController modally")
            vaccineInputVC.modalPresentationStyle = .fullScreen
            present(vaccineInputVC, animated: true)
        }
    }
    
    /// Check first time user status and navigate accordingly
    func checkAndNavigateFirstTimeUser() {
        print("🔍 [Navigation] Starting first-time user check and navigation")
        Task {
            do {
                // First try to get the current baby ID
                guard let currentBabyId = UserDefaultsManager.shared.currentBabyId else {
                    print("⚠️ [Navigation] No current baby ID found, attempting to fetch first connected baby")
                    // If no baby ID is set, try to fetch the first connected baby
                    let baby = try await fetchFirstConnectedBaby()
                    print("✅ [Navigation] Found first connected baby: \(baby.babyID)")
                    UserDefaultsManager.shared.currentBabyId = baby.babyID
                    
                    // Check first time status for this baby
                    let hasSeen = try await FirstTimeUserManager.shared.checkFirstTimeUser(babyId: baby.babyID)
                    print("📊 [Navigation] First time status for new baby: hasSeen = \(hasSeen)")
                    await MainActor.run {
                        handleNavigation(hasSeen: hasSeen)
                    }
                    return
                }
                
                print("🔍 [Navigation] Found current baby ID: \(currentBabyId)")
                // Check first time status for the current baby
                let hasSeen = try await FirstTimeUserManager.shared.checkFirstTimeUser(babyId: currentBabyId)
                print("📊 [Navigation] First time status for current baby: hasSeen = \(hasSeen)")
                await MainActor.run {
                    handleNavigation(hasSeen: hasSeen)
                }
            } catch {
                print("❌ [Navigation] Error in checkAndNavigateFirstTimeUser: \(error)")
                // On error, default to vaccine input for safety
                await MainActor.run {
                    print("⚠️ [Navigation] Defaulting to VaccineInput due to error")
                    navigateToVaccineInput()
                }
            }
        }
    }
    
    private func handleNavigation(hasSeen: Bool) {
        print("🔄 [Navigation] Handling navigation based on hasSeen: \(hasSeen)")
        if hasSeen {
            print("📱 [Navigation] User has seen vaccine input, navigating to VacciAlertViewController")
            navigateToVaccineAlertViewController()
        } else {
            print("📱 [Navigation] First time user, navigating to VaccineInputViewController")
            navigateToVaccineInput()
        }
    }
}
