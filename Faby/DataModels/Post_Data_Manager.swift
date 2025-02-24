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
    private var postsByCategory: [String: [Post]] = [:]
    private var userPosts:[Post] = []
    func getUserPosts() -> [Post] {
        guard let currentParent = ParentDataModel.shared.currentParent else {
            print("No current parent found!")
            return []
        }
        
        // Filter posts based on the parent's username (or any other identifying attribute)
        return postsByCategory.flatMap { $0.value }.filter { $0.username == currentParent.name }
    }
    func getPostsByCategory() -> [String: [Post]] {
        return postsByCategory
    }

    
    static func getDemoComments() -> [Post] {
        return [
            Post(username: "SarahM", title: "Sleep Solutions for Toddlers",
                 text: "My 2-year-old used to wake up 4 times a night, but we found that a bedtime routine helped.",
                 likes: 12, replies: [
                    Post(username: "MomLife24", title: "", text: "That’s great advice! What’s your routine like?", likes: 3, replies: []),
                    Post(username: "Dad101", title: "", text: "I’ll try this. My toddler struggles too.", likes: 2, replies: [])
                 ]),
            
            Post(username: "DadLife101", title: "Sleep Training Success",
                 text: "We tried everything! What finally worked for us was giving our toddler a security blanket and making sure the room was completely dark.",
                 likes: 8, replies: [
                    Post(username: "BabyGuru", title: "", text: "Security blankets work wonders! Glad it helped.", likes: 4, replies: [])
                 ]),
            
            Post(username: "EmilyRose", title: "Help! Toddler Won't Nap",
                 text: "I need help! My 18-month-old won’t nap during the day and wakes up cranky. Any advice?",
                 likes: 5, replies: [
                    Post(username: "CalmMom", title: "", text: "Try a consistent schedule. It worked for us!", likes: 5, replies: []),
                    Post(username: "DadOnDuty", title: "", text: "Maybe shorten nap times? Sometimes they sleep better at night.", likes: 3, replies: [])
                 ]),
            
            Post(username: "ToddlerMom", title: "White Noise for Better Sleep",
                 text: "White noise machines are a lifesaver! I’ve been using one for months, and my baby sleeps so much better now.",
                 likes: 20, replies: [
                    Post(username: "BabyGuru", title: "", text: "Agree! White noise is amazing.", likes: 6, replies: [])
                 ]),
            
            Post(username: "MomOfTwins", title: "Potty Training Struggles",
                 text: "Potty training twins is a challenge! Any tips for managing both at once?",
                 likes: 7, replies: [
                    Post(username: "TwinDad", title: "", text: "Rewards worked for us! Stickers and small treats.", likes: 5, replies: []),
                    Post(username: "BusyMama", title: "", text: "Training one at a time helped me. Good luck!", likes: 4, replies: [])
                 ]),
            
            Post(username: "FirstTimeDad", title: "Best Finger Foods?",
                 text: "Looking for safe finger foods for my 10-month-old. Any suggestions?",
                 likes: 6, replies: [
                    Post(username: "HealthyParent", title: "", text: "Soft banana slices and steamed carrots!", likes: 3, replies: []),
                    Post(username: "FoodieMom", title: "", text: "Avocado pieces and scrambled eggs are great.", likes: 2, replies: [])
                 ]),
            
            Post(username: "GentleParenting", title: "Handling Tantrums with Patience",
                 text: "Any parents practicing gentle parenting? How do you handle toddler tantrums?",
                 likes: 14, replies: [
                    Post(username: "MindfulMama", title: "", text: "Deep breaths and getting down to their level helps.", likes: 7, replies: []),
                    Post(username: "DadCalm", title: "", text: "Distraction works wonders sometimes!", likes: 5, replies: [])
                 ]),
            
            Post(username: "SpeechMama", title: "Delayed Speech Concerns",
                 text: "My 2-year-old isn't talking much. Should I be worried?",
                 likes: 10, replies: [
                    Post(username: "SLP_Mom", title: "", text: "Every child is different, but you could try more interactive reading!", likes: 6, replies: []),
                    Post(username: "ConcernedDad", title: "", text: "We started speech therapy early, and it helped a lot.", likes: 4, replies: [])
                 ]),
            
            Post(username: "BabySteps", title: "First Steps Milestone!",
                 text: "My little one took their first steps today! So proud! 🥹",
                 likes: 18, replies: [
                    Post(username: "ExcitedMom", title: "", text: "That’s amazing! Congrats!", likes: 8, replies: []),
                    Post(username: "ToddlerDad", title: "", text: "The fun begins! Enjoy the chasing. 😂", likes: 6, replies: [])
                 ]),
            
            Post(username: "DadJokes", title: "Funny Toddler Moments",
                 text: "My kid just tried to 'shush' the vacuum cleaner. 😂 What are your funniest toddler moments?",
                 likes: 22, replies: [
                    Post(username: "MomLaughs", title: "", text: "Mine tried to feed our cat a banana. 😂", likes: 9, replies: []),
                    Post(username: "FunDad", title: "", text: "Toddler logic is the best! My son calls all animals 'dog'.", likes: 7, replies: [])
                 ])
        ]
    }


    
    
    
    // Get all posts
    func getPosts(for category: String) -> [Post] {
            return postsByCategory[category] ?? []
        }
    
    // Add a new post
    // Add a new post
    func addPost(category: String, title: String, text: String, username: String) {
        let newPost = Post(username: username, title: title, text: text, likes: 0, replies: [])
        
        if postsByCategory[category] != nil {
            postsByCategory[category]?.insert(newPost, at: 0) // Insert at the top
        } else {
            postsByCategory[category] = [newPost]
        }
    


            // ✅ Print details in terminal
            print("✅ Post added under category: \(category)")
            print("post added by \(username)")
            print("📝 Title: \(title)")
            print("💬 Comment: \(text)")
        }
    // Fetch all posts
    func getAllPosts() -> [Post] {
        return posts
    }

    // Fetch comments (replies) for a specific post
    func getComments(for post: Post) -> [Post] {
        return post.replies
    }

    // Add a new comment to a post in the demo comments
    func addComment(toPost post: Post, comment: Post) {
        if let index = posts.firstIndex(where: { $0.title == post.title && $0.username == post.username }) {
            posts[index].replies.append(comment)
            print("✅ Comment added successfully!")
        } else {
            print("❌ Post not found!")
        }
    }

    
}
