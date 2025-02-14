//
//  commentdetails data.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

struct Post {
   // var id: String
    var parentPhoneNumber: String // Link to Parent
    var username: String
    var title: String
    var text: String
    var likes: Int
    var replies: [String]
    
    init(parentPhoneNumber: String, username: String, title: String, text: String, likes: Int = 0, replies: [String] = []) {
     //   self.id = UUID()
        self.parentPhoneNumber = parentPhoneNumber
        self.username = username
        self.title = title
        self.text = text
        self.likes = likes
        self.replies = replies
    }
}

