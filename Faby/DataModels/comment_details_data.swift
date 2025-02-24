//
//  commentdetails data.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

import Foundation

struct Post : Codable {
    var username: String
    var title: String
    var text: String
    var likes: Int
    var replies: [Post] // ✅ Must be an array of `Post`
    var timeStamp: Date
    
    init(username: String, title: String, text: String, likes: Int = 0, replies: [Post] = []) {
        self.username = username
        self.title = title
        self.text = text
        self.likes = likes
        self.replies = replies // ✅ Ensure replies are Post objects
        self.timeStamp = Date()
    }
}

