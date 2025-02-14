//
//  CommentDataManager.swift
//  Toddler Talk1
//
//  Created by Vivek kumar on 30/01/25.
//
//  CommentDataManager.swift
//  Talk
//

import Foundation

class PostDataManager {
    static let shared = PostDataManager()
    
    private init() {}
    private var posts: [Post] = getDemoComments()
    private var userPosts:[Post] = []
    func getUserPosts() -> [Post] {
        guard let currentParent = ParentDataModel.shared.currentParent else {
            print("No current parent found!")
            return []
        }
        return userPosts.filter { $0.parentPhoneNumber == currentParent.phoneNumber }
    }
    
    static func getDemoComments() -> [Post] {
        return [
            Post(parentPhoneNumber: "123-456-7890", username: "SarahM", title: "Sleep Solutions for Toddlers", text: "My 2-year-old used to wake up 4 times a night, but we found that a bedtime routine helped.", likes: 12, replies: ["That's great advice!", "I’ll try this."]),
            Post(parentPhoneNumber: "987-654-3210", username: "DadLife101", title: "Sleep Training Success", text: "We tried everything! What finally worked for us was giving our toddler a security blanket and making sure the room was completely dark.", likes: 8, replies: ["Security blankets work wonders!"]),
            Post(parentPhoneNumber: "555-123-6789", username: "EmilyRose", title: "Help! Toddler Won't Nap", text: "I need help! My 18-month-old won’t nap during the day and wakes up cranky. Any advice?", likes: 5, replies: ["Try a consistent schedule.", "Shorten nap times."]),
            Post(parentPhoneNumber: "111-222-3333", username: "ToddlerMom", title: "White Noise for Better Sleep", text: "White noise machines are a lifesaver! I’ve been using one for months, and my baby sleeps so much better now.", likes: 20, replies: ["Agree! White noise is amazing."]),
            Post(parentPhoneNumber: "444-555-6666", username: "SleepGuru99", title: "Consistency is Key", text: "It's all about consistency. Toddlers thrive on routine.", likes: 15, replies: []),
            Post(parentPhoneNumber: "777-888-9999", username: "BabySleepExpert", title: "Melatonin-Free Sleep Tips", text: "We switched to a calming bedtime routine without screens, and it worked wonders.", likes: 10, replies: ["Great idea!", "Will try this tonight."]),
            Post(parentPhoneNumber: "222-333-4444", username: "NightOwlDad", title: "Early Bedtime Struggles", text: "My 2-year-old refuses to sleep before 10 PM. Any tips?", likes: 7, replies: ["Try dimming the lights early.", "A warm bath helps."]),
            Post(parentPhoneNumber: "666-777-8888", username: "NewMom123", title: "Nap Time Battles", text: "My toddler fights naps but crashes later. How can I make nap time smoother?", likes: 9, replies: ["Consistency is key!", "Try a nap-time story."])
        ]
    }
    
    
    
    // Get all posts
    func getPosts() -> [Post] {
        return posts
    }
    
    // Add a new post
    // Add a new post
    func addPost(title: String, text: String) {
        guard let currentParent = ParentDataModel.shared.currentParent else {
            print("Error: No parent found!")
            return
        }
        
        let newPost = Post(
            parentPhoneNumber: currentParent.phoneNumber ?? "Unknown",
            username: currentParent.name,
            title: title,
            text: text
        )
        
        posts.insert(newPost, at: 0)
        userPosts.insert(newPost, at: 0)
        
        // ✅ Print Statement to Log Post Creation
        print("📝 New Post Created by \(currentParent.name) (\(currentParent.phoneNumber ?? "No Phone"))")
        print("📌 Post Title: \(title)")
        print("🗒️ Post Content: \(text)")
    }
    
    
    
}
