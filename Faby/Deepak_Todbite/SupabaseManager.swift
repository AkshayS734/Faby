//
//  SupabaseManager.swift
//  Faby
//
//  Created by DEEPAK PRAJAPATI on 12/05/25.
//

import Foundation
import Supabase
class SupabaseManager {
    static func saveToMyBowlDatabase(_ meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot save meal to My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Saving meal to My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Create entry with the user ID
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // Insert with the user ID
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully saved meal to My Bowl database")
        } catch let error {
            print("❌ Error saving to My Bowl database: \(error)")
            
            // Extract error details from the description
            let errorDescription = error.localizedDescription
            print("🔍 Error details: \(errorDescription)")
        }
    }
    
    // Delete a meal from My Bowl in Supabase
    static func deleteFromMyBowlDatabase(mealId: Int, using client: SupabaseClient) async {
        do {
            print("🔄 Deleting meal from My Bowl database, mealId: \(mealId)")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Delete the entry matching both user_id and meal_id
            let response = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            print("✅ Successfully deleted meal from My Bowl database")
        } catch let error {
            print("❌ Error deleting from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Update bite type for a meal in My Bowl
    // Note: In Supabase, we don't directly store the bite_type in my_Bowl table
    // Instead, we'll delete the existing entry and create a new one with the same meal_id
    static func updateBiteTypeInMyBowlDatabase(meal: FeedingMeal, using client: SupabaseClient) async {
        guard let mealId = meal.id else {
            print("❌ Cannot update meal in My Bowl: missing meal ID")
            return
        }
        
        do {
            print("🔄 Updating meal in My Bowl database: \(meal.name)")
            
            // First, get the current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // 1. Delete existing entry
            _ = try await client.database
                .from("my_Bowl")
                .delete()
                .eq("user_id", value: userId)
                .eq("meal_id", value: mealId)
                .execute()
            
            // 2. Create a new entry (with the updated meal which has a new bite type)
            let myBowlEntry = MyBowlEntry(from: meal, userId: userId)
            
            // 3. Insert the new entry
            let response = try await client.database
                .from("my_Bowl")
                .insert(myBowlEntry)
                .execute()
            
            print("✅ Successfully updated meal in My Bowl database")
        } catch let error {
            print("❌ Error updating meal in My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    // Load all My Bowl meals for the current user from database
    static func loadMyBowlMealsFromDatabase(using client: SupabaseClient) async -> [FeedingMeal] {
        var meals: [FeedingMeal] = []
        
        do {
            print("🔄 Loading My Bowl meals from database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Query my_Bowl table to get all meals for this user
            let response = try await client.database
                .from("my_Bowl")
                .select("meal_id")
                .eq("user_id", value: userId)
                .execute()
            
            // Extract meal IDs from response
            if response.data.isEmpty {
                print("❌ No data found in my_Bowl table")
                return []
            }
            
            // Parse the response to get meal IDs
            let decoder = JSONDecoder()
            let bowlEntries = try decoder.decode([MyBowlResponseEntry].self, from: response.data)
            
            // Get all the meal IDs
            let mealIds = bowlEntries.map { $0.meal_id }
            
            if mealIds.isEmpty {
                print("⚠️ No meals found in my_Bowl table")
                return []
            }
            
            print("🔍 Found \(mealIds.count) meals in my_Bowl")
            
            // For each meal ID, fetch the full meal details from the feeding_meals table
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    // Check if mealResponse.data has content
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        let decodedMeals = try decoder.decode([FeedingMeal].self, from: mealResponse.data)
                        
                        if let meal = decodedMeals.first {
                            meals.append(meal)
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            print("✅ Successfully loaded \(meals.count) meals from My Bowl database")
            return meals
            
        } catch let error {
            print("❌ Error loading from My Bowl database: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Save feeding plan to the database
    static func saveFeedingPlan(meals: [FeedingMeal], planType: FeedingPlanType, startDate: Date, endDate: Date, using client: SupabaseClient) async -> Bool {
        do {
            print("🔄 Saving feeding plan to database")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // For each meal, create a feeding plan entry and save it
            for meal in meals {
                guard let mealId = meal.id else {
                    print("⚠️ Skipping meal without ID: \(meal.name)")
                    continue
                }
                
                let planEntry = FeedingPlanEntry(
                    mealId: mealId,
                    userId: userId,
                    planType: planType,
                    startDate: startDate,
                    endDate: endDate
                )
                
                // Insert into feeding_plan table
                let response = try await client.database
                    .from("feeding_plan")
                    .insert(planEntry)
                    .execute()
                
                print("✅ Added meal to feeding plan: \(meal.name)")
            }
            
            print("✅ Successfully saved feeding plan with \(meals.count) meals")
            return true
            
        } catch let error {
            print("❌ Error saving feeding plan: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return false
        }
    }
    
    // Load feeding plans for a specific date range
    static func loadFeedingPlans(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [FeedingPlanEntry] {
        var planEntries: [FeedingPlanEntry] = []
        
        do {
            print("🔄 Loading feeding plans for date range")
            
            // Get current user's ID
            let userResponse = try await client.auth.session
            let userId = userResponse.user.id.uuidString
            
            // Format dates for query
            let dateFormatter = ISO8601DateFormatter()
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            // Query feeding_plan table for entries in the date range
            let response = try await client.database
                .from("feeding_plan")
                .select("*")
                .eq("user_id", value: userId)
                .gte("start_date", value: startDateString)
                .lte("end_date", value: endDateString)
                .execute()
            
            // Extract plan entries from response
            if !response.data.isEmpty {
                let decoder = JSONDecoder()
                planEntries = try decoder.decode([FeedingPlanEntry].self, from: response.data)
            }
            
            print("✅ Loaded \(planEntries.count) feeding plan entries")
            return planEntries
            
        } catch let error {
            print("❌ Error loading feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return []
        }
    }
    
    // Extended method to load feeding plans with meal details
    static func loadFeedingPlansWithMeals(startDate: Date, endDate: Date, using client: SupabaseClient) async -> [String: [BiteType: [FeedingMeal]]] {
        var result: [String: [BiteType: [FeedingMeal]]] = [:]
        
        do {
            print("🔄 Loading feeding plans with meal details")
            
            // First, load all plan entries
            let planEntries = await loadFeedingPlans(startDate: startDate, endDate: endDate, using: client)
            
            if planEntries.isEmpty {
                return result
            }
            
            // Get all unique meal IDs
            let mealIds = Array(Set(planEntries.map { $0.feeding_meal_id }))
            
            // Get date formatter for result keys
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E d MMM" // Same format as getFormattedDate in FeedingPlanViewController
            
            // Fetch meals for all IDs
            var mealDetails: [Int: FeedingMeal] = [:]
            
            for mealId in mealIds {
                do {
                    let mealResponse = try await client.database
                        .from("feeding_meals")
                        .select("*")
                        .eq("id", value: mealId)
                        .execute()
                    
                    if !mealResponse.data.isEmpty {
                        let decoder = JSONDecoder()
                        if let meals = try? decoder.decode([FeedingMeal].self, from: mealResponse.data),
                           let meal = meals.first {
                            mealDetails[mealId] = meal
                        }
                    }
                } catch {
                    print("❌ Error fetching meal details for ID \(mealId): \(error)")
                }
            }
            
            // Process each plan entry
            for entry in planEntries {
                guard let meal = mealDetails[entry.feeding_meal_id] else {
                    continue
                }
                
                // Parse the date
                if let entryDate = parseDate(from: entry.start_date) {
                    // Format date as key
                    let dateKey = dateFormatter.string(from: entryDate)
                    
                    // Initialize dictionary for this date if needed
                    if result[dateKey] == nil {
                        result[dateKey] = [:]
                    }
                    
                    // Initialize array for this category if needed
                    if result[dateKey]?[meal.category] == nil {
                        result[dateKey]?[meal.category] = []
                    }
                    
                    // Add meal to the appropriate category
                    result[dateKey]?[meal.category]?.append(meal)
                }
            }
            
            print("✅ Processed feeding plans into \(result.count) days")
            return result
            
        } catch let error {
            print("❌ Error processing feeding plans: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return [:]
        }
    }
    
    // Helper method to parse ISO date string to Date
    private static func parseDate(from iso8601String: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: iso8601String)
    }
}

// MARK: - Bluetooth Functionality
var dataBuf: Data? = nil // Using optional Data instead of implicitly unwrapped optional

// Function to rebuild packet data from partial data
func rebuiltPacket(data: Data) -> Data? {
    var fullPacket: Data? = nil
    
    if dataBuf == nil {
        dataBuf = data
    } else if let existingData = dataBuf, (existingData.count + data.count) == 20 {
        fullPacket = existingData + data
        dataBuf = nil
    }
    
    return fullPacket
}

// Function to parse complete packet data
func parsePacket(data: Data) {
    guard data.count >= 1 else { return }
    
    let myFirstByte = data[0]
    print("\(myFirstByte)")
}



