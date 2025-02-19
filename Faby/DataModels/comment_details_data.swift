//
//  commentdetails data.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

import Foundation

struct Post {
   // var id: String
   // var parentPhoneNumber: String // Link to Parent
  
    var username: String
    var title : String
    var text: String
    var likes: Int
    var replies: [String]
    
    init(username: String, title: String, text: String, likes: Int = 0, replies: [String] = []) {
    
      
        self.username = username
        self.title = title
        self.text = text
        self.likes = likes
        self.replies = replies
    }
}

// Demo data
class CommentDataManager {
    
    // Static method to get demo data
    static func getDemoComments() -> [Comment] {
        return [
            Comment(username: "SarahM",title: "sleep solutions for toddlers", text: "My 2-year-old used to wake up 4 times ", likes: 12, replies: ["That's great advice!", "I’ll try this."]),
            Comment(username: "DadLife101",title:"sleep", text: "We tried everything! What finally worked for us was giving our toddler a security blanket and making sure the room was completely dark.", likes: 8, replies: ["Security blankets work wonders!"]),
            Comment(username: "EmilyRose",title:"asdfghj", text: "I need help! My 18-month-old won’t nap during the day and wakes up cranky. Any advice?", likes: 5, replies: ["Try a consistent schedule.", "Shorten nap times."]),
            Comment(username: "ToddlerMom",title:"qwertyu", text: "White noise machines are a lifesaver! I’ve been using one for months night.", likes: 20, replies: ["Agree! White noise is amazing."]),
            Comment(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: []),
            Comment(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: []),
            Comment(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: [])
        ]
    }
}
