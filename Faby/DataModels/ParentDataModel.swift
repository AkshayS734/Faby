import Foundation
import Supabase

class ParentDataModel {
    static let shared = ParentDataModel()

    var parentData: [Parent] = []
    var currentParent: Parent?

    private init() {
        // Initialize with nil, will be set after login
        currentParent = nil
    }
    
    // Update parent data based on user ID from login
    func updateCurrentParent(userId: String, completion: @escaping (Bool) -> Void) {
        print("📢 Updating current parent with userId: \(userId)")
        
        // Fetch parent data from Supabase
        Task {
            do {
                let client = SupabaseManager.shared.client
                
                let response = try await client.database
                    .from("parents")
                    .select()
                    .eq("uid", value: userId)
                    .limit(1)
                    .execute()
                
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("📜 Parent data from Supabase: \(jsonString)")
                }
                
                // Check if parent exists
                if let jsonData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                   let firstParent = jsonData.first {
                    
                    // Extract parent data
                    let name = firstParent["name"] as? String ?? "Unknown"
                    let email = firstParent["email"] as? String ?? ""
                    let phoneNumber = firstParent["phone_number"] as? String
                    let genderString = firstParent["gender"] as? String ?? "male"
                    let relationString = firstParent["relation"] as? String ?? "father"
                    let parentImageUrl = firstParent["parentimage_url"] as? String
                    
                    // Convert gender and relation strings to enums
                    let gender: Gender = genderString == "female" ? .female : .male
                    let relation: Relation
                    switch relationString.lowercased() { // Use lowercase to handle case variations
                    case "father":
                        relation = .father
                        print("✅ Set relation to father")
                    case "mother":
                        relation = .mother
                        print("✅ Set relation to mother")
                    default:
                        // If the relation is not recognized, check gender to make a better guess
                        if gender == .male {
                            relation = .father
                            print("⚠️ Unrecognized relation, defaulting to father based on gender")
                        } else if gender == .female {
                            relation = .mother
                            print("⚠️ Unrecognized relation, defaulting to mother based on gender")
                        } else {
                            relation = .guardian
                            print("⚠️ Unrecognized relation, defaulting to guardian")
                        }
                    }
                    
                    // Create parent object
                    self.currentParent = Parent(
                        name: name,
                        email: email,
                        phoneNumber: phoneNumber,
                        gender: gender,
                        relation: relation,
                     //   babyIds: [],
                        parentimage_url: parentImageUrl
                    )
                    
                    print("✅ Successfully updated current parent: \(name)")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    // Parent not found, create a new one with default values
                    print("⚠️ Parent not found in database, creating default parent")
                    self.currentParent = Parent(
                        name: "New User",
                        email: "",
                        gender: .male,
                        relation: .guardian,
                      //  babyIds: [],
                        parentimage_url: nil
                    )
                    
                    // Save this new parent to Supabase
                    try await client.database
                        .from("parents")
                        .insert([
                            "uid": userId,
                            "name": "New User",
                            "gender": "male",
                            "relation": "guardian"
                        ])
                        .execute()
                    
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
            } catch {
                print("❌ Error fetching parent data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
