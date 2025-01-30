//
//  commentdetails data.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

import Foundation

// Data model for Comment
struct Post {
    var username: String
    var title : String
    var text: String
    var likes: Int
    var replies: [String]

}

// Demo data
class CommentDataManager {
    
    // Static method to get demo data
    static func getDemoComments() -> [Post] {
        return [
            Post(username: "SarahM",title: "sleep solutions for toddlers", text: "My 2-year-old used to wake up 4 times ", likes: 12, replies: ["That's great advice!", "I’ll try this."]),
            Post(username: "DadLife101",title:"sleep", text: "We tried everything! What finally worked for us was giving our toddler a security blanket and making sure the room was completely dark.", likes: 8, replies: ["Security blankets work wonders!"]),
            Post(username: "EmilyRose",title:"asdfghj", text: "I need help! My 18-month-old won’t nap during the day and wakes up cranky. Any advice?", likes: 5, replies: ["Try a consistent schedule.", "Shorten nap times."]),
            Post(username: "ToddlerMom",title:"qwertyu", text: "White noise machines are a lifesaver! I’ve been using one for months night.", likes: 20, replies: ["Agree! White noise is amazing."]),
            Post(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: []),
            Post(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: []),
            Post(username: "SleepGuru99",title: "zxcvbn", text: "It's all about consistency. Toddlers thrive on routine. ", likes: 15, replies: [])
        ]
    }
}
