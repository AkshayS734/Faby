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
    var title: String
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
