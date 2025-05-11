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
        
        // Filter posts based on the parent's username (or any other identifying attribute)
        return posts.filter { $0.username == currentParent.name }
    }

    
    static func getDemoComments() -> [Post] {
        return [
            Post( username: "SarahM", title: "Sleep Solutions for Toddlers", text: "My 2-year-old used to wake up 4 times a night, but we found that a bedtime routine helped.", likes: 12, replies: ["That's great advice!", "I’ll try this."]),
            Post( username: "DadLife101", title: "Sleep Training Success", text: "We tried everything! What finally worked for us was giving our toddler a security blanket and making sure the room was completely dark.", likes: 8, replies: ["Security blankets work wonders!"]),
            Post( username: "EmilyRose", title: "Help! Toddler Won't Nap", text: "I need help! My 18-month-old won’t nap during the day and wakes up cranky. Any advice?", likes: 5, replies: ["Try a consistent schedule.", "Shorten nap times."]),
            Post( username: "ToddlerMom", title: "White Noise for Better Sleep", text: "White noise machines are a lifesaver! I’ve been using one for months, and my baby sleeps so much better now.", likes: 20, replies: ["Agree! White noise is amazing."]),
            Post( username: "SleepGuru99", title: "Consistency is Key", text: "It's all about consistency. Toddlers thrive on routine.", likes: 15, replies: []),
            Post( username: "BabySleepExpert", title: "Melatonin-Free Sleep Tips", text: "We switched to a calming bedtime routine without screens, and it worked wonders.", likes: 10, replies: ["Great idea!", "Will try this tonight."]),
            Post( username: "NightOwlDad", title: "Early Bedtime Struggles", text: "My 2-year-old refuses to sleep before 10 PM. Any tips?", likes: 7, replies: ["Try dimming the lights early.", "A warm bath helps."]),
            Post( username: "NewMom123", title: "Nap Time Battles", text: "My toddler fights naps but crashes later. How can I make nap time smoother?", likes: 9, replies: ["Consistency is key!", "Try a nap-time story."]),

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
            username: currentParent.name,
            title: title,
            text: text
        )
        
        posts.insert(newPost, at: 0)
        userPosts.insert(newPost, at: 0)
        
        // ✅ Print Statement to Log Post Creation
        print("📝 New Post Created by \(currentParent.name)")
        print("📌 Post Title: \(title)")
        print("🗒️ Post Content: \(text)")
    }
    
    
    
}
