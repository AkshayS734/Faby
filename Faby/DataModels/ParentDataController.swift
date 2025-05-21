import Foundation
import UIKit

class ParentDataController {
    static let shared = ParentDataController()
    
    private init() {}
    
    // Load parent data for the current user
    func loadParentData(completion: @escaping (Bool) -> Void) {
        Task {
            if let userId = await AuthManager.shared.getCurrentUserID() {
                print("📱 ParentDataController: Loading parent data for user ID: \(userId)")
                ParentDataModel.shared.updateCurrentParent(userId: userId) { success in
                    if success {
                        print("✅ ParentDataController: Successfully loaded parent data")
                    } else {
                        print("❌ ParentDataController: Failed to load parent data")
                    }
                    completion(success)
                }
            } else {
                print("⚠️ ParentDataController: No user ID available, user might not be logged in")
                completion(false)
            }
        }
    }
    
    // Get parent profile image
    func getParentProfileImage(completion: @escaping (UIImage?) -> Void) {
        guard let parent = ParentDataModel.shared.currentParent,
              let imageUrlString = parent.parentimage_url else {
            completion(UIImage(systemName: "person.circle.fill"))
            return
        }
        
        // Extract the path from the URL
        guard let url = URL(string: imageUrlString),
              let path = url.pathComponents.dropFirst().joined(separator: "/").removingPercentEncoding else {
            completion(UIImage(systemName: "person.circle.fill"))
            return
        }
        
        // Load image from Supabase storage
        SupabaseManager.shared.loadImageFromPublicBucket(path: path, bucket: "parent-images") { image in
            completion(image ?? UIImage(systemName: "person.circle.fill"))
        }
    }
    
    // Update parent profile in the settings view controller
    func updateParentProfileInSettings(viewController: SettingsViewController) {
        if let parent = ParentDataModel.shared.currentParent {
            // Update the profile cell with parent data
            viewController.updateParentInfo(name: parent.name, email: parent.email)
            
            // Load and update the profile image
            getParentProfileImage { image in
                DispatchQueue.main.async {
                    viewController.updateParentProfileImage(image: image)
                }
            }
        }
    }
}
